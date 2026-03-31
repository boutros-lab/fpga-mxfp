module fp32_to_mxfp #(
    parameter exponent_width = 4,
    parameter mantissa_width = 3,
    parameter block_size = 32,
    parameter freq_mhz = 400
) (
    input  logic        clk,
    input  logic        valid_in,
    input  logic [31:0] in [block_size],

    output logic [1 + exponent_width + mantissa_width - 1:0] out [block_size],
    output logic [7:0]  out_blk_exp,
    output logic        valid_out
);

    // ---------- Pipeline latency of conv_bf16tomxfp (must match its params) ----------
    localparam pl_pre_shift_rnd = freq_mhz > 200 ? 1 : 0;
    localparam max_flop_output  = freq_mhz > 100 ? 1 : 0;
    localparam max_pl_freq      = (freq_mhz > 200) ? 2 :
                                 ((freq_mhz > 100) ? 4 : 8);
    localparam max_pl_depth     = ($clog2(block_size) / max_pl_freq) + max_flop_output;
    // conv_bf16tomxfp stages: max_pl_depth + pl_pre_shift_rnd + 1 (output register)
    localparam CONV_LATENCY     = max_pl_depth + pl_pre_shift_rnd + 1;
    // Total latency: 1 (FP32→BF16 register) + CONV_LATENCY
    localparam TOTAL_LATENCY    = 1 + CONV_LATENCY;

    // ---------- Stage 0: FP32 to BF16 with RNE rounding (registered) ----------
    // FP32: {sign[31], exp[30:23], mantissa[22:0]}
    // BF16: {sign[15], exp[14:7],  mantissa[6:0]}
    // Truncate lower 16 mantissa bits with round-to-nearest-even.
    logic [15:0] bf16_vec [block_size];

    always_ff @(posedge clk) begin
        for (int i = 0; i < block_size; i++) begin
            logic [15:0] truncated;
            logic        round_bit;   // bit 16 of FP32
            logic        sticky_bit;  // OR of bits [15:0] of FP32
            logic        lsb;         // bit 0 of truncated BF16 (bit 16 of mantissa)

            truncated = in[i][31:16];
            round_bit = in[i][15];
            sticky_bit = |in[i][14:0];
            lsb = truncated[0];

            // RNE: round up if (round && (sticky || lsb))
            if (round_bit && (sticky_bit || lsb))
                bf16_vec[i] <= truncated + 16'd1;
            else
                bf16_vec[i] <= truncated;
        end
    end

    // ---------- Stage 1+: conv_bf16tomxfp ----------
    conv_bf16tomxfp #(
        .exp_width (exponent_width),
        .man_width (mantissa_width),
        .k         (block_size),
        .freq_mhz  (freq_mhz)
    ) u_conv (
        .i_clk     (clk),
        .i_bf16_vec(bf16_vec),
        .o_mx_vec  (out),
        .o_mx_exp  (out_blk_exp)
    );

    // ---------- Valid pipeline ----------
    logic [TOTAL_LATENCY-1:0] valid_sr;

    always_ff @(posedge clk) begin
        valid_sr <= {valid_sr[TOTAL_LATENCY-2:0], valid_in};
    end

    assign valid_out = valid_sr[TOTAL_LATENCY-1];

endmodule