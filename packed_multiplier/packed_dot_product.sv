module packed_dot_product #(
    parameter exponent_width = 4,
    parameter mantissa_width = 3,
    parameter mul_width = 18,
    parameter block_size = 32, // must be divisible by 2 since the DSP can handle 2 multiplications at once
    localparam num_ops = mul_width / 2 / (1+mantissa_width), 
    // Sign + Mantissa_Multiplied + Max_Exponent_Sum_Shift + Block_Sum
    localparam fixed_point_product_width = 1 + 2 * (mantissa_width + 1) + 2 ** (exponent_width + 1) - 2,
    localparam fixed_point_result_width = 1 + 2 * (mantissa_width + 1) + 2 ** (exponent_width + 1) -2 + $clog2(block_size)
) (
    input logic clk,
    // NOTE: operands are a sequence of block-length vectors
    input logic [1 + mantissa_width + exponent_width -1:0] operands [block_size-1:0][num_ops-1:0], sharedOperands [block_size-1:0],
    // output size is 1 + 2(M+1) + 2^(E+1) + log2(B)
    output logic [fixed_point_result_width-1:0] results [num_ops-1:0]
);

// MXFP format example
//
// MXFP-8 E4M3
// always first bit sign
// SEEEEMMM
// sign: [E+M] = [7]
// exponent: [E+M-1:M] = [6:3]
// mantissa: [M-1:0] = [2:0]
// 
// multiplication of two MXFP numbers
// EEEE + EEEE -> EEEEE
// 1MMM * 1MMM -> MMMMMMMM
//
// conversion to fixed point
// shift left mantissa by 2^E

// intermediate between multiplication and reduction trees
logic [fixed_point_product_width-1:0] fixed_point_products [block_size-1:0][num_ops-1:0];

// MULTIPLICATION AND CONVERSION
for (genvar i = 0; i < block_size/2; i++) begin

    // Connections between packed multipliers and DSP
    logic [17:0] ax, ay, bx, by;
    logic [35:0] resulta, resultb;
    // Connections between packed multipliers and float-fix conversion
    logic [2*(mantissa_width + 1)-1:0] mantissa_products_a [num_ops-1:0], mantissa_products_b [num_ops-1:0];
    logic [exponent_width:0] exponent_sums_a [num_ops-1:0], exponent_sums_b [num_ops-1:0];

    // Subnormal handling: if exponent is 0, the first bit of the mantissa is 0 instead of 1. 
    logic shared_is_normal_a, shared_is_normal_b;
    logic is_normal_a [num_ops-1:0], is_normal_b [num_ops-1:0];
    assign shared_is_normal_a = sharedOperands[i*2][exponent_width+mantissa_width-1:mantissa_width] != 0;
    assign shared_is_normal_b = sharedOperands[i*2+1][exponent_width+mantissa_width-1:mantissa_width] != 0;
    for (genvar n = 0; n < num_ops; n++) begin
        assign is_normal_a[n] = operands[i*2][n][exponent_width+mantissa_width-1:mantissa_width] != 0;
        assign is_normal_b[n] = operands[i*2+1][n][exponent_width+mantissa_width-1:mantissa_width] != 0;
    end 

    // Extract mantissas 
    logic [mantissa_width:0] mantissas_a [num_ops-1:0], mantissas_b [num_ops-1:0], shared_mantissa_a , shared_mantissa_b;
    assign shared_mantissa_a = {shared_is_normal_a, sharedOperands[i*2][mantissa_width-1:0]};
    assign shared_mantissa_b = {shared_is_normal_b, sharedOperands[i*2+1][mantissa_width-1:0]};
    for (genvar n = 0; n < num_ops; n++) begin
        assign mantissas_a[n] = {is_normal_a[n], operands[i*2][n][mantissa_width-1:0]};
        assign mantissas_b[n] = {is_normal_b[n], operands[i*2+1][n][mantissa_width-1:0]};
    end

    // Use packed multipliers and DSP to multiply mantissas
    packed_multiplier #(
        .op_width(mantissa_width + 1),
        .mul_width(mul_width)
    ) pm_a (
        .clk(clk),
        .operands(mantissas_a),
        .sharedOperand(shared_mantissa_a), 
        .products(mantissa_products_a),
        .mul_x(ax),
        .mul_y(ay),
        .mul_result(resulta)
    );
    packed_multiplier #(
        .op_width(mantissa_width + 1),
        .mul_width(mul_width)
    ) pm_b (
        .clk(clk),
        .operands(mantissas_b),
        .sharedOperand(shared_mantissa_b), 
        .products(mantissa_products_b),
        .mul_x(bx),
        .mul_y(by),
        .mul_result(resultb)
    );
    DSP_2x18x18 dsp_inst (
        .ax(ax),
        .ay(ay),
        .bx(bx),
        .by(by),
        .resulta(resulta),
        .resultb(resultb),
        .clk(clk)
    );

    // Add exponents (subnormals use effective exponent of 1)
    for (genvar n = 0; n < num_ops; n++) begin
        always_comb begin
            exponent_sums_a[n] = (is_normal_a[n] ? operands[i*2][n][exponent_width+mantissa_width-1:mantissa_width] : 1)
                + (shared_is_normal_a ? sharedOperands[i*2][exponent_width+mantissa_width-1:mantissa_width] : 1);
            exponent_sums_b[n] = (is_normal_b[n] ? operands[i*2+1][n][exponent_width+mantissa_width-1:mantissa_width] : 1)
                + (shared_is_normal_b ? sharedOperands[i*2+1][exponent_width+mantissa_width-1:mantissa_width] : 1);
        end
    end

    // Convert to fixed point
    for (genvar n = 0; n < num_ops; n++) begin
        always_comb begin
            // shift left mantissa by exponent
            fixed_point_products[i*2][n] = fixed_point_product_width'(mantissa_products_a[n]) << exponent_sums_a[n];
            fixed_point_products[i*2+1][n] = fixed_point_product_width'(mantissa_products_b[n]) << exponent_sums_b[n];
            // handle sign
            if (operands[i*2][n][exponent_width+mantissa_width] ^ sharedOperands[i*2][exponent_width+mantissa_width]) begin
                fixed_point_products[i*2][n] = -fixed_point_products[i*2][n];
            end
            if (operands[i*2+1][n][exponent_width+mantissa_width] ^ sharedOperands[i*2+1][exponent_width+mantissa_width]) begin
                fixed_point_products[i*2+1][n] = -fixed_point_products[i*2+1][n];
            end
        end
    end

end

// REDUCTION TREE
for (genvar i = 0; i < num_ops; i++) begin

    logic [fixed_point_result_width*block_size-1:0] din_packed;
    for (genvar j = 0; j < block_size; j++) begin
        // Sign-extend fixed_point_products to match fixed_point_result_width
        assign din_packed[j*fixed_point_result_width +: fixed_point_result_width] = 
            {{(fixed_point_result_width - fixed_point_product_width){fixed_point_products[j][i][fixed_point_product_width-1]}}, fixed_point_products[j][i]};
    end
    
    reduction #(
        .DW(fixed_point_result_width),
        .L(1),
        .N(block_size)
    ) red_inst (
        .din(din_packed),
        .dout(results[i]),
        .valid_in(1'b1),
        .valid_out(),
        .clk(clk),
        .rst(1'b0)
    );

end

endmodule