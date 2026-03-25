`timescale 1ns/1ps
module sys_array_packed_mult_tb;
    localparam N = 3;
    // Number of sets of activations to stream in.
    localparam P = 5;
    localparam EXP_W = 4;
    localparam MAN_W = 3;
    localparam DATA_MX_W = 1 + MAN_W + EXP_W;
    localparam SHARED_EXP_W = 8;
    localparam int MUL_WIDTH = 18;
    localparam int DOT_LEN = 32;
    localparam int DATA_OUT_W = 32;
    localparam int NUM_OPS = MUL_WIDTH / 2 / (1 + MAN_W);

    localparam int GOLD_TOTAL_OUTPUTS = P * N * N;
    localparam int DUT_TOTAL_OUTPUTS = P * N * N;

    // Test vectors
    logic [DATA_MX_W-1:0] w_vec_mem [0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] w_shared_exp_mem [0:N-1];
    logic [DATA_MX_W-1:0] x_vec_mem [0:P-1][0:N-1][0:DOT_LEN-1][0:NUM_OPS-1];
    logic [SHARED_EXP_W-1:0] x_shared_exp_mem [0:P-1][0:N-1][0:NUM_OPS-1];

    // Result according to the activation (set p, row r, col c, op n)
    logic [DATA_OUT_W-1:0] gold_results_mem [0:P-1][0:N-1][0:N-1][0:NUM_OPS-1];

    logic gen_done;
    logic gold_done;

    integer p, r, c, i, n;

    // Helper function to create packed MXFP numbers
    // Avoids zero/denormal/infinity numbers
    function automatic logic [DATA_MX_W-1:0] make_mxfp(input int seed);
        int bias;
        int exp_bits;
        int mant_bits;
        logic sign_bit;
        logic [DATA_MX_W-1:0] tmp;
        begin
            bias = (1 << (EXP_W-1)) - 1;

            sign_bit = seed[0];

            // Stay in normal range, near the bias
            exp_bits = bias + ((seed % 3) - 1);
            if (exp_bits < 1) exp_bits = 1;
            if (exp_bits > ((1 << EXP_W) - 2)) exp_bits = (1 << EXP_W) - 2;

            mant_bits = (seed * 3 + 1) % (1 << MAN_W);

            tmp = '0;
            tmp[DATA_MX_W-1] = sign_bit;
            tmp[DATA_MX_W-2 -: EXP_W] = exp_bits[EXP_W-1:0];
            tmp[MAN_W-1:0] = mant_bits[MAN_W-1:0];
            make_mxfp = tmp;
        end
    endfunction

    // Generate weights + activations (deterministically)
    initial begin : DATA_GEN
        gen_done  = 1'b0;
        gold_done = 1'b0;

        for (r = 0; r < N; r = r + 1) begin
            w_shared_exp_mem[r] = 8'(127 + (r % 2));
            for (i = 0; i < DOT_LEN; i = i + 1) begin
                w_vec_mem[r][i] = make_mxfp(100 + r*37 + i);
            end
        end

        for (p = 0; p < P; p = p + 1) begin
            for (c = 0; c < N; c = c + 1) begin
                for (n = 0; n < NUM_OPS; n = n + 1) begin
                    x_shared_exp_mem[p][c][n] = 8'(127 + ((p + c + n) % 2));
                end

                for (i = 0; i < DOT_LEN; i = i + 1) begin
                    for (n = 0; n < NUM_OPS; n = n + 1) begin
                        x_vec_mem[p][c][i][n] = make_mxfp(1000 + p*101 + c*29 + i*3 + n);
                    end
                end
            end
        end

        $display("============================================================");
        $display("Generated weights");
        $display("============================================================");
        for (r = 0; r < N; r = r + 1) begin
            $write("W[%0d] shared_exp=%0d :", r, w_shared_exp_mem[r]);
            for (i = 0; i < DOT_LEN; i = i + 1) begin
                $write(" %0h", w_vec_mem[r][i]);
            end
            $write("\n");
        end

        $display("============================================================");
        $display("Generated activations");
        $display("============================================================");
        for (p = 0; p < P; p = p + 1) begin
            for (c = 0; c < N; c = c + 1) begin
                for (n = 0; n < NUM_OPS; n = n + 1) begin
                    $write("X[p=%0d][c=%0d][op=%0d] exp=%0d :", p, c, n, x_shared_exp_mem[p][c][n]);
                    for (i = 0; i < DOT_LEN; i = i + 1) begin
                        $write(" %0h", x_vec_mem[p][c][i][n]);
                    end
                    $write("\n");
                end
            end
        end

        gen_done = 1'b1;

    end

    // Clock gen
    logic clk;
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // DUT
    logic rst;

    logic weights_valid_left_i_dut [0:N-1];
    logic [DATA_MX_W-1:0] weight_left_i_dut [0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] weight_shared_exp_left_i_dut [0:N-1];

    logic x_valid_top_i_dut [0:N-1];
    logic [DATA_MX_W-1:0] x_top_i_dut [0:N-1][0:DOT_LEN-1][0:NUM_OPS-1];
    logic [SHARED_EXP_W-1:0] x_shared_exp_top_i_dut [0:N-1][0:NUM_OPS-1];

    logic [DATA_OUT_W-1:0] dot_fp32_o_dut [0:N-1][0:N-1][0:NUM_OPS-1];
    logic valid_o_dut [0:N-1][0:N-1];

    sys_array_packed_mult #(
        .N(N),
        .MAN_W(MAN_W),
        .EXP_W(EXP_W),
        .DATA_MX_W(DATA_MX_W),
        .SHARED_EXP_W(SHARED_EXP_W),
        .MUL_WIDTH(MUL_WIDTH),
        .DOT_LEN(DOT_LEN),
        .DATA_OUT_W(DATA_OUT_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .weights_valid_left_i(weights_valid_left_i_dut),
        .weight_left_i(weight_left_i_dut),
        .weight_shared_exp_left_i(weight_shared_exp_left_i_dut),
        .x_valid_top_i(x_valid_top_i_dut),
        .x_top_i(x_top_i_dut),
        .x_shared_exp_top_i(x_shared_exp_top_i_dut),
        .dot_fp32_o(dot_fp32_o_dut),
        .valid_o(valid_o_dut)
    );

    // Independent PE
    logic gold_valid_in [0:N-1][0:N-1];
    logic gold_valid_out [0:N-1][0:N-1];

    logic [DATA_MX_W-1:0] gold_operands [0:N-1][0:N-1][0:DOT_LEN-1][0:NUM_OPS-1];
    logic [DATA_MX_W-1:0] gold_sharedOperands [0:N-1][0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] gold_block_exp [0:N-1][0:N-1][0:NUM_OPS-1];
    logic [SHARED_EXP_W-1:0] gold_sharedBlock_exp [0:N-1][0:N-1];
    logic [DATA_OUT_W-1:0] gold_results_wire [0:N-1][0:N-1][0:NUM_OPS-1];

    genvar gr, gc;
    generate
        for (gr = 0; gr < N; gr = gr + 1) begin : GEN_GOLD_ROW
            for (gc = 0; gc < N; gc = gc + 1) begin : GEN_GOLD_COL
                packed_dot_product_fp32 #(
                    .exponent_width(EXP_W),
                    .mantissa_width(MAN_W),
                    .mul_width(MUL_WIDTH),
                    .block_size(DOT_LEN)
                ) gold_pe (
                    .clk(clk),
                    .valid_in(gold_valid_in[gr][gc]),
                    .valid_out(gold_valid_out[gr][gc]),
                    .operands(gold_operands[gr][gc]),
                    .sharedOperands(gold_sharedOperands[gr][gc]),
                    .block_exponent(gold_block_exp[gr][gc]),
                    .sharedBlock_exponent(gold_sharedBlock_exp[gr][gc]),
                    .results(gold_results_wire[gr][gc])
                );
            end
        end
    endgenerate

    // DUT in reset until all gold values are generated
    initial begin
        rst = 1'b1;
        wait(gold_done);
        repeat (4) @(posedge clk);
        rst = 1'b0;
    end

    // Initialization of DUT and gold results
    integer rr, cc;
    initial begin
        wait(gen_done);

        for (rr = 0; rr < N; rr = rr + 1) begin
            weights_valid_left_i_dut[rr] = 1'b0;
            x_valid_top_i_dut[rr]        = 1'b0;
            weight_shared_exp_left_i_dut[rr] = '0;
            for (i = 0; i < DOT_LEN; i = i + 1) begin
                weight_left_i_dut[rr][i] = '0;
                for (n = 0; n < NUM_OPS; n = n + 1) begin
                    x_top_i_dut[rr][i][n] = '0;
                end
            end
            for (n = 0; n < NUM_OPS; n = n + 1) begin
                x_shared_exp_top_i_dut[rr][n] = '0;
            end
        end

        for (rr = 0; rr < N; rr = rr + 1) begin
            for (cc = 0; cc < N; cc = cc + 1) begin
                gold_valid_in[rr][cc] = 1'b0;
                gold_sharedBlock_exp[rr][cc] = '0;
                for (i = 0; i < DOT_LEN; i = i + 1) begin
                    gold_sharedOperands[rr][cc][i] = '0;
                    for (n = 0; n < NUM_OPS; n = n + 1) begin
                        gold_operands[rr][cc][i][n] = '0;
                    end
                end
                for (n = 0; n < NUM_OPS; n = n + 1) begin
                    gold_block_exp[rr][cc][n] = '0;
                end
            end
        end
    end

    // Generate the expected results from the independent PEs
    integer gold_recv_count;
    integer gold_expect_p [0:N-1][0:N-1];

    initial begin : GOLD_STIMULUS
        wait(gen_done);

        gold_recv_count = 0;
        for (rr = 0; rr < N; rr = rr + 1) begin
            for (cc = 0; cc < N; cc = cc + 1) begin
                gold_expect_p[rr][cc] = 0;
            end
        end

        repeat (3) @(negedge clk);

        for (p = 0; p < P; p = p + 1) begin
            @(negedge clk);
            for (rr = 0; rr < N; rr = rr + 1) begin
                for (cc = 0; cc < N; cc = cc + 1) begin
                    gold_valid_in[rr][cc] <= 1'b1;

                    for (i = 0; i < DOT_LEN; i = i + 1) begin
                        gold_sharedOperands[rr][cc][i] <= w_vec_mem[rr][i];
                        for (n = 0; n < NUM_OPS; n = n + 1) begin
                            gold_operands[rr][cc][i][n] <= x_vec_mem[p][cc][i][n];
                        end
                    end

                    gold_sharedBlock_exp[rr][cc] <= w_shared_exp_mem[rr];
                    for (n = 0; n < NUM_OPS; n = n + 1) begin
                        gold_block_exp[rr][cc][n] <= x_shared_exp_mem[p][cc][n];
                    end
                end
            end

            // Bubble
            //@(negedge clk);
            //for (rr = 0; rr < N; rr = rr + 1) begin
            //    for (cc = 0; cc < N; cc = cc + 1) begin
            //        gold_valid_in[rr][cc] <= 1'b0;
            //    end
            //end

        end
    end

    initial begin : GOLD_RECEIVER
        wait(gen_done);

        forever begin
            @(posedge clk);

            for (rr = 0; rr < N; rr = rr + 1) begin
                for (cc = 0; cc < N; cc = cc + 1) begin
                    if (gold_valid_out[rr][cc]) begin
                        for (n = 0; n < NUM_OPS; n = n + 1) begin
                            gold_results_mem[gold_expect_p[rr][cc]][rr][cc][n] = gold_results_wire[rr][cc][n];
                        end

                        $display("[%0t] GOLD captured p=%0d row=%0d col=%0d",
                                 $time, gold_expect_p[rr][cc], rr, cc);

                        gold_expect_p[rr][cc] = gold_expect_p[rr][cc] + 1;
                        gold_recv_count = gold_recv_count + 1;

                        if (gold_recv_count == GOLD_TOTAL_OUTPUTS) begin
                            $display("============================================================");
                            $display("[%0t] GOLD phase done, captured %0d expected outputs",
                                     $time, GOLD_TOTAL_OUTPUTS);
                            $display("============================================================");
                            gold_done = 1'b1;
                        end
                    end
                end
            end
        end
    end

    // Having received all gold outputs, send in the activations and weights
    initial begin : DUT_DRIVER
        wait(gen_done);
        wait(gold_done);
        @(negedge rst);

        repeat (4) @(posedge clk);

        // Drive P consecutive launches.
        // For each launch p, send both:
        //   - the row weight blocks
        //   - the column activation blocks
        for (p = 0; p < P; p = p + 1) begin
            @(negedge clk);
            for (r = 0; r < N; r = r + 1) begin
                weights_valid_left_i_dut[r] <= 1'b1;
                x_valid_top_i_dut[r]        <= 1'b1;

                weight_shared_exp_left_i_dut[r] <= w_shared_exp_mem[r];
                for (i = 0; i < DOT_LEN; i = i + 1) begin
                    // Re-inject weights every cycle
                    weight_left_i_dut[r][i] <= w_vec_mem[r][i];

                    for (n = 0; n < NUM_OPS; n = n + 1) begin
                        x_top_i_dut[r][i][n] <= x_vec_mem[p][r][i][n];
                    end
                end

                for (n = 0; n < NUM_OPS; n = n + 1) begin
                    x_shared_exp_top_i_dut[r][n] <= x_shared_exp_mem[p][r][n];
                end
            end
        end

        // Deassert inputs after final launch
        @(negedge clk);
        // Right now packed mult does not support stream
        for (r = 0; r < N; r = r + 1) begin
            weights_valid_left_i_dut[r] <= 1'b0;
            x_valid_top_i_dut[r]        <= 1'b0;

            weight_shared_exp_left_i_dut[r] <= '0;
            for (i = 0; i < DOT_LEN; i = i + 1) begin
                weight_left_i_dut[r][i] <= '0;
                for (n = 0; n < NUM_OPS; n = n + 1) begin
                    x_top_i_dut[r][i][n] <= '0;
                end
            end

            for (n = 0; n < NUM_OPS; n = n + 1) begin
                x_shared_exp_top_i_dut[r][n] <= '0;
            end
        end

        repeat (300) @(negedge clk);
        $error("Timeout waiting for DUT outputs.");
        $finish;
    end

    // Check the outputs of the SA against the independent PEs
    integer dut_recv_count;
    integer dut_expect_p [0:N-1][0:N-1];
    logic mismatch_seen;

    initial begin : DUT_RECEIVER
        dut_recv_count = 0;
        mismatch_seen  = 1'b0;

        for (rr = 0; rr < N; rr = rr + 1) begin
            for (cc = 0; cc < N; cc = cc + 1) begin
                dut_expect_p[rr][cc] = 0;
            end
        end

        wait(gold_done);
        @(negedge rst);

        forever begin
            @(posedge clk);

            for (rr = 0; rr < N; rr = rr + 1) begin
                for (cc = 0; cc < N; cc = cc + 1) begin
                    if (valid_o_dut[rr][cc]) begin
                        if (dut_expect_p[rr][cc] >= P) begin
                            $error("[%0t] Unexpected extra DUT output at row=%0d col=%0d",
                                   $time, rr, cc);
                            $finish;
                        end

                        for (n = 0; n < NUM_OPS; n = n + 1) begin
                            $display("[%0t] DUT row=%0d col=%0d p=%0d op=%0d dut=0x%08h gold=0x%08h",
                                     $time, rr, cc, dut_expect_p[rr][cc], n,
                                     dot_fp32_o_dut[rr][cc][n],
                                     gold_results_mem[dut_expect_p[rr][cc]][rr][cc][n]);

                            if (dot_fp32_o_dut[rr][cc][n] !==
                                gold_results_mem[dut_expect_p[rr][cc]][rr][cc][n]) begin
                                mismatch_seen = 1'b1;
                                $error("[%0t] MISMATCH row=%0d col=%0d p=%0d op=%0d dut=0x%08h gold=0x%08h",
                                       $time, rr, cc, dut_expect_p[rr][cc], n,
                                       dot_fp32_o_dut[rr][cc][n],
                                       gold_results_mem[dut_expect_p[rr][cc]][rr][cc][n]);
                                $finish;
                            end
                        end

                        dut_expect_p[rr][cc] = dut_expect_p[rr][cc] + 1;
                        dut_recv_count = dut_recv_count + 1;

                        if (dut_recv_count == DUT_TOTAL_OUTPUTS) begin
                            $display("============================================================");
                            $display("[%0t] TEST PASSED: received all expected DUT outputs (%0d).",
                                     $time, DUT_TOTAL_OUTPUTS);
                            $display("============================================================");
                            $finish;
                        end
                    end
                end
            end
        end
    end
endmodule