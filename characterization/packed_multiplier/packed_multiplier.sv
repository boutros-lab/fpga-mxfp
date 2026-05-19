module packed_multiplier # (
    parameter op_width = 3,
    parameter mul_width = 18,
    localparam num_ops = mul_width / 2 / op_width
) (
    input logic clk,
    input logic [op_width-1:0] operands [num_ops-1:0], sharedOperand,
    output logic [2*op_width-1:0] products [num_ops-1:0],
    output logic [mul_width-1:0] mul_x, mul_y,
    input logic [2 * mul_width-1:0] mul_result
);

// Pack and unpack operands and products
for (genvar i = 0; i < num_ops; i++) begin : gen_operand_packing
    assign mul_x[i * 2 * op_width +: op_width] = operands[i]; // place operand
    assign mul_x[i * 2 * op_width + op_width +: op_width] = {(op_width){1'b0}}; // pad other half with zeros
    assign products[i] = mul_result[i * 2 * op_width +: 2 * op_width]; // extract product
end
if (num_ops * 2 * op_width < mul_width) // pad remaining bits with zeros
    assign mul_x[num_ops * 2 * op_width +: (mul_width - num_ops * 2 * op_width)] = {(mul_width - num_ops * 2 * op_width){1'b0}};
assign mul_y[0 +: op_width] = sharedOperand; // place shared operand
assign mul_y[op_width +: (mul_width - op_width)] = {(mul_width - op_width){1'b0}}; // pad rest with zeros

endmodule