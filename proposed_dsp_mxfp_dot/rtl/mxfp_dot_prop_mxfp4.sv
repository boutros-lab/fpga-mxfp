import pkg_aitb::*;

module mxfp_dot_prop_mxfp4 #(
    parameter mxfp_mode_e MODE = MXFP4,
    parameter bit IS_SIM = 1,
    // Latency of 1 AITB
    parameter int LAT_AITB = 5,
    parameter E = 2,
    parameter M = 1,
	parameter E_SHARED = 8,
	parameter FP_BIAS = 1, // MX-FP BIAS
	parameter SH_BIAS = 127, // Shared EXP bias
	parameter DOT_LEN = 32
) (
    input logic clk,
    input logic rst,
    input logic load_en_i,
    input logic valid_en_i,
    input logic [M+E:0] mx_data_in_i [0:DOT_LEN-1],
	input logic [E_SHARED-1:0] shared_exponent_i,
	output logic [31:0] fp32_dot_out_col1_o,
	output logic [31:0] fp32_dot_out_col2_o,
	output logic valid_out_o,
	output logic [3:0] fp32_flags_col1_o,
	output logic [3:0] fp32_flags_col2_o
);

    localparam int NUM_AITBS = 2;
    // Total latency = LAT_AITB + (NUM_AITB - 1)
    // Top DSP takes LAT_AITB cycles. DSPs in cascade is registered and then we need another cycle for the addition.
    localparam int STAGGER = 2;
    localparam int LAT = LAT_AITB + STAGGER;

    // Valid pipe
    logic [LAT-1:0] valid_pipe;

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_pipe <= '0;
        end else begin
            valid_pipe <= {valid_pipe[LAT-2:0], valid_en_i};
        end
    end
    assign valid_out_o = valid_pipe[LAT-1];

    logic [79:0] data_unpacked [0:NUM_AITBS-1];
    // Unpack inputs
    genvar i;
    generate
    for (i = 0; i < DOT_LEN; i++) begin : unpack
        localparam int aitb_idx = i / 16;
        localparam int word_idx = i % 16;
        assign data_unpacked[aitb_idx][word_idx*(M+E+1) +: (M+E+1)] = mx_data_in_i[i];
    end
    endgenerate
    // Zero out unused bits (16 words × 4 bits)
    assign data_unpacked[0][79:64] = 16'b0;
    assign data_unpacked[1][79:64] = 16'b0;

    // Delay inputs to bottom DSP
    logic [79:0]          data_bot_dly   [0:STAGGER-1];
    logic [E_SHARED-1:0]  sh_exp_bot_dly [0:STAGGER-1];
    logic                 load_en_dly    [0:STAGGER-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < STAGGER; s++) begin
                data_bot_dly[s]   <= '0;
                sh_exp_bot_dly[s] <= '0;
                load_en_dly[s]    <= 1'b0;
            end
        end else begin
            data_bot_dly[0]   <= data_unpacked[1];
            sh_exp_bot_dly[0] <= shared_exponent_i;
            load_en_dly[0]    <= load_en_i;
            for (int s = 1; s < STAGGER; s++) begin
                data_bot_dly[s]   <= data_bot_dly[s-1];
                sh_exp_bot_dly[s] <= sh_exp_bot_dly[s-1];
                load_en_dly[s]    <= load_en_dly[s-1];
            end
        end
    end

    logic [31:0] fp32_dot_out_col1_top;
    logic [31:0] fp32_dot_out_col2_top;
    logic [31:0] fp32_cascade_out_col1_top;
    logic [31:0] fp32_cascade_out_col2_top;
    logic [3:0] fp32_flags_col1_top;
    logic [3:0] fp32_flags_col2_top;

    // Top of the chain PE
    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_top (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_i),
        .data_i(data_unpacked[0]),
        .shared_exponent_i(shared_exponent_i),
        .fp32_cascade_in_col1_i('0),
        .fp32_cascade_in_col2_i('0),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_top),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_top),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_top),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_top),
        .fp32_flags_col1_o(fp32_flags_col1_top),
        .fp32_flags_col2_o(fp32_flags_col2_top)
    );

    logic [31:0] fp32_dot_out_col1_bot;
    logic [31:0] fp32_dot_out_col2_bot;
    logic [31:0] fp32_cascade_out_col1_bot;
    logic [31:0] fp32_cascade_out_col2_bot;
    logic [3:0] fp32_flags_col1_bot;
    logic [3:0] fp32_flags_col2_bot;

    // Bottom PE
    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_bot (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_dly[STAGGER-1]),
        .data_i(data_bot_dly[STAGGER-1]),
        .shared_exponent_i(sh_exp_bot_dly[STAGGER-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_top),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_top),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_bot),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_bot),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_bot),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_bot),
        .fp32_flags_col1_o(fp32_flags_col1_bot),
        .fp32_flags_col2_o(fp32_flags_col2_bot)
    );

    // Assign outputs
    assign fp32_dot_out_col1_o = fp32_dot_out_col1_bot;
    assign fp32_dot_out_col2_o = fp32_dot_out_col2_bot;
    assign fp32_flags_col1_o = fp32_flags_col1_bot;
    assign fp32_flags_col2_o = fp32_flags_col2_bot;

endmodule