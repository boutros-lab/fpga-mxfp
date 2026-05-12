// //////////////////////////////////////////////////////////////////////////////////////
// Module: mxfp_dot_prop_mxfp6
//
// Description:
// MXFP6 dot product unit instantiating 3 of our proposed DSP blocks, 
// each perform a dot-12 E2M3 or E3M2 dot product.
//
// Parameters:
//  Default parameter values are the correct values.
// - MODE: used by our DSP block to select the appropriate configuration according to the MXFP format.
// - IS_SIM: passed to fp_aitb_proposed.
// - LAT_AITB: the latency of a single DSP block in tensor block mode. Used to match valid signal's latency
//   to the latency of the computation.
// - E: exponent width of selected MXFP format.
// - M: mantissa width of selected MXFP format.
// - E_SHARED: shared exponent widht of MXFP format.
// - DOT_LEN: length of dot product being implemented.
// //////////////////////////////////////////////////////////////////////////////////////

import pkg_aitb::*;

module mxfp_dot_prop_mxfp6 #(
    parameter mxfp_mode_e MODE = MXFP6_23,
    parameter bit IS_SIM = 1,
    // Latency of 1 AITB
    parameter int LAT_AITB = 5,
    parameter E = 2,
    parameter M = 3,
	parameter E_SHARED = 8,
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
    // 3 AITBs, each support up to 12 inputs.
    localparam int NUM_AITBS = 3;
    localparam int ELEMS_PER_AITB = 12;
    localparam int DATA_W = M + E + 1;

    // Each DSP needs its inputs delayed by 2 cycles compared to the one above
    localparam int STAGGER = 2;

    // Total latency: top DSP takes LAT_AITB cycles, each additional
    // DSP adds STAGGER cycles.
    localparam int LAT = LAT_AITB + (NUM_AITBS - 1) * STAGGER;

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
    // First 2 AITBs will operate on 12 elements. The last one 8.
    genvar i;
    generate
    for (i = 0; i < DOT_LEN; i++) begin : unpack
        localparam int aitb_idx = i / ELEMS_PER_AITB;
        localparam int word_idx = i % ELEMS_PER_AITB;
        assign data_unpacked[aitb_idx][word_idx*DATA_W +: DATA_W] = mx_data_in_i[i];
    end
    endgenerate
    // Zero out unused bits
    assign data_unpacked[0][79:ELEMS_PER_AITB*DATA_W] = '0;
    assign data_unpacked[1][79:ELEMS_PER_AITB*DATA_W] = '0;
    localparam int BOT_ELEMS = DOT_LEN - 2 * ELEMS_PER_AITB;  // 8
    assign data_unpacked[2][79:BOT_ELEMS*DATA_W] = '0;

    // Delay inputs to middle and bottom DSPs
    localparam int MID_DELAY = STAGGER;          // 2 cycles
    localparam int BOT_DELAY = 2 * STAGGER;      // 4 cycles
    // Mid delay line
    logic [79:0]          data_mid_dly   [0:MID_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_mid_dly [0:MID_DELAY-1];
    logic                 load_en_mid_dly[0:MID_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < MID_DELAY; s++) begin
                data_mid_dly[s]    <= '0;
                sh_exp_mid_dly[s]  <= '0;
                load_en_mid_dly[s] <= 1'b0;
            end
        end else begin
            data_mid_dly[0]    <= data_unpacked[1];
            sh_exp_mid_dly[0]  <= shared_exponent_i;
            load_en_mid_dly[0] <= load_en_i;
            for (int s = 1; s < MID_DELAY; s++) begin
                data_mid_dly[s]    <= data_mid_dly[s-1];
                sh_exp_mid_dly[s]  <= sh_exp_mid_dly[s-1];
                load_en_mid_dly[s] <= load_en_mid_dly[s-1];
            end
        end
    end

    // Bot delay line
    logic [79:0]          data_bot_dly   [0:BOT_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_bot_dly [0:BOT_DELAY-1];
    logic                 load_en_bot_dly[0:BOT_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < BOT_DELAY; s++) begin
                data_bot_dly[s]    <= '0;
                sh_exp_bot_dly[s]  <= '0;
                load_en_bot_dly[s] <= 1'b0;
            end
        end else begin
            data_bot_dly[0]    <= data_unpacked[2];
            sh_exp_bot_dly[0]  <= shared_exponent_i;
            load_en_bot_dly[0] <= load_en_i;
            for (int s = 1; s < BOT_DELAY; s++) begin
                data_bot_dly[s]    <= data_bot_dly[s-1];
                sh_exp_bot_dly[s]  <= sh_exp_bot_dly[s-1];
                load_en_bot_dly[s] <= load_en_bot_dly[s-1];
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
        .IS_SIM(IS_SIM),
        .CHAIN_MODE("zero_tensor_chain_output")
    ) aitb_top (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b1),
        .load_en_i(load_en_i),
        .data_i(data_unpacked[0]),
        .shared_exponent_i(shared_exponent_i),
        //.fp32_cascade_in_col1_i('0),
        //.fp32_cascade_in_col2_i('0),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_top),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_top),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_top),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_top),
        .fp32_flags_col1_o(fp32_flags_col1_top),
        .fp32_flags_col2_o(fp32_flags_col2_top)
    );

    // Mid PE
    logic [31:0] fp32_dot_out_col1_mid;
    logic [31:0] fp32_dot_out_col2_mid;
    logic [31:0] fp32_cascade_out_col1_mid;
    logic [31:0] fp32_cascade_out_col2_mid;
    logic [3:0]  fp32_flags_col1_mid;
    logic [3:0]  fp32_flags_col2_mid;

    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_mid (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_mid_dly[MID_DELAY-1]),
        .data_i(data_mid_dly[MID_DELAY-1]),
        .shared_exponent_i(sh_exp_mid_dly[MID_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_top),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_top),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_mid),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_mid),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_mid),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_mid),
        .fp32_flags_col1_o(fp32_flags_col1_mid),
        .fp32_flags_col2_o(fp32_flags_col2_mid)
    );
    
    // Bot PE
    logic [31:0] fp32_dot_out_col1_bot;
    logic [31:0] fp32_dot_out_col2_bot;
    logic [31:0] fp32_cascade_out_col1_bot;
    logic [31:0] fp32_cascade_out_col2_bot;
    logic [3:0] fp32_flags_col1_bot;
    logic [3:0] fp32_flags_col2_bot;

    // Bot PE
    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_bot (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_bot_dly[BOT_DELAY-1]),
        .data_i(data_bot_dly[BOT_DELAY-1]),
        .shared_exponent_i(sh_exp_bot_dly[BOT_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_mid),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_mid),
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