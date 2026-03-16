`timescale 1ns/1ps
module sys_array_aitb_tb;
    localparam N = 3;
    localparam MAN_W = 3;
    localparam EXP_W = 2;
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
    shortreal w_vec_real [0:N-1][0:DOT_LEN-1];
    shortreal x_vec_real [0:N-1][0:DOT_LEN-1];
    shortreal dot_gold_real [0:N-1][0:N-1]; // This is for only 1 set of activations

    // Stimulus
    logic [DATA_MX_W-1:0] w_vec_mem [0:N-1][0:DOT_LEN-1];
    logic [DATA_MX_W-1:0] x_vec_mem [0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] w_shared_exp_mem [0:N-1];
    logic [SHARED_EXP_W-1:0] x_shared_exp_mem [0:N-1];

    // Golden result bits
    logic gen_done;
    logic [DATA_OUT_W-1:0] dot_fp32_o_gold [0:N-1][0:N-1];
    integer r, c, k;
    initial begin : DATA_GEN
        gen_done = 1'b0;
        // Reset everything
        for (r = 0; r < N; r = r + 1) begin
            w_shared_exp_mem[r] = '0;
            x_shared_exp_mem[r] = '0;
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                w_vec_mem[r][k] = '0;
                x_vec_mem[r][k] = '0;
                w_vec_real[r][k] = 0.0;
                x_vec_real[r][k] = 0.0;
            end
        end
        
        for (r = 0; r < N; r = r + 1) begin
            for (c = 0; c < N; c = c + 1) begin
                dot_fp32_o_gold[r][c] = '0;
                dot_gold_real[r][c] = 0.0;
            end
        end

        // Shared exponents
        for (r = 0; r < N; r = r + 1) begin
            // Sensible values to be in normal range
            w_shared_exp_mem[r] = 8'd127;
            x_shared_exp_mem[r] = 8'd126;
        end

        // Generate N weight vectors / N activation vectors
        // since array is symmetric using "row" as iterator, but,
        // for the activations these are the different columns
        for (r = 0; r < N; r = r + 1) begin
           for (k = 0; k < DOT_LEN; k = k + 1) begin
                w_vec_mem[r][k] = $random;
                x_vec_mem[r][k] = $random;

                w_vec_real[r][k] = to_fp32(int'(w_vec_mem[r][k]));
                x_vec_real[r][k] = to_fp32(int'(x_vec_mem[r][k]));
            end 
        end

        // For a set of weights and a set of activations, NxN dot products
        for (r = 0; r < N; r = r + 1) begin
            for (c = 0; c < N; c = c + 1) begin
                dot_gold_real[r][c] = dot(
                    w_vec_real[r],
                    x_vec_real[c],
                    byte'(w_shared_exp_mem[r]),
                    byte'(x_shared_exp_mem[c])
                );

                dot_fp32_o_gold[r][c] = $shortrealtobits(dot_gold_real[r][c]);
            end
        end

        // -----------------------------------------------------------------------------
        // Print generated weights, activations, and golden results
        // -----------------------------------------------------------------------------
        $display("============================================================");
        $display("DATA_GEN: Generated test data");
        $display("============================================================");

        // Weights
        for (r = 0; r < N; r = r + 1) begin
            $display("Weight row %0d : shared_exp = %0d (0x%02h)", 
                    r, w_shared_exp_mem[r], w_shared_exp_mem[r]);
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                $display("  w_vec_mem[%0d][%0d] = 0x%0h   -> fp32 = %f",
                        r, k, w_vec_mem[r][k], w_vec_real[r][k]);
            end
        end

        // Activations
        for (c = 0; c < N; c = c + 1) begin
            $display("Activation col %0d : shared_exp = %0d (0x%02h)", 
                    c, x_shared_exp_mem[c], x_shared_exp_mem[c]);
            for (k = 0; k < DOT_LEN; k = k + 1) begin
                $display("  x_vec_mem[%0d][%0d] = 0x%0h   -> fp32 = %f",
                        c, k, x_vec_mem[c][k], x_vec_real[c][k]);
            end
        end

        // Golden results
        $display("Golden dot products:");
        for (r = 0; r < N; r = r + 1) begin
            for (c = 0; c < N; c = c + 1) begin
                $display("  gold[%0d][%0d] = 0x%08h   -> fp32 = %f",
                        r, c, dot_fp32_o_gold[r][c], dot_gold_real[r][c]);
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
    logic [DATA_OUT_W-1:0] dot_fp32_o_dut [0:N-1][0:N-1];
    logic valid_o_dut [0:N-1][0:N-1];
    logic [3:0] fp32_flags_o_dut [0:N-1][0:N-1][0:3];
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
        .dot_fp32_o(dot_fp32_o_dut),
        .valid_o(valid_o_dut),
        .fp32_flags_o(fp32_flags_o_dut)
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

        @ (negedge clk);
        // Introduce weights
        for (i = 0; i < N; i = i + 1) begin
            weight_shared_exp_left_i_dut[i] <= w_shared_exp_mem[i];
            for (j = 0; j < DOT_LEN; j = j + 1) begin
                weight_left_i_dut[i][j] <= w_vec_mem[i][j];
            end 
        end
        // Assert load enable
        // NOTE: Need to hold load_en_all_i_dut for N cycles
        load_en_all_i_dut <= 1'b1;

        repeat (N) @(negedge clk);
        // Deassert load enable
        load_en_all_i_dut <= 1'b0;

        @(negedge clk); // Have to wait an extra cycle before deassert load phase
        @(negedge clk);
        // Switch to "forward pass" mode
        is_load_phase_i_dut <= 1'b0;
        
        @(negedge clk);
        // Present the activations
        for (i = 0; i < N; i = i + 1) begin
            x_shared_exp_top_i_dut[i] <= x_shared_exp_mem[i];
            for (j = 0; j < DOT_LEN; j = j + 1) begin
                x_top_i_dut[i][j] <= x_vec_mem[i][j];
            end
            valid_top_i_dut[i] = 1'b1;
        end

        @(negedge clk);
        for (i = 0; i < N; i = i + 1) begin
            valid_top_i_dut[i] = 1'b0;
        end

        repeat (100) @(negedge clk);

        $finish;

    end

    integer rr, cc;
    integer recv_count;

    initial begin : RECEIVER
        recv_count = 0;

        wait(gen_done);
        @(negedge rst);

        forever begin
            @(posedge clk);

            for (rr = 0; rr < N; rr = rr + 1) begin
                for (cc = 0; cc < N; cc = cc + 1) begin
                    if (valid_o_dut[rr][cc]) begin
                        recv_count = recv_count + 1;

                        $display("[%0t] RECEIVER: valid_o_dut[%0d][%0d]=1, dut=0x%08h, gold=0x%08h",
                                $time, rr, cc,
                                dot_fp32_o_dut[rr][cc],
                                dot_fp32_o_gold[rr][cc]);

                        if (dot_fp32_o_dut[rr][cc] !== dot_fp32_o_gold[rr][cc]) begin
                            $error("[%0t] MISMATCH at [%0d][%0d]: dut=0x%08h, gold=0x%08h",
                                $time, rr, cc,
                                dot_fp32_o_dut[rr][cc],
                                dot_fp32_o_gold[rr][cc]);
                        end
                        else begin
                            $display("[%0t] MATCH at [%0d][%0d]", $time, rr, cc);
                        end
                    end
                end
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
        else if (E_bits == 0) begin //CURSED SUBNORMALS
            to_fp32 = sign * (2.0 ** (1 - BIAS)) * (M_bits / shortreal'(1 << M));
        end
        else begin // NORMALs
            to_fp32 = sign * (2.0 ** (E_bits - BIAS)) * (1.0 + M_bits / shortreal'(1 << M));
        end

    endfunction

endmodule