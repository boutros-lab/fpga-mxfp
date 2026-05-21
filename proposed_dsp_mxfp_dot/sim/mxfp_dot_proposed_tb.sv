// //////////////////////////////////////////////////////////////////////////////////////
// Testbench: mxfp_dot_proposed_tb
// DUT: mxfp_dot_proposed
//
// Description:
// Testbench to verify the `mxfp_dot_proposed` module by loading in `NUM_LOADS` sets of vectors 
// followed by streaming in `REUSE_FACTOR` vectors.
//
// //////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

import pkg_aitb::*;
module mxfp_dot_proposed_tb;

    // -----------------------------------------------------------------
    // Parameters
    // -----------------------------------------------------------------
    // See `systolic_array/syn/setup_24_2_mxfp_dot_prop.tcl` for correspondance between MXFP format and MODE_INT value.
    parameter  MODE_INT = 4;
    localparam bit IS_SIM  = 1;
    parameter  bit IS_DOT4 = 1;
    parameter  EXP_W          = 5;
    parameter  MAN_W          = 2;
    localparam DATA_MX_W      = 1 + MAN_W + EXP_W;
    localparam SHARED_EXP_W   = 8;
    localparam DOT_LEN        = 32;
    localparam DATA_OUT_W     = 32;

    localparam NUM_LOADS      = 2;     // Weight-load phases
    localparam REUSE_FACTOR   = 5;     // Activation vectors per load

    // -----------------------------------------------------------------
    // Stimulus / golden storage
    // Here, we generate the test vectors and the outputs using a "SW" golden model.
    // -----------------------------------------------------------------
    // Col1 weights (loaded second into PE, produces col1 output)
    shortreal w1_vec_real [0:NUM_LOADS-1][0:DOT_LEN-1];
    // Col2 weights (loaded first into PE, produces col2 output)
    shortreal w2_vec_real [0:NUM_LOADS-1][0:DOT_LEN-1];
    // The activations (vectors "dotted" with the weights)
    shortreal x_vec_real  [0:NUM_LOADS-1][0:REUSE_FACTOR-1][0:DOT_LEN-1];

    shortreal dot_gold_col1_real [0:NUM_LOADS-1][0:REUSE_FACTOR-1];
    shortreal dot_gold_col2_real [0:NUM_LOADS-1][0:REUSE_FACTOR-1];

    logic [DATA_MX_W-1:0]    w1_vec_mem       [0:NUM_LOADS-1][0:DOT_LEN-1];
    logic [DATA_MX_W-1:0]    w2_vec_mem       [0:NUM_LOADS-1][0:DOT_LEN-1];
    logic [DATA_MX_W-1:0]    x_vec_mem        [0:NUM_LOADS-1][0:REUSE_FACTOR-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] w1_shared_exp    [0:NUM_LOADS-1];
    logic [SHARED_EXP_W-1:0] w2_shared_exp    [0:NUM_LOADS-1];
    logic [SHARED_EXP_W-1:0] x_shared_exp     [0:NUM_LOADS-1][0:REUSE_FACTOR-1];

    logic [DATA_OUT_W-1:0]   gold_col1_bits   [0:NUM_LOADS-1][0:REUSE_FACTOR-1];
    logic [DATA_OUT_W-1:0]   gold_col2_bits   [0:NUM_LOADS-1][0:REUSE_FACTOR-1];

    // -----------------------------------------------------------------
    // Data generation
    // -----------------------------------------------------------------
    logic gen_done;
    integer ld, rv, k;
    initial begin : DATA_GEN
        gen_done = 1'b0;

        // Clear
        for (ld = 0; ld < NUM_LOADS; ld = ld + 1) begin
            w1_shared_exp[ld] = '0;
            w2_shared_exp[ld] = '0;
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                w1_vec_mem[ld][k]  = '0;
                w1_vec_real[ld][k] = 0.0;
                w2_vec_mem[ld][k]  = '0;
                w2_vec_real[ld][k] = 0.0;
            end
        end
        for (ld = 0; ld < NUM_LOADS; ld = ld + 1) begin
            for (rv = 0; rv < REUSE_FACTOR; rv = rv + 1) begin
                x_shared_exp[ld][rv] = '0;
                for (k = 0; k < DOT_LEN; k = k + 1) begin
                    x_vec_mem[ld][rv][k]  = '0;
                    x_vec_real[ld][rv][k] = 0.0;
                end
                dot_gold_col1_real[ld][rv] = 0.0;
                dot_gold_col2_real[ld][rv] = 0.0;
                gold_col1_bits[ld][rv]     = '0;
                gold_col2_bits[ld][rv]     = '0;
            end
        end

        // Generate col1 weights (one vector per load)
        for (ld = 0; ld < NUM_LOADS; ld = ld + 1) begin
            w1_shared_exp[ld] = 8'd127;
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                w1_vec_mem[ld][k]  = $random;
                w1_vec_real[ld][k] = to_fp32(int'(w1_vec_mem[ld][k]));
            end
        end

        // Generate col2 weights
        for (ld = 0; ld < NUM_LOADS; ld = ld + 1) begin
            w2_shared_exp[ld] = 8'd127;
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                w2_vec_mem[ld][k]  = $random;
                w2_vec_real[ld][k] = to_fp32(int'(w2_vec_mem[ld][k]));
            end
        end

        // Generate activations
        for (ld = 0; ld < NUM_LOADS; ld = ld + 1) begin
            for (rv = 0; rv < REUSE_FACTOR; rv = rv + 1) begin
                x_shared_exp[ld][rv] = 8'd126;
                for (k = 0; k < DOT_LEN; k = k + 1) begin
                    x_vec_mem[ld][rv][k]  = $random;
                    x_vec_real[ld][rv][k] = to_fp32(int'(x_vec_mem[ld][rv][k]));
                end
            end
        end

        // Compute golden results
        for (ld = 0; ld < NUM_LOADS; ld = ld + 1) begin
            for (rv = 0; rv < REUSE_FACTOR; rv = rv + 1) begin
                dot_gold_col1_real[ld][rv] = dot(
                    w1_vec_real[ld],
                    x_vec_real[ld][rv],
                    byte'(w1_shared_exp[ld]),
                    byte'(x_shared_exp[ld][rv])
                );
                gold_col1_bits[ld][rv] = $shortrealtobits(dot_gold_col1_real[ld][rv]);

                dot_gold_col2_real[ld][rv] = dot(
                    w2_vec_real[ld],
                    x_vec_real[ld][rv],
                    byte'(w2_shared_exp[ld]),
                    byte'(x_shared_exp[ld][rv])
                );
                gold_col2_bits[ld][rv] = $shortrealtobits(dot_gold_col2_real[ld][rv]);
            end
        end

        // Print summary
        $display("============================================================");
        $display("DATA_GEN: Generated %0d load(s), %0d reuse vectors each",
                 NUM_LOADS, REUSE_FACTOR);
        $display("============================================================");
        for (ld = 0; ld < NUM_LOADS; ld = ld + 1) begin
            for (rv = 0; rv < REUSE_FACTOR; rv = rv + 1) begin
                $display("  G_col1[ld=%0d][rv=%0d] = 0x%08h (%f)",
                         ld, rv, gold_col1_bits[ld][rv], dot_gold_col1_real[ld][rv]);
                $display("  G_col2[ld=%0d][rv=%0d] = 0x%08h (%f)",
                         ld, rv, gold_col2_bits[ld][rv], dot_gold_col2_real[ld][rv]);
            end
        end
        $display("============================================================");

        gen_done = 1'b1;
    end

    // -----------------------------------------------------------------
    // DUT signals
    // -----------------------------------------------------------------
    logic                    clk;
    logic                    rst;
    logic                    load_en;
    logic                    valid_en;
    logic [DATA_MX_W-1:0]    mx_data_in [0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] shared_exponent;
    logic [DATA_OUT_W-1:0]   fp32_dot_out_col1;
    logic [DATA_OUT_W-1:0]   fp32_dot_out_col2;
    logic                    valid_out;
    logic [3:0]              fp32_flags_col1;
    logic [3:0]              fp32_flags_col2;

    // -----------------------------------------------------------------
    // DUT
    // -----------------------------------------------------------------
    mxfp_dot_proposed #(
        .MODE_INT (MODE_INT),
        .IS_SIM   (IS_SIM),
        .IS_DOT4  (IS_DOT4),
        .E        (EXP_W),
        .M        (MAN_W),
        .E_SHARED (SHARED_EXP_W),
        .DOT_LEN  (DOT_LEN)
    ) dut (
        .clk                 (clk),
        .rst                 (rst),
        .load_en_i           (load_en),
        .valid_en_i          (valid_en),
        .mx_data_in_i        (mx_data_in),
        .shared_exponent_i   (shared_exponent),
        .fp32_dot_out_col1_o (fp32_dot_out_col1),
        .fp32_dot_out_col2_o (fp32_dot_out_col2),
        .valid_out_o         (valid_out),
        .fp32_flags_col1_o   (fp32_flags_col1),
        .fp32_flags_col2_o   (fp32_flags_col2)
    );

    // -----------------------------------------------------------------
    // Clock generation (100 MHz)
    // -----------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // -----------------------------------------------------------------
    // Reset
    // -----------------------------------------------------------------
    initial begin
        rst = 1'b1;
        wait (gen_done);
        repeat (4) @(posedge clk);
        rst = 1'b0;
    end

    // -----------------------------------------------------------------
    // Driver
    // Applies the stimulus to the DUT.
    //
    // Protocol:
    //   1. Assert load_en one cycle before col2 weights
    //   2. Drive col2 weights (w2) + shared exp
    //   3. De-assert load_en, drive col1 weights (w1) + shared exp
    //   4. For each reuse vector: assert valid_en, drive activation
    //      data + shared exp
    //      (re-assert load_en on last reuse cycle if another load follows)
    //   5. De-assert valid_en
    //
    // -----------------------------------------------------------------
    integer di, dj;
    initial begin : DRIVER
        wait (gen_done);

        // Initialize
        load_en          <= 1'b0;
        valid_en         <= 1'b0;
        shared_exponent  <= '0;
        for (di = 0; di < DOT_LEN; di = di + 1)
            mx_data_in[di] <= '0;

        // Wait for reset de-assertion
        @(negedge rst);
        repeat (4) @(posedge clk);

        // Place ourselves on a negedge
        @(negedge clk);

        for (dj = 0; dj < NUM_LOADS; dj = dj + 1) begin
            // Assert load_en one cycle before col2 data
            load_en <= 1'b1;

            @(negedge clk);
            // Drive col2 weights (loaded first, produces col2 output)
            for (di = 0; di < DOT_LEN; di = di + 1)
                mx_data_in[di] <= w2_vec_mem[dj][di];
            shared_exponent <= w2_shared_exp[dj];

            @(negedge clk);
            // Drive col1 weights, de-assert load_en
            load_en <= 1'b0;
            for (di = 0; di < DOT_LEN; di = di + 1)
                mx_data_in[di] <= w1_vec_mem[dj][di];
            shared_exponent <= w1_shared_exp[dj];

            @(negedge clk);

            // Stream reuse activation vectors
            for (int rv_idx = 0; rv_idx < REUSE_FACTOR; rv_idx = rv_idx + 1) begin
                valid_en <= 1'b1;
                for (di = 0; di < DOT_LEN; di = di + 1)
                    mx_data_in[di] <= x_vec_mem[dj][rv_idx][di];
                shared_exponent <= x_shared_exp[dj][rv_idx];

                // Pipeline: re-assert load_en on last reuse cycle if
                // another load phase follows
                if ((rv_idx == REUSE_FACTOR - 1) && (dj != NUM_LOADS - 1))
                    load_en <= 1'b1;

                @(negedge clk);
            end

            // De-assert valid after streaming
            valid_en <= 1'b0;
        end

        // Timeout safety net
        repeat (1000) @(negedge clk);
        $error("[%0t] Timeout: not all outputs received.", $time);
        $finish;
    end

    // -----------------------------------------------------------------
    // Receiver / Checker
    // Compares DUT outputs to the golden model's outputs.
    // Stops simulation on first mismatch or after all
    // expected outputs are received.
    //
    // Uses ULP (unit in the last place) tolerance to account for
    // FP32 rounding differences between the golden model (single
    // accumulation) and the hardware (cascaded partial FP32 adds).
    // -----------------------------------------------------------------
    localparam TOTAL_EXPECTED = NUM_LOADS * REUSE_FACTOR;
    localparam int MAX_ULP = 4;  // Allow up to 4 ULP difference

    integer out_load;       // current load index we expect output for
    integer out_reuse;      // current reuse index within that load
    integer total_recv;
    logic   mismatch_seen;

    initial begin : RECEIVER
        total_recv    = 0;
        out_load      = 0;
        out_reuse     = 0;
        mismatch_seen = 1'b0;

        wait (gen_done);
        @(negedge rst);

        forever begin
            @(posedge clk);

            if (valid_out) begin
                total_recv = total_recv + 1;

                $display("[%0t] OUT ld=%0d rv=%0d  dut_col1=0x%08h gold_col1=0x%08h (%0d ULP)  dut_col2=0x%08h gold_col2=0x%08h (%0d ULP)  flags1=%4b flags2=%4b",
                         $time, out_load, out_reuse,
                         fp32_dot_out_col1, gold_col1_bits[out_load][out_reuse],
                         fp32_ulp_diff(fp32_dot_out_col1, gold_col1_bits[out_load][out_reuse]),
                         fp32_dot_out_col2, gold_col2_bits[out_load][out_reuse],
                         fp32_ulp_diff(fp32_dot_out_col2, gold_col2_bits[out_load][out_reuse]),
                         fp32_flags_col1,   fp32_flags_col2);

                // Check col1
                if (!fp32_close(fp32_dot_out_col1, gold_col1_bits[out_load][out_reuse], MAX_ULP)) begin
                    mismatch_seen = 1'b1;
                    $error("[%0t] COL1 MISMATCH ld=%0d rv=%0d  dut=0x%08h gold=0x%08h (diff=%0d ULP, max=%0d)",
                           $time, out_load, out_reuse,
                           fp32_dot_out_col1, gold_col1_bits[out_load][out_reuse],
                           fp32_ulp_diff(fp32_dot_out_col1, gold_col1_bits[out_load][out_reuse]),
                           MAX_ULP);
                    $display("[%0t] TEST FAILED: ending simulation.", $time);
                    repeat(5) @(negedge clk);
                    $finish;
                end

                // Check col2
                if (!fp32_close(fp32_dot_out_col2, gold_col2_bits[out_load][out_reuse], MAX_ULP)) begin
                    mismatch_seen = 1'b1;
                    $error("[%0t] COL2 MISMATCH ld=%0d rv=%0d  dut=0x%08h gold=0x%08h (diff=%0d ULP, max=%0d)",
                           $time, out_load, out_reuse,
                           fp32_dot_out_col2, gold_col2_bits[out_load][out_reuse],
                           fp32_ulp_diff(fp32_dot_out_col2, gold_col2_bits[out_load][out_reuse]),
                           MAX_ULP);
                    $display("[%0t] TEST FAILED: ending simulation.", $time);
                    $finish;
                end

                // Advance expected index
                out_reuse = out_reuse + 1;
                if (out_reuse == REUSE_FACTOR) begin
                    $display("[%0t] Completed load phase %0d (%0d outputs)",
                             $time, out_load, REUSE_FACTOR);
                    out_reuse = 0;
                    out_load  = out_load + 1;
                end

                if (total_recv == TOTAL_EXPECTED) begin
                    $display("============================================================");
                    $display("[%0t] TEST PASSED: received all %0d expected outputs.",
                             $time, TOTAL_EXPECTED);
                    $display("============================================================");
                    $finish;
                end
            end
        end
    end

    // -----------------------------------------------------------------
    // Golden model helpers
    // -----------------------------------------------------------------

    // Returns the absolute ULP distance between two FP32 bit patterns.
    // Works correctly for same-sign values (which is the expected case
    // for dot product results).  For opposite signs, returns a large
    // value that will always exceed any reasonable tolerance.
    function automatic int fp32_ulp_diff(logic [31:0] a, logic [31:0] b);
        int sa, sb, diff;
        // Convert sign-magnitude to a signed integer that preserves
        // FP32 ordering: if negative, flip to two's complement form.
        sa = a[31] ? -(int'({1'b0, a[30:0]})) : int'(a);
        sb = b[31] ? -(int'({1'b0, b[30:0]})) : int'(b);
        diff = sa - sb;
        if (diff < 0) diff = -diff;
        return diff;
    endfunction

    // Returns 1 if two FP32 bit patterns are within max_ulp of each other.
    function automatic logic fp32_close(logic [31:0] a, logic [31:0] b, int max_ulp);
        return (fp32_ulp_diff(a, b) <= max_ulp);
    endfunction

    // Dot product of two MXFP vectors; scales result by the combined shared exponents.
    function automatic shortreal dot(
        shortreal vec1[], shortreal vec2[],
        byte shared_exp1, byte shared_exp2
    );
        int corrected_exp = shared_exp1 - 127 + shared_exp2 - 127;
        dot = 0.0;
        foreach (vec1[i])
            dot += vec1[i] * vec2[i];
        dot = shortreal'(dot * (2.0 ** corrected_exp));
    endfunction

    // Converts an MXFP element (raw bits as int) to FP32, handling both normal and subnormal encodings.
    function automatic shortreal to_fp32(int fp_bits);
        localparam int M = MAN_W;
        localparam int E = EXP_W;
        int BIAS = (1 << (E - 1)) - 1;

        shortreal sign = fp_bits[M+E] ? -1.0 : 1.0;
        int M_bits = fp_bits[M-1:0];
        int E_bits = fp_bits[M+E-1:M];

        if (M_bits == 0 && E_bits == 0)
            to_fp32 = sign * 0.0;
        else if (E_bits == 0)
            to_fp32 = sign * (2.0 ** (1 - BIAS)) * (M_bits / shortreal'(1 << M));
        else
            to_fp32 = sign * (2.0 ** (E_bits - BIAS)) * (1.0 + M_bits / shortreal'(1 << M));
    endfunction

endmodule