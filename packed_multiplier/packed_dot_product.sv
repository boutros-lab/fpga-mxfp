module packed_dot_product #(
    parameter 
    parameter op_width = 3,
    parameter mul_width = 18,
    parameter is_registered = 0,
    localparam num_ops = mul_width / 2 / op_width,
    parameter length = 4 // must be divisible by 2 since the DSP can handle 2 multiplications at once
) (
    input logic clk,
    input logic [op_width-1:0] operands [num_ops-1:0] [length-1:0], sharedOperands [length-1:0],
    output logic [2*op_width + $clog2(length) -1:0] dot_product [length-1:0]
);

    // Instantiate packed multipliers and accumulate results
    for (genvar i = 0; i < length/2; i++) begin : gen_dot_product
        logic [2*op_width-1:0] products [num_ops-1:0];
        packed_multiplier #(
            .op_width(op_width),
            .mul_width(mul_width),
            .is_registered(is_registered)
        ) pm_a (
            .clk(clk),
            .operands(operands[:,i]),
            .sharedOperand(sharedOperands[i]), // assuming shared operand is the first one
            .products(products)
        );
        packed_multiplier #(
            .op_width(op_width),
            .mul_width(mul_width),
            .is_registered(is_registered)
        ) pm_b (
            .clk(clk),
            .operands(operands[:,i]),
            .sharedOperand(sharedOperands[i]), // assuming shared operand is the first one
            .products(products)
        );

        // Accumulate products to get dot product
        logic [2*op_width + $clog2(num_ops) -1:0] sum;
        always_comb begin
            sum = '0;
            for (int j = 0; j < num_ops; j++) begin
                sum += products[j];
            end
        end

        // Assign to output with appropriate width
        assign dot_product[i] = sum;
    end

    
endmodule