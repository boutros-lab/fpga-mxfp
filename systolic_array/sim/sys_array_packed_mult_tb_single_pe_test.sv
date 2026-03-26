`timescale 1ns/1ps
module sys_array_packed_mult_tb;

    localparam EXP_W        = 4;
    localparam MAN_W        = 3;
    localparam DATA_MX_W    = 1 + MAN_W + EXP_W;
    localparam SHARED_EXP_W = 8;
    localparam MUL_WIDTH    = 18;
    localparam DOT_LEN      = 32;
    localparam DATA_OUT_W   = 32;
    localparam NUM_OPS      = MUL_WIDTH / 2 / (1 + MAN_W);

    // Clock
    logic clk;
    initial begin clk = 0; forever #5 clk = ~clk; end

    // Deterministic MXFP generator
    function automatic logic [DATA_MX_W-1:0] make_mxfp(input int seed);
        int bias, exp_bits, mant_bits;
        logic sign_bit;
        logic [DATA_MX_W-1:0] tmp;
        begin
            bias      = (1 << (EXP_W-1)) - 1;
            sign_bit  = seed[0];
            exp_bits  = bias + ((seed % 3) - 1);
            if (exp_bits < 1)                    exp_bits = 1;
            if (exp_bits > ((1 << EXP_W) - 2))  exp_bits = (1 << EXP_W) - 2;
            mant_bits = (seed * 3 + 1) % (1 << MAN_W);
            tmp = '0;
            tmp[DATA_MX_W-1]          = sign_bit;
            tmp[DATA_MX_W-2 -: EXP_W] = exp_bits[EXP_W-1:0];
            tmp[MAN_W-1:0]            = mant_bits[MAN_W-1:0];
            make_mxfp = tmp;
        end
    endfunction

    // PE signals
    logic                       valid_in;
    logic [DATA_MX_W-1:0]      operands      [DOT_LEN-1:0][NUM_OPS-1:0];
    logic [DATA_MX_W-1:0]      sharedOperands[DOT_LEN-1:0];
    logic [SHARED_EXP_W-1:0]   block_exp     [NUM_OPS-1:0];
    logic [SHARED_EXP_W-1:0]   shared_block_exp;
    logic [DATA_OUT_W-1:0]     results       [NUM_OPS-1:0];
    logic                       valid_out;

    packed_dot_product_fp32 #(
        .exponent_width (EXP_W),
        .mantissa_width (MAN_W),
        .mul_width      (MUL_WIDTH),
        .block_size     (DOT_LEN)
    ) u_pe (
        .clk                 (clk),
        .valid_in            (valid_in),
        .valid_out           (valid_out),
        .operands            (operands),
        .sharedOperands      (sharedOperands),
        .block_exponent      (block_exp),
        .sharedBlock_exponent(shared_block_exp),
        .results             (results)
    );

    // Shared storage for captured outputs
    integer valid_count;

    // Checker — runs continuously, captures outputs
    initial begin : CHECKER
        valid_count = 0;
        forever begin
            @(posedge clk);
            if (valid_out) begin
                $display("[%0t] valid_out #%0d: results[0]=0x%08h results[1]=0x%08h",
                         $time, valid_count, results[0], results[1]);
                valid_count = valid_count + 1;
            end
        end
    end

    // Driver — runs test sequences
    initial begin : DRIVER
        integer i, n;

        // Init
        valid_in = 1'b0;
        shared_block_exp = '0;
        for (i = 0; i < DOT_LEN; i++) begin
            sharedOperands[i] = '0;
            for (n = 0; n < NUM_OPS; n++)
                operands[i][n] = '0;
        end
        for (n = 0; n < NUM_OPS; n++)
            block_exp[n] = '0;

        // Wait long enough for all pipeline stages (delay lines, reduction
        // tree, flopoco) to flush X values with known zeros.
        repeat (50) @(posedge clk);

        // ============================================================
        // TEST 1: valid + data for 1 cycle, then deassert
        // ============================================================
        $display("=== Test 1: valid for 1 cycle ===");
        valid_count = 0;

        @(negedge clk);
        valid_in <= 1'b1;
        shared_block_exp <= 8'd128;
        for (n = 0; n < NUM_OPS; n++)
            block_exp[n] <= 8'd127;
        for (i = 0; i < DOT_LEN; i++) begin
            sharedOperands[i] <= make_mxfp(100 + i);
            for (n = 0; n < NUM_OPS; n++)
                operands[i][n] <= make_mxfp(1000 + i*3 + n);
        end

        @(negedge clk);
        valid_in <= 1'b0;
        shared_block_exp <= '0;
        for (n = 0; n < NUM_OPS; n++)
            block_exp[n] <= '0;
        for (i = 0; i < DOT_LEN; i++) begin
            sharedOperands[i] <= '0;
            for (n = 0; n < NUM_OPS; n++)
                operands[i][n] <= '0;
        end

        // Wait for output
        repeat (50) @(posedge clk);
        if (valid_count != 1) begin
            $error("Test 1 FAIL: expected 1 valid output, got %0d", valid_count);
        end else begin
            $display("Test 1: got 1 valid output.");
        end

        repeat (5) @(posedge clk);

        // ============================================================
        // TEST 2: valid + data for 2 cycles (same data), then deassert
        //         Expect 2 identical valid outputs
        // ============================================================
        $display("");
        $display("=== Test 2: valid for 2 cycles, same data ===");
        valid_count = 0;

        @(negedge clk);
        valid_in <= 1'b1;
        shared_block_exp <= 8'd128;
        for (n = 0; n < NUM_OPS; n++)
            block_exp[n] <= 8'd127;
        for (i = 0; i < DOT_LEN; i++) begin
            sharedOperands[i] <= make_mxfp(100 + i);
            for (n = 0; n < NUM_OPS; n++)
                operands[i][n] <= make_mxfp(1000 + i*3 + n);
        end

        // Hold for second cycle (same values, NBA keeps them)
        @(negedge clk);
        // valid_in still 1, data unchanged

        @(negedge clk);
        valid_in <= 1'b0;
        shared_block_exp <= '0;
        for (n = 0; n < NUM_OPS; n++)
            block_exp[n] <= '0;
        for (i = 0; i < DOT_LEN; i++) begin
            sharedOperands[i] <= '0;
            for (n = 0; n < NUM_OPS; n++)
                operands[i][n] <= '0;
        end

        // Wait for outputs
        repeat (50) @(posedge clk);
        if (valid_count != 2) begin
            $error("Test 2 FAIL: expected 2 valid outputs, got %0d", valid_count);
        end else begin
            $display("Test 2: got 2 valid outputs.");
        end

        // ============================================================
        $display("");
        $display("============================================================");
        $display("Tests complete.");
        $display("============================================================");
        $finish;
    end

endmodule