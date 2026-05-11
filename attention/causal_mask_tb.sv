`timescale 1ns/1ns

module causal_mask_tb;

parameter tests = 256;
parameter N = 8;

logic clk;
logic valid_in, valid_out;
logic [31:0] in_data  [N][N];
logic [31:0] out_data [N][N];

causal_mask #(
    .N(N)
) dut (
    .clk(clk),
    .valid_in(valid_in),
    .valid_out(valid_out),
    .in_data(in_data),
    .out_data(out_data)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Input queue to pair inputs with their outputs
typedef struct {
    int test_num;
    logic [31:0] ins [N][N];
} test_entry_t;
test_entry_t fifo [$];

// Generate random FP32 that is a valid number (no NaN/Inf)
function logic [31:0] rand_fp32();
    logic [31:0] val;
    logic [7:0] exp;
    val[31]    = $urandom_range(0, 1);
    exp        = $urandom_range(0, 254);
    val[30:23] = exp;
    val[22:0]  = $urandom;
    return val;
endfunction

// Drive inputs
initial begin
    $display("!!!DUT=causal_mask");
    $display("N=%0d", N);
    $display("tests=%0d", tests);

    valid_in = 0;
    @(posedge clk);
    for (int t = 0; t < tests; t++) begin
        @(posedge clk);
        valid_in <= 1;
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                in_data[i][j] = rand_fp32();
            end
        end
        // Capture driven values at negedge
        @(negedge clk);
        begin
            test_entry_t entry;
            entry.test_num = t;
            entry.ins = in_data;
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
            for (int i = 0; i < N; i++) begin
                for (int j = 0; j < N; j++) begin
                    $display("in[%0d][%0d]=%b", i, j, test_entry.ins[i][j]);
                end
            end
            for (int i = 0; i < N; i++) begin
                for (int j = 0; j < N; j++) begin
                    $display("out[%0d][%0d]=%b", i, j, out_data[i][j]);
                end
            end
            checks_done++;
            if (checks_done == tests) $finish;
        end
    end
end

endmodule
