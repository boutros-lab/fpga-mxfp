module packed_multiplier #(
    parameter width = 3,
    parameter number = 18 / 2 / width
) (
    input logic clk,
    input logic rst,
    input logic [width-1:0] operands [number-1:0],
    input logic [width-1:0] sharedOperand,
    output logic [2*width-1:0] products [number-1:0]
);
generate

wire [17:0] operandA; 
wire [17:0] operandB;
reg [35:0] result_reg;

// 18 x 18
// width = 3
// XXXAAAXXXBBBXXXCCC
// XXXXXXXXXXXXXXXSSS
// XXXXXXAAAAAAXXXXXXBBBBBBXXXXXXCCCCCC
// width = 2
// XXXXAAXXBBXXCCXXDD
// XXXXXXXXXXXXXXXXSS
// XXXXXXXXAAAAXXXXBBBBXXXXCCCCXXXXDDDD

for (genvar i = 0; i < number; i++) begin : gen_operand_packing
    assign operandA[i * 2 * width +: width] = operands[i]; // place operand
    assign operandA[i * 2 * width + width +: width] = {(width){1'b0}}; // pad other half with zeros
    assign products[i] = result_reg[i * 2 * width +: 2 * width]; // extract product
end
if (number * 2 * width < 18) begin
    assign operandA[number * 2 * width +: (18 - number * 2 * width)] = {(18 - number * 2 * width){1'b0}}; // pad rest with zeros
end
assign operandB[0 +: width] = sharedOperand; // place shared operand
assign operandB[width +: (18 - width)] = {(18 - width){1'b0}}; // pad rest with zeros

always_ff @(posedge clk) begin
    if (rst) begin
        result_reg <= 36'b0; // reset result register
    end else begin
        result_reg <= operandA * operandB; // perform multiplication
    end
end

endgenerate
endmodule