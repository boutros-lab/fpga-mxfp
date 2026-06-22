`timescale 1ns/1ns

module packed_dot_product_tb;
parameter tests = 1024;
parameter exponent_width = 4;
parameter mantissa_width = 3;
parameter mul_width = 18;
parameter block_size = 32;
localparam num_ops = (mul_width / (1+mantissa_width)) - (mul_width / (2*(1+mantissa_width)));
localparam result_width = 1 + 2 * (mantissa_width + 1) + 2 ** (exponent_width + 1) - 2 + $clog2(block_size);

logic clk;
logic [1 + mantissa_width + exponent_width -1:0] operands [block_size-1:0][num_ops-1:0], sharedOperands [block_size-1:0];
logic [result_width-1:0] results [num_ops-1:0];
logic valid_in, valid_out;

packed_dot_product #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) pdp (
    .clk(clk),
    .operands(operands),
    .sharedOperands(sharedOperands),
    .results(results),
    .valid_in(valid_in),
    .valid_out(valid_out)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Input queue to pair inputs with their outputs
typedef struct {
    int test_num;
    logic [1 + mantissa_width + exponent_width -1:0] ops [block_size-1:0][num_ops-1:0];
    logic [1 + mantissa_width + exponent_width -1:0] shared [block_size-1:0];
} test_entry_t;
test_entry_t fifo [$];

// Drive inputs: one test per clock cycle
initial begin
    // DUT identifier and parameters
    $display("!!!DUT=packed_dot_product");
    $display("mantissa_width=%0d", mantissa_width);
    $display("exponent_width=%0d", exponent_width);
    $display("num_ops=%0d", num_ops);
    $display("block_size=%0d", block_size);
    $display("tests=%0d", tests);
    // Start with invalid and then drive inputs
    valid_in = 0;
    @(posedge clk);
    for (int t = 0; t < tests; t++) begin
        @(posedge clk);
        valid_in <= 1;
        for (int i = 0; i < block_size; i++) begin
            sharedOperands[i] = $random;
            for (int j = 0; j < num_ops; j++) begin
                operands[i][j] = $random;
            end
        end
        // Capture driven values at negedge
        @(negedge clk);
        begin
            test_entry_t entry;
            entry.test_num = t;
            entry.ops = operands;
            entry.shared = sharedOperands;
            fifo.push_back(entry);
        end
    end
    @(posedge clk);
    valid_in <= 0;
end

// Start displaying to transcript when valid_out becomes high
initial begin
    int checks_done;
    test_entry_t test_entry;
    checks_done = 0;
    forever begin
        @(posedge clk);
        if (valid_out) begin
            test_entry = fifo.pop_front();
            $display("test=%0d", test_entry.test_num);
            for (int i = 0; i < block_size; i++) begin
                $display("sharedOperand[%0d]=%b", i, test_entry.shared[i]);
                for (int j = 0; j < num_ops; j++) begin
                    $display("operand[%0d][%0d]=%b", i, j, test_entry.ops[i][j]);
                end
            end
            for (int i = 0; i < num_ops; i++) begin
                $display("result[%0d]=%b", i, results[i]);
            end
            checks_done++;
            if (checks_done == tests) $finish;
        end
    end
end

endmodule
