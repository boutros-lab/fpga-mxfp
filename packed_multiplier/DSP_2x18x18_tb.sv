`timescale 1ns / 1ps

module DSP_2x18x18_tb;

    // Parameters
    parameter TESTS = 1024;  // Number of tests

    // DUT signals
    logic clk;
    logic [17:0] ax, ay, bx, by;
    logic [35:0] expected_resulta, expected_resultb;
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

            expected_resulta = ax * ay;
            expected_resultb = bx * by;

            // Check results
            if (resulta !== expected_resulta) begin
                $display("Test %da FAILED (p1): ax=%d, ay=%d, expected=%d, got=%d", i, ax, ay, expected_resulta, resulta);
            end else begin
                //$display("Test %da PASSED (p1): ax=%d, ay=%d, resulta=%d", i, ax, ay, resulta);
            end
            if (resultb !== expected_resultb) begin
                $display("Test %db FAILED (p2): bx=%d, by=%d, expected=%d, got=%d", i, bx, by, expected_resultb, resultb);
            end else begin
                //$display("Test %db PASSED (p2): bx=%d, by=%d, resultb=%d", i, bx, by, resultb);
            end
        end

        // End simulation
        $display("All tests completed.");
        $finish;
    end

endmodule