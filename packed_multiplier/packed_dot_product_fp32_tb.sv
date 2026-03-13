`timescale 1ns/1ns

module packed_dot_product_fp32_tb;
parameter exponent_width = 5;
parameter mantissa_width = 2;
parameter mul_width = 18;
parameter block_size = 32;
localparam num_ops = mul_width / 2 / (1+mantissa_width);

logic clk;
logic [1 + mantissa_width + exponent_width -1:0] operands [block_size-1:0][num_ops-1:0], sharedOperands [block_size-1:0];
logic [7:0] shared_exponent [num_ops-1:0];
logic [31:0] results [num_ops-1:0];
packed_dot_product_fp32 #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) dut (
    .clk(clk),
    .operands(operands),
    .sharedOperands(sharedOperands),
    .shared_exponent(shared_exponent),
    .results(results)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

parameter num_tests = 100;

initial begin

    $display("!!!DUT=packed_dot_product_fp32");
    $display("mantissa_width=%0d", mantissa_width);
    $display("exponent_width=%0d", exponent_width);
    $display("num_ops=%0d", num_ops);
    $display("block_size=%0d", block_size);
    $display("tests=%0d", num_tests);

    for (int t = 0; t < num_tests; t++) begin
        for (int j = 0; j < num_ops; j++) begin
            shared_exponent[j] = 8'b1000000;
        end
        for (int i = 0; i < block_size; i++) begin
            sharedOperands[i] = $urandom;
            for (int j = 0; j < num_ops; j++) begin
                operands[i][j] = $urandom;
            end
        end

        // Wait for packed_dot_product (5 cycles) + converter pipeline (11 cycles for E4M3)
        #200;

        $display("test=%0d", t);
        for (int j = 0; j < num_ops; j++) begin
            $display("shared_exponent[%0d]=%b", j, shared_exponent[j]);
        end

        for (int i = 0; i < block_size; i++) begin
            $display("sharedOperand[%0d]=%b", i, sharedOperands[i]);
            for (int j = 0; j < num_ops; j++) begin
                $display("operand[%0d][%0d]=%b", i, j, operands[i][j]);
            end
        end

        for (int i = 0; i < num_ops; i++) begin
            $display("result[%0d]=%b", i, results[i]);
        end
    end

    $finish;

end

endmodule
