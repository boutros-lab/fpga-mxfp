module packed_dot_product #(
    parameter exponent_width = 4,
    parameter mantissa_width = 3,
    parameter mul_width = 18,
    parameter block_size = 32, // must be divisible by 2 since the DSP can handle 2 multiplications at once
    localparam num_ops = (mul_width / (1+mantissa_width)) - (mul_width / (2*(1+mantissa_width))), 
    // Sign + Mantissa_Multiplied + Max_Exponent_Sum_Shift + Block_Sum
    localparam fixed_point_product_width = 1 + 2 * (mantissa_width + 1) + 2 ** (exponent_width + 1) - 2,
    localparam result_width = fixed_point_product_width + $clog2(block_size)
) (
    input logic clk,
    // NOTE: operands are a sequence of block-length vectors
    input logic [1 + mantissa_width + exponent_width -1:0] operands [block_size-1:0][num_ops-1:0], sharedOperands [block_size-1:0],
    // output size is 1 + 2(M+1) + 2^(E+1) + log2(B)
    output logic [result_width-1:0] results [num_ops-1:0],
    input logic valid_in,
    output logic valid_out
);

    // MULTIPLY AND CONVERT TO FIXED POINT
    logic [fixed_point_product_width-1:0] fixed_point_products [block_size-1:0][num_ops-1:0];

    // DSP has two independent multiplier inputs, so we can process two rows of the block at once
    for (genvar i = 0; i < block_size/2; i++) begin

        // EXTRACT EXPONENTS
        logic [exponent_width-1:0] exponents_a [num_ops-1:0], exponents_b [num_ops-1:0], shared_exponent_a , shared_exponent_b;
        assign shared_exponent_a = sharedOperands[i*2][exponent_width+mantissa_width-1:mantissa_width];
        assign shared_exponent_b = sharedOperands[i*2+1][exponent_width+mantissa_width-1:mantissa_width];
        for (genvar n = 0; n < num_ops; n++) begin
            assign exponents_a[n] = operands[i*2][n][exponent_width+mantissa_width-1:mantissa_width];
            assign exponents_b[n] = operands[i*2+1][n][exponent_width+mantissa_width-1:mantissa_width];
        end

        // EXTRACT MANTISSAS 
        logic [mantissa_width:0] mantissas_a [num_ops-1:0], mantissas_b [num_ops-1:0], shared_mantissa_a , shared_mantissa_b;
        // Subnormal handling: if exponent is 0, the first bit of the mantissa is 0 instead of 1. 
        assign shared_mantissa_a = {shared_exponent_a != 0, sharedOperands[i*2][mantissa_width-1:0]};
        assign shared_mantissa_b = {shared_exponent_b != 0, sharedOperands[i*2+1][mantissa_width-1:0]};
        for (genvar n = 0; n < num_ops; n++) begin
            assign mantissas_a[n] = {exponents_a[n] != 0, operands[i*2][n][mantissa_width-1:0]};
            assign mantissas_b[n] = {exponents_b[n] != 0, operands[i*2+1][n][mantissa_width-1:0]};
        end

        // ADD EXPONENTS
        logic [exponent_width:0] exponent_sums_a [num_ops-1:0], exponent_sums_b [num_ops-1:0];
        // Subnormals use effective exponent of 1
        for (genvar n = 0; n < num_ops; n++) begin
            assign exponent_sums_a[n] = (exponents_a[n] != 0 ? exponents_a[n] : 1) + (shared_exponent_a != 0 ? shared_exponent_a : 1);
            assign exponent_sums_b[n] = (exponents_b[n] != 0 ? exponents_b[n] : 1) + (shared_exponent_b != 0 ? shared_exponent_b : 1);
        end

        // MULTIPLY MANTISSAS
        logic [2*(mantissa_width + 1)-1:0] mantissa_products_a [num_ops-1:0], mantissa_products_b [num_ops-1:0];
        // Connections to DSP
        logic [17:0] ax, ay, bx, by;
        logic [35:0] resulta, resultb;
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

        // CONVERT TO FIXED POINT
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

    // REDUCE BLOCK OF FIXED POINT PRODUCTS
    for (genvar i = 0; i < num_ops; i++) begin : gen_reduce
        // pack fixed_point_products into a single vector for reduction
        logic [result_width*block_size-1:0] din_packed;
        for (genvar j = 0; j < block_size; j++) begin
            // Sign-extend fixed_point_products to match result_width
            assign din_packed[j*result_width +: result_width] = 
                {{(result_width - fixed_point_product_width){fixed_point_products[j][i][fixed_point_product_width-1]}}, fixed_point_products[j][i]};
        end
        logic red_valid_out;
        reduction #(
            .DW(result_width),
            .L(1),
            .N(block_size)
        ) red_inst (
            .din(din_packed),
            .dout(results[i]),
            .valid_in(valid_in),
            .valid_out(red_valid_out),
            .clk(clk),
            .rst(1'b0)
        );
    end

    // HANDLE VALID SIGNALS
    // multiplier is combinatinal, so valid signals connect straight to the reduction unit
    // connect to the first reduction unit only to avoid redundant drivers
    assign valid_out = gen_reduce[0].red_valid_out;

endmodule
