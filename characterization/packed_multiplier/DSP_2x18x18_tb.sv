`timescale 1ns / 1ps

module DSP_2x18x18_tb;

// Parameters
parameter TESTS = 1024;  // Number of tests

// DUT signals
logic clk;
logic [17:0] ax, ay, bx, by;
logic [35:0] resulta, resultb;

// Instantiate DUT
DSP_2x18x18 dut (
    .clk(clk),
    .ax(ax),
    .ay(ay),
    .bx(bx),
    .by(by),
    .resulta(resulta),
    .resultb(resultb)
);

// Clock generation
initial begin
    clk = 0;
    forever #(10 / 2) clk = ~clk;
end

// Test stimulus
initial begin

    $display("!!!DUT=DSP_2x18x18");
    $display("tests=%0d", TESTS);

    // Run N random tests
    for (int i = 0; i < TESTS; i++) begin
        // Generate random inputs
        ax = $random;
        ay = $random;
        bx = $random;
        by = $random;
        #10;  // Wait one clock cycle

        $display("test=%0d", i);
        $display("ax=%b", ax);
        $display("ay=%b", ay);
        $display("bx=%b", bx);
        $display("by=%b", by);
        $display("resulta=%b", resulta);
        $display("resultb=%b", resultb);
    end

    $finish;
end

endmodule