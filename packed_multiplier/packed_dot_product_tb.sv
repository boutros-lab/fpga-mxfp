`timescale 1ns/1ns

module packed_dot_product_tb;
parameter exponent_width = 4;
parameter mantissa_width = 3;
parameter mul_width = 18;
parameter block_size = 32;
localparam num_ops = mul_width / 2 / (1+mantissa_width);
localparam fixed_point_width = 1 + 2 * (mantissa_width + 1) + 2 ** (exponent_width + 1) + $clog2(block_size);

logic clk;
logic [1 + mantissa_width + exponent_width -1:0] operands [block_size-1:0][num_ops-1:0], sharedOperands [block_size-1:0];
logic [fixed_point_width-1:0] results [num_ops-1:0];
packed_dot_product #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) pdp (
    .clk(clk),
    .operands(operands),
    .sharedOperands(sharedOperands),
    .results(results)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    
    // Initialize inputs
    for (int i = 0; i < block_size; i++) begin
        sharedOperands[i] = $random % (1 << (1 + mantissa_width + exponent_width));
        for (int j = 0; j < num_ops; j++) begin
            operands[i][j] = $random % (1 << (1 + mantissa_width + exponent_width));
        end
    end

    #100;

    $display("!!!START!!!");

    $display("mantissa_width=%0d", mantissa_width);
    $display("exponent_width=%0d", exponent_width);
    $display("num_ops=%0d", num_ops);
    $display("block_size=%0d", block_size);

    for (int i = 0; i < block_size; i++) begin
        $display("sharedOperand[%0d]=%b", i, sharedOperands[i]);
        for (int j = 0; j < num_ops; j++) begin
            $display("operand[%0d][%0d]=%b", i, j, operands[i][j]);
        end
    end

    for (int i = 0; i < num_ops; i++) begin
        $display("result[%0d]=%b", i, results[i]);
    end

    $finish;

end

endmodule