`timescale 1ns/1ns

module fp32_to_mxfp_tb;

parameter tests = 256;
parameter EXPONENT_WIDTH = 4;
parameter MANTISSA_WIDTH = 3;
parameter BLOCK_SIZE = 32;
parameter FREQ_MHZ = 400;
parameter BIT_WIDTH = 1 + EXPONENT_WIDTH + MANTISSA_WIDTH;

logic clk;
logic valid_in, valid_out;
logic [31:0] in [BLOCK_SIZE];
logic [BIT_WIDTH-1:0] out [BLOCK_SIZE];
logic [7:0] out_blk_exp;

fp32_to_mxfp #(
    .exponent_width(EXPONENT_WIDTH),
    .mantissa_width(MANTISSA_WIDTH),
    .block_size(BLOCK_SIZE),
    .freq_mhz(FREQ_MHZ)
) dut (
    .clk(clk),
    .valid_in(valid_in),
    .valid_out(valid_out),
    .in(in),
    .out(out),
    .out_blk_exp(out_blk_exp)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Input queue to pair inputs with their outputs
typedef struct {
    int test_num;
    logic [31:0] ins [BLOCK_SIZE];
} test_entry_t;
test_entry_t fifo [$];

// Generate random FP32 that is a valid number (no NaN/Inf)
function logic [31:0] rand_fp32();
    logic [31:0] val;
    logic [7:0] exp;
    val[31]    = $urandom_range(0, 1);  // sign
    exp        = $urandom_range(0, 254); // exponent: avoid 255 (NaN/Inf)
    val[30:23] = exp;
    val[22:0]  = $urandom;              // mantissa
    return val;
endfunction

// Drive inputs
initial begin
    $display("!!!DUT=fp32_to_mxfp");
    $display("EXPONENT_WIDTH=%0d", EXPONENT_WIDTH);
    $display("MANTISSA_WIDTH=%0d", MANTISSA_WIDTH);
    $display("BLOCK_SIZE=%0d", BLOCK_SIZE);
    $display("tests=%0d", tests);

    valid_in = 0;
    @(posedge clk);
    for (int t = 0; t < tests; t++) begin
        @(posedge clk);
        valid_in <= 1;
        for (int i = 0; i < BLOCK_SIZE; i++) begin
            in[i] = rand_fp32();
        end
        // Capture driven values at negedge
        @(negedge clk);
        begin
            test_entry_t entry;
            entry.test_num = t;
            entry.ins = in;
            fifo.push_back(entry);
        end
    end
    @(posedge clk);
    valid_in <= 0;
end

// Collect outputs
initial begin
    int checks_done;
    test_entry_t test_entry;
    checks_done = 0;
    forever begin
        @(posedge clk);
        if (valid_out) begin
            test_entry = fifo.pop_front();
            $display("test=%0d", test_entry.test_num);
            for (int i = 0; i < BLOCK_SIZE; i++) begin
                $display("in[%0d]=%b", i, test_entry.ins[i]);
            end
            $display("out_blk_exp=%b", out_blk_exp);
            for (int i = 0; i < BLOCK_SIZE; i++) begin
                $display("out[%0d]=%b", i, out[i]);
            end
            checks_done++;
            if (checks_done == tests) $finish;
        end
    end
end

endmodule
