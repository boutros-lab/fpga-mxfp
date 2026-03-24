`timescale 1ns/1ns

module packed_dot_product_fp32_tb;
parameter exponent_width = 5;
parameter mantissa_width = 2;
parameter mul_width = 18;
parameter block_size = 32;
localparam num_ops = mul_width / 2 / (1+mantissa_width);

logic clk;
logic valid_in, valid_out;
logic [1 + mantissa_width + exponent_width -1:0] operands [block_size-1:0][num_ops-1:0], sharedOperands [block_size-1:0];
logic [7:0] block_exponent [num_ops-1:0];
logic [7:0] sharedBlock_exponent;
logic [31:0] results [num_ops-1:0];
packed_dot_product_fp32 #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) dut (
    .clk(clk),
    .valid_in(valid_in),
    .valid_out(valid_out),
    .operands(operands),
    .sharedOperands(sharedOperands),
    .block_exponent(block_exponent),
    .sharedBlock_exponent(sharedBlock_exponent),
    .results(results)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

parameter num_tests = 128;

// Input queue to pair inputs with their outputs
typedef struct {
    int test_num;
    logic [1 + mantissa_width + exponent_width -1:0] ops [block_size-1:0][num_ops-1:0];
    logic [1 + mantissa_width + exponent_width -1:0] shared [block_size-1:0];
    logic [7:0] blk_exp [num_ops-1:0];
    logic [7:0] shared_blk_exp;
} test_entry_t;
test_entry_t fifo [$];

// Drive inputs: one test per clock cycle
initial begin
    $display("!!!DUT=packed_dot_product_fp32");
    $display("mantissa_width=%0d", mantissa_width);
    $display("exponent_width=%0d", exponent_width);
    $display("num_ops=%0d", num_ops);
    $display("block_size=%0d", block_size);
    $display("tests=%0d", num_tests);

    valid_in <= 0;
    sharedBlock_exponent <= 0;
    for (int j = 0; j < num_ops; j++) begin
        block_exponent[j] <= 0;
    end
    for (int i = 0; i < block_size; i++) begin
        sharedOperands[i] <= 1;
        for (int j = 0; j < num_ops; j++) begin
            operands[i][j] <= 0;
        end
    end

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    for (int t = 0; t < num_tests; t++) begin
        @(posedge clk);
        valid_in <= 1;
        sharedBlock_exponent <= $random;
        for (int j = 0; j < num_ops; j++) begin
            block_exponent[j] <= $random;
        end
        for (int i = 0; i < block_size; i++) begin
            sharedOperands[i] <= $random;
            for (int j = 0; j < num_ops; j++) begin
                operands[i][j] <= $random;
            end
        end

        // Capture driven values at negedge
        @(negedge clk);
        begin
            test_entry_t entry;
            entry.test_num = t;
            entry.ops = operands;
            entry.shared = sharedOperands;
            entry.blk_exp = block_exponent;
            entry.shared_blk_exp = sharedBlock_exponent;
            fifo.push_back(entry);
        end
    end

    @(posedge clk);
    valid_in <= 0;
end

// Collect outputs when valid_out asserts, print in check.py format
initial begin
    int checks_done;
    test_entry_t e;
    checks_done = 0;

    forever begin
        @(posedge clk);
        if (valid_out) begin
            e = fifo.pop_front();
            $display("test=%0d", e.test_num);
            $display("sharedBlock_exponent=%b", e.shared_blk_exp);
            for (int j = 0; j < num_ops; j++) begin
                $display("block_exponent[%0d]=%b", j, e.blk_exp[j]);
            end
            for (int i = 0; i < block_size; i++) begin
                $display("sharedOperand[%0d]=%b", i, e.shared[i]);
                for (int j = 0; j < num_ops; j++) begin
                    $display("operand[%0d][%0d]=%b", i, j, e.ops[i][j]);
                end
            end
            for (int i = 0; i < num_ops; i++) begin
                $display("result[%0d]=%b", i, results[i]);
            end
            checks_done++;
            if (checks_done == num_tests) $finish;
        end
    end
end

endmodule
