`timescale 1ns/1ps
module sys_array_aitb_tb;
    localparam N = 3;
    // Number of sets of activations to stream in.
    localparam P = 2;
    localparam EXP_W = 2;
    localparam MAN_W = 3;
    localparam DATA_MX_W = 1 + MAN_W + EXP_W;
    localparam SHARED_EXP_W = 8;
    localparam FP_BIAS = 1;
    localparam SHARED_EXP_BIAS = 127;
    localparam DOT_LEN = 32;
    localparam DATA_OUT_W = 32;
    
    // If want to use hex files
    // NOTE: issue with this is the hex from testbench/scripts/generate_data.py does not seem to be exactly like our PEs
    //logic hex_loaded_done;
    //logic [DATA_MX_W-1:0] w0_vec_mem [0:DOT_LEN-1];
    //logic [DATA_MX_W-1:0] x0_vec_mem [0:DOT_LEN-1];
    //logic [SHARED_EXP_W-1:0] w0_shared_exp_mem [0:0];
    //logic [SHARED_EXP_W-1:0] x0_shared_exp_mem [0:0];
    //logic [DATA_OUT_W-1:0] gold_dot_mem [0:0];
    //initial begin : LOAD_HEX
    //    hex_loaded_done = 1'b0;
    //    $display("[%0t] Reading hex files...", $time);
    //    $readmemh("../data/vector_a.hex", w0_vec_mem);
    //    $readmemh("../data/vector_b.hex", x0_vec_mem);
    //    $readmemh("../data/shared_exp_a.hex", w0_shared_exp_mem);
    //    $readmemh("../data/shared_exp_a.hex", x0_shared_exp_mem);
    //    $readmemh("../data/fp32_result.hex", gold_dot_mem);
    //    $display("[%0t] Finished reading hex files.", $time);
    //    hex_loaded_done = 1'b1;
    //end

    // Generate the inputs ourselves
    // Col1 weights (loaded second into PE, produces col1 output)
    shortreal w1_vec_real [0:N-1][0:DOT_LEN-1];
    // Col2 weights (loaded first into PE, produces col2 output)
    shortreal w2_vec_real [0:N-1][0:DOT_LEN-1];
    shortreal x_vec_real [0:P-1][0:N-1][0:DOT_LEN-1];
    shortreal dot_gold_col1_real [0:P-1][0:N-1][0:N-1];
    shortreal dot_gold_col2_real [0:P-1][0:N-1][0:N-1];

    // Stimulus
    logic [DATA_MX_W-1:0] w1_vec_mem [0:N-1][0:DOT_LEN-1];
    logic [DATA_MX_W-1:0] w2_vec_mem [0:N-1][0:DOT_LEN-1];
    logic [DATA_MX_W-1:0] x_vec_mem [0:P-1][0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] w1_shared_exp_mem [0:N-1];
    logic [SHARED_EXP_W-1:0] w2_shared_exp_mem [0:N-1];
    logic [SHARED_EXP_W-1:0] x_shared_exp_mem [0:P-1][0:N-1];

    // Golden result bits
    logic gen_done;
    logic [DATA_OUT_W-1:0] dot_fp32_col1_o_gold [0:P-1][0:N-1][0:N-1];
    logic [DATA_OUT_W-1:0] dot_fp32_col2_o_gold [0:P-1][0:N-1][0:N-1];
    integer r, c, k, p;
    initial begin : DATA_GEN
        gen_done = 1'b0;

        // Clear everything
        for (r = 0; r < N; r = r + 1) begin
            w1_shared_exp_mem[r] = '0;
            w2_shared_exp_mem[r] = '0;
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                w1_vec_mem[r][k]  = '0;
                w1_vec_real[r][k] = 0.0;
                w2_vec_mem[r][k]  = '0;
                w2_vec_real[r][k] = 0.0;
            end
        end

        for (p = 0; p < P; p = p + 1) begin
            for (c = 0; c < N; c = c + 1) begin
                x_shared_exp_mem[p][c] = '0;
                for (k = 0; k < DOT_LEN; k = k + 1) begin
                    x_vec_mem[p][c][k]  = '0;
                    x_vec_real[p][c][k] = 0.0;
                end
            end
        end

        for (p = 0; p < P; p = p + 1) begin
            for (r = 0; r < N; r = r + 1) begin
                for (c = 0; c < N; c = c + 1) begin
                    dot_gold_col1_real[p][r][c]   = 0.0;
                    dot_gold_col2_real[p][r][c]   = 0.0;
                    dot_fp32_col1_o_gold[p][r][c] = '0;
                    dot_fp32_col2_o_gold[p][r][c] = '0;
                end
            end
        end

        // Col1 weights, one vector per row
        for (r = 0; r < N; r = r + 1) begin
            w1_shared_exp_mem[r] = 8'd127;
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                w1_vec_mem[r][k] = $random;
                w1_vec_real[r][k] = to_fp32(int'(w1_vec_mem[r][k]));
            end
        end

        // Col2 weights, one vector per row
        for (r = 0; r < N; r = r + 1) begin
            w2_shared_exp_mem[r] = 8'd127;
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                w2_vec_mem[r][k] = $random;
                w2_vec_real[r][k] = to_fp32(int'(w2_vec_mem[r][k]));
            end
        end

        // Activations
        // P sets of activations
        for (p = 0; p < P; p = p + 1) begin
            for (c = 0; c < N; c = c + 1) begin
                x_shared_exp_mem[p][c] = 8'd126;
                for (k = 0; k < DOT_LEN; k = k + 1) begin
                    x_vec_mem[p][c][k] = $random;
                    x_vec_real[p][c][k] = to_fp32(int'(x_vec_mem[p][c][k]));
                end
            end
        end

        // Golden dot products for both columns
        for (p = 0; p < P; p = p + 1) begin
            for (r = 0; r < N; r = r + 1) begin
                for (c = 0; c < N; c = c + 1) begin
                    // Col1: w1 dot x
                    dot_gold_col1_real[p][r][c] = dot(
                        w1_vec_real[r],
                        x_vec_real[p][c],
                        byte'(w1_shared_exp_mem[r]),
                        byte'(x_shared_exp_mem[p][c])
                    );
                    dot_fp32_col1_o_gold[p][r][c] = $shortrealtobits(dot_gold_col1_real[p][r][c]);

                    // Col2: w2 dot x
                    dot_gold_col2_real[p][r][c] = dot(
                        w2_vec_real[r],
                        x_vec_real[p][c],
                        byte'(w2_shared_exp_mem[r]),
                        byte'(x_shared_exp_mem[p][c])
                    );
                    dot_fp32_col2_o_gold[p][r][c] = $shortrealtobits(dot_gold_col2_real[p][r][c]);
                end
            end
        end

        // -----------------------------------------------------------------------------
        // Print generated weights, activations, and golden results
        // -----------------------------------------------------------------------------
        $display("============================================================");
        $display("DATA_GEN: Generated col1 weights");
        $display("============================================================");
        for (r = 0; r < N; r = r + 1) begin
            $write("W1[%0d] exp=%0d :", r, w1_shared_exp_mem[r]);
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                $write(" %0h", w1_vec_mem[r][k]);
            end
            $write("\n");
        end

        $display("============================================================");
        $display("DATA_GEN: Generated col2 weights");
        $display("============================================================");
        for (r = 0; r < N; r = r + 1) begin
            $write("W2[%0d] exp=%0d :", r, w2_shared_exp_mem[r]);
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                $write(" %0h", w2_vec_mem[r][k]);
            end
            $write("\n");
        end

        $display("============================================================");
        $display("DATA_GEN: Generated activation sets");
        $display("============================================================");
        // Limit ourselves to the first set, can put in <P if want more
        for (p = 0; p < P; p = p + 1) begin
            for (c = 0; c < N; c = c + 1) begin
                $write("X[p=%0d][c=%0d] exp=%0d :", p, c, x_shared_exp_mem[p][c]);
                for (k = 0; k < DOT_LEN; k = k + 1) begin
                    $write(" %0h", x_vec_mem[p][c][k]);
                end
                $write("\n");
            end
        end

        $display("============================================================");
        $display("DATA_GEN: Golden dot products (col1)");
        $display("============================================================");
        for (p = 0; p < P; p = p + 1) begin
            for (r = 0; r < N; r = r + 1) begin
                for (c = 0; c < N; c = c + 1) begin
                    $display("G_col1[p=%0d][%0d][%0d] = 0x%08h (%f)",
                            p, r, c, dot_fp32_col1_o_gold[p][r][c], dot_gold_col1_real[p][r][c]);
                end
            end
        end

        $display("============================================================");
        $display("DATA_GEN: Golden dot products (col2)");
        $display("============================================================");
        for (p = 0; p < P; p = p + 1) begin
            for (r = 0; r < N; r = r + 1) begin
                for (c = 0; c < N; c = c + 1) begin
                    $display("G_col2[p=%0d][%0d][%0d] = 0x%08h (%f)",
                            p, r, c, dot_fp32_col2_o_gold[p][r][c], dot_gold_col2_real[p][r][c]);
                end
            end
        end
        $display("============================================================");

        gen_done = 1'b1;
    end

    // Signals for DUT
    logic clk;
    logic rst;
    logic is_load_phase_i_dut;
    // NOTE:
    // The underlying mxfp_dot uses column 1 of the AITB to produce the output.
    // The load signal has to be asserted 2 cycles before the corresponding weight is asserted
    logic load_en_all_i_dut;
    logic [DATA_MX_W-1:0] weight_left_i_dut [0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] weight_shared_exp_left_i_dut [0:N-1];
    logic valid_top_i_dut [0:N-1];
    logic [DATA_MX_W-1:0] x_top_i_dut [0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] x_shared_exp_top_i_dut [0:N-1];
    logic [DATA_OUT_W-1:0] dot_fp32_col1_o_dut [0:N-1][0:N-1];
    logic [DATA_OUT_W-1:0] dot_fp32_col2_o_dut [0:N-1][0:N-1];
    logic valid_o_dut [0:N-1][0:N-1];
    logic [3:0] fp32_flags_col1_o_dut [0:N-1][0:N-1];
    logic [3:0] fp32_flags_col2_o_dut [0:N-1][0:N-1];
    // DUT
    sys_array_aitb #(
        .N(N),
        .MAN_W(MAN_W),
        .EXP_W(EXP_W),
        .DATA_MX_W(DATA_MX_W),
        .SHARED_EXP_W(SHARED_EXP_W),
        .FP_BIAS(FP_BIAS),
        .SHARED_EXP_BIAS(SHARED_EXP_BIAS),
        .DOT_LEN(DOT_LEN),
        .DATA_OUT_W(DATA_OUT_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .is_load_phase_i(is_load_phase_i_dut),
        .load_en_all_i(load_en_all_i_dut),
        .weight_left_i(weight_left_i_dut),
        .weight_shared_exp_left_i(weight_shared_exp_left_i_dut),
        .valid_top_i(valid_top_i_dut),
        .x_top_i(x_top_i_dut),
        .x_shared_exp_top_i(x_shared_exp_top_i_dut),
        .dot_fp32_col1_o(dot_fp32_col1_o_dut),
        .dot_fp32_col2_o(dot_fp32_col2_o_dut),
        .valid_o(valid_o_dut),
        .fp32_flags_col1_o(fp32_flags_col1_o_dut),
        .fp32_flags_col2_o(fp32_flags_col2_o_dut)
    );

    // CLK Gen (100 MHz)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Reset: assert for a few clock cycles
    initial begin
        rst = 1'b1;
        repeat (4) @(posedge clk);
        rst = 1'b0;
    end

    integer i, j;
    initial begin : DRIVER
        wait(gen_done);
        // Initialize inputs
        is_load_phase_i_dut = 1'b0;
        load_en_all_i_dut = 1'b0;

        for (i = 0; i < N; i = i + 1) begin
            weight_shared_exp_left_i_dut[i] = '0;
            valid_top_i_dut[i] = 1'b0;
            x_shared_exp_top_i_dut[i] = '0;
            for (j = 0; j < DOT_LEN; j = j + 1) begin
                weight_left_i_dut[i][j] = '0;
                x_top_i_dut[i][j] = '0;
            end
        end

        // Wait for out of reset
        @(negedge rst);
        
        // Wait a few cycles for clarity
        repeat (4) @(posedge clk);

        // Place ourselves on a negative edge
        @(negedge clk);
        // We are loading weights
        is_load_phase_i_dut <= 1'b1;

        @(negedge clk);

        @(negedge clk);
        // Assert load_en 1 cycle before col2 weights
        load_en_all_i_dut <= 1'b1;

        @ (negedge clk);
        // Introduce weights
        // Col 2 first
        for (i = 0; i < N; i = i + 1) begin
            weight_shared_exp_left_i_dut[i] <= w2_shared_exp_mem[i];
            for (j = 0; j < DOT_LEN; j = j + 1) begin
                weight_left_i_dut[i][j] <= w2_vec_mem[i][j];
            end 
        end

        @ (negedge clk);
        // Col 1 after
        // Deassert load_en
        load_en_all_i_dut <= 1'b0;
        for (i = 0; i < N; i = i + 1) begin
            weight_shared_exp_left_i_dut[i] <= w1_shared_exp_mem[i];
            for (j = 0; j < DOT_LEN; j = j + 1) begin
                weight_left_i_dut[i][j] <= w1_vec_mem[i][j];
            end 
        end

        // Wait for propagation through the array
        repeat (N) @(negedge clk);

        @(negedge clk);
        // Switch to "forward pass" mode
        is_load_phase_i_dut <= 1'b0;
        
        @(negedge clk);
        // Stream the P activations
        for (p = 0; p < P; p = p + 1) begin
            @(negedge clk);
            // Stream one set of activations
            for (i = 0; i < N; i = i + 1) begin
                x_shared_exp_top_i_dut[i] <= x_shared_exp_mem[p][i];
                for (j = 0; j < DOT_LEN; j = j + 1) begin
                    x_top_i_dut[i][j] <= x_vec_mem[p][i][j];
                end
                valid_top_i_dut[i] <= 1'b1;
            end

            //@(negedge clk);
            //for (i = 0; i < N; i = i + 1) begin
            //    valid_top_i_dut[i] <= 1'b0;
            //end

            //repeat (N+2) @(negedge clk);  // temporary debug bubble

        end
        
        @(negedge clk);
        // Deassert once done streaming
        for (i = 0; i < N; i = i + 1) begin
            valid_top_i_dut[i] <= 1'b0;
        end

        repeat (1000) @(negedge clk);
        $error("Timeout.");
        $finish;

    end

    localparam TOTAL_EXPECTED_OUTPUTS = P * N * N;

    integer rr, cc;
    logic mismatch_seen;
    integer total_recv_count;
    // Each row should give P outputs
    integer expect_p_per_row [0:N-1];
    integer recv_count_per_row [0:N-1];
    integer row_valids_this_cycle [0:N-1];

    initial begin : RECEIVER
        total_recv_count = 0;
        mismatch_seen    = 1'b0;

        // Set the counters to 0
        for (rr = 0; rr < N; rr = rr + 1) begin
            expect_p_per_row[rr] = 0;
            recv_count_per_row[rr] = 0;
            row_valids_this_cycle[rr] = 0;
        end

        wait(gen_done);
        @(negedge rst);

        forever begin
            @(posedge clk);

            // Reset valid flags
            for (rr = 0; rr < N; rr = rr + 1) begin
                row_valids_this_cycle[rr] = 0;
            end

            // Find the valid outputs of the array
            for (rr = 0; rr < N; rr = rr + 1) begin
                for (cc = 0; cc < N; cc = cc + 1) begin
                    if (valid_o_dut[rr][cc]) begin
                        row_valids_this_cycle[rr] = row_valids_this_cycle[rr] + 1;
                        total_recv_count = total_recv_count + 1;

                        $display("[%0t] OUT row=%0d col=%0d expect_p=%0d dut_col1=0x%08h gold_col1=0x%08h dut_col2=0x%08h gold_col2=0x%08h",
                             $time, rr, cc, expect_p_per_row[rr],
                             dot_fp32_col1_o_dut[rr][cc],
                             dot_fp32_col1_o_gold[expect_p_per_row[rr]][rr][cc],
                             dot_fp32_col2_o_dut[rr][cc],
                             dot_fp32_col2_o_gold[expect_p_per_row[rr]][rr][cc]);

                        // Check col1
                        if (dot_fp32_col1_o_dut[rr][cc] !==
                            dot_fp32_col1_o_gold[expect_p_per_row[rr]][rr][cc]) begin
                            mismatch_seen = 1'b1;
                            $error("[%0t] COL1 MISMATCH row=%0d col=%0d expect_p=%0d dut=0x%08h gold=0x%08h",
                                $time, rr, cc, expect_p_per_row[rr],
                                dot_fp32_col1_o_dut[rr][cc],
                                dot_fp32_col1_o_gold[expect_p_per_row[rr]][rr][cc]);
                            $display("[%0t] TEST FAILED: ending simulation.", $time);
                            $finish;
                        end

                        // Check col2
                        if (dot_fp32_col2_o_dut[rr][cc] !==
                            dot_fp32_col2_o_gold[expect_p_per_row[rr]][rr][cc]) begin
                            mismatch_seen = 1'b1;
                            $error("[%0t] COL2 MISMATCH row=%0d col=%0d expect_p=%0d dut=0x%08h gold=0x%08h",
                                $time, rr, cc, expect_p_per_row[rr],
                                dot_fp32_col2_o_dut[rr][cc],
                                dot_fp32_col2_o_gold[expect_p_per_row[rr]][rr][cc]);
                            $display("[%0t] TEST FAILED: ending simulation.", $time);
                            $finish;
                        end

                        //$display("[%0t] MATCH row=%0d col=%0d expect_p=%0d (both columns)",
                        //        $time, rr, cc, expect_p_per_row[rr]);
                    end
                end
            end

            for (rr = 0; rr < N; rr = rr + 1) begin
                recv_count_per_row[rr] = recv_count_per_row[rr] + row_valids_this_cycle[rr];

                if (recv_count_per_row[rr] == N) begin
                    $display("[%0t] Completed row %0d for activation set %0d",
                            $time, rr, expect_p_per_row[rr]);
                    recv_count_per_row[rr] = 0;
                    expect_p_per_row[rr] = expect_p_per_row[rr] + 1;
                end
            end

            if (total_recv_count == TOTAL_EXPECTED_OUTPUTS) begin
                $display("============================================================");
                $display("[%0t] TEST PASSED: received all expected outputs (%0d).",
                        $time, TOTAL_EXPECTED_OUTPUTS);
                $display("============================================================");
                $finish;
            end

        end
    end

    // "Golden" model
    function automatic shortreal dot (shortreal vec1[], shortreal vec2[], byte shared_exp1, byte shared_exp2);
        int corrected_exp = shared_exp1-127+shared_exp2-127;
        dot = 0.0;

        foreach (vec1[i])
            dot += vec1[i] * vec2[i]; 
        dot = shortreal'(dot * (2.0 ** (corrected_exp))); // 127 is exponent bias from OCP-MX Standard
    endfunction

    function automatic shortreal to_fp32 (int fp_bits);

        localparam int M = MAN_W;
        localparam int E = EXP_W;

        int BIAS = (1 << (E-1)) - 1;
        //logic [M+E:0] fp_bits = bits[M+E:0];

        shortreal sign = fp_bits[M+E] ? -1.0 : 1.0;
        int M_bits = fp_bits[M-1:0];
        int E_bits = fp_bits[M+E-1:M];



        if (M_bits == 0 && E_bits == 0) begin // ZERO
            to_fp32 = sign * 0.0;
        end
        else if (E_bits == 0) begin // SUBNORMALS
            to_fp32 = sign * (2.0 ** (1 - BIAS)) * (M_bits / shortreal'(1 << M));
        end
        else begin // NORMALs
            to_fp32 = sign * (2.0 ** (E_bits - BIAS)) * (1.0 + M_bits / shortreal'(1 << M));
        end

    endfunction

endmodule