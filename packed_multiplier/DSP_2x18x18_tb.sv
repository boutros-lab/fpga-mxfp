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

        // Run N random tests
        for (int i = 0; i < TESTS; i++) begin
            // Generate random inputs
            ax = $random;
            ay = $random;
            bx = $random;
            by = $random;
            #10;  // Wait one clock cycle (assuming 1-cycle latency)

            // Check results
            if (resulta !== ax * bx) begin
                $display("Test %da FAILED (p1): ax=%d, bx=%d, expected=%d, got=%d", i, ax, bx, ax * bx, resulta);
            end else begin
                //$display("Test %da PASSED (p1): ax=%d, bx=%d, resulta=%d", i, ax, bx, resulta);
            end
            if (resultb !== ay * by) begin
                $display("Test %db FAILED (p2): ay=%d, by=%d, expected=%d, got=%d", i, ay, by, ay * by, resultb);
            end else begin
                //$display("Test %db PASSED (p2): ay=%d, by=%d, resultb=%d", i, ay, by, resultb);
            end
        end

        // End simulation
        $display("All tests completed.");
        $finish;
    end

endmodule