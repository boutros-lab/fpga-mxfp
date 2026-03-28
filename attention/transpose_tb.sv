`timescale 1ns/1ns

module transpose_tb;

parameter tests = 1024;
parameter INPUT_ROWS = 2;
parameter INPUT_COLS = 4;
parameter DATA_WIDTH = 8;

logic clk;
logic valid_in, valid_out;
logic [DATA_WIDTH-1:0] in_data [INPUT_ROWS][INPUT_COLS];
logic [DATA_WIDTH-1:0] out_data [INPUT_COLS][INPUT_ROWS];

transpose #(
    .ROWS(INPUT_ROWS),
    .COLS(INPUT_COLS),
    .DATA_WIDTH(DATA_WIDTH)
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
    logic [DATA_WIDTH-1:0] ins [INPUT_ROWS][INPUT_COLS];
} test_entry_t;
test_entry_t fifo [$];

// Drive inputs: one test per clock cycle
initial begin
    $display("!!!DUT=transpose");
    $display("INPUT_ROWS=%0d", INPUT_ROWS);
    $display("INPUT_COLS=%0d", INPUT_COLS);
    $display("DATA_WIDTH=%0d", DATA_WIDTH);
    $display("tests=%0d", tests);

    valid_in = 0;
    @(posedge clk);
    for (int t = 0; t < tests; t++) begin
        @(posedge clk);
        valid_in <= 1;
        for (int i = 0; i < INPUT_ROWS; i++) begin
            for (int j = 0; j < INPUT_COLS; j++) begin
                in_data[i][j] = $random;
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

// Collect outputs when they appear (1-cycle latency)
initial begin
    int checks_done;
    test_entry_t test_entry;
    checks_done = 0;
    forever begin
        @(posedge clk);
        if (valid_out) begin
            test_entry = fifo.pop_front();
            $display("test=%0d", test_entry.test_num);
            for (int i = 0; i < INPUT_ROWS; i++) begin
                for (int j = 0; j < INPUT_COLS; j++) begin
                    $display("in_data[%0d][%0d]=%b", i, j, test_entry.ins[i][j]);
                end
            end
            for (int i = 0; i < INPUT_COLS; i++) begin
                for (int j = 0; j < INPUT_ROWS; j++) begin
                    $display("out_data[%0d][%0d]=%b", i, j, out_data[i][j]);
                end
            end
            checks_done++;
            if (checks_done == tests) $finish;
        end
    end
end

endmodule
