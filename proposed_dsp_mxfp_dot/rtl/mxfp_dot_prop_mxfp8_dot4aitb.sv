// //////////////////////////////////////////////////////////////////////////////////////
// Module: mxfp_dot_prop_mxfp8_dot4aitb
//
// Description:
// MXFP8 dot product unit instantiating 8 of our proposed DSP blocks, 
// each perform a dot-4 E5M2 dot product.
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

module mxfp_dot_prop_mxfp8_dot4aitb #(
    parameter mxfp_mode_e MODE = MXFP8_52,
    parameter bit IS_SIM = 1,
    // Latency of 1 AITB
    parameter int LAT_AITB = 5,
    parameter E = 5,
    parameter M = 2,
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

    // 8 AITBs, each supports 4 inputs.
    localparam int NUM_AITBS = 8;
    localparam int ELEMS_PER_AITB = 4;
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
    // All AITBs will operate on 4 elements
    genvar i;
    generate
    for (i = 0; i < DOT_LEN; i++) begin : unpack
        localparam int aitb_idx = i / ELEMS_PER_AITB;
        localparam int word_idx = i % ELEMS_PER_AITB;
        assign data_unpacked[aitb_idx][word_idx*DATA_W +: DATA_W] = mx_data_in_i[i];
    end
    endgenerate
    // Zero out unused bits
    generate
    for (genvar a = 0; a < NUM_AITBS; a++) begin : zero_unused
        assign data_unpacked[a][79:ELEMS_PER_AITB*DATA_W] = '0;
    end
    endgenerate

    // Delay inputs to staggered DSPs
    localparam int MID1_DELAY = STAGGER;
    localparam int MID2_DELAY = 2 * STAGGER;
    localparam int MID3_DELAY = 3 * STAGGER;
    localparam int MID4_DELAY = 4 * STAGGER;
    localparam int MID5_DELAY = 5 * STAGGER;
    localparam int MID6_DELAY = 6 * STAGGER;
    localparam int BOT_DELAY  = 7 * STAGGER;
    
    // Mid1 delay line (2 cycles)
    logic [79:0]          data_mid1_dly   [0:MID1_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_mid1_dly [0:MID1_DELAY-1];
    logic                 load_en_mid1_dly[0:MID1_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < MID1_DELAY; s++) begin
                data_mid1_dly[s]    <= '0;
                sh_exp_mid1_dly[s]  <= '0;
                load_en_mid1_dly[s] <= 1'b0;
            end
        end else begin
            data_mid1_dly[0]    <= data_unpacked[1];
            sh_exp_mid1_dly[0]  <= shared_exponent_i;
            load_en_mid1_dly[0] <= load_en_i;
            for (int s = 1; s < MID1_DELAY; s++) begin
                data_mid1_dly[s]    <= data_mid1_dly[s-1];
                sh_exp_mid1_dly[s]  <= sh_exp_mid1_dly[s-1];
                load_en_mid1_dly[s] <= load_en_mid1_dly[s-1];
            end
        end
    end

    // Mid2 delay line (4 cycles)
    logic [79:0]          data_mid2_dly   [0:MID2_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_mid2_dly [0:MID2_DELAY-1];
    logic                 load_en_mid2_dly[0:MID2_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < MID2_DELAY; s++) begin
                data_mid2_dly[s]    <= '0;
                sh_exp_mid2_dly[s]  <= '0;
                load_en_mid2_dly[s] <= 1'b0;
            end
        end else begin
            data_mid2_dly[0]    <= data_unpacked[2];
            sh_exp_mid2_dly[0]  <= shared_exponent_i;
            load_en_mid2_dly[0] <= load_en_i;
            for (int s = 1; s < MID2_DELAY; s++) begin
                data_mid2_dly[s]    <= data_mid2_dly[s-1];
                sh_exp_mid2_dly[s]  <= sh_exp_mid2_dly[s-1];
                load_en_mid2_dly[s] <= load_en_mid2_dly[s-1];
            end
        end
    end

    // Mid3 delay line (6 cycles)
    logic [79:0]          data_mid3_dly   [0:MID3_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_mid3_dly [0:MID3_DELAY-1];
    logic                 load_en_mid3_dly[0:MID3_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < MID3_DELAY; s++) begin
                data_mid3_dly[s]    <= '0;
                sh_exp_mid3_dly[s]  <= '0;
                load_en_mid3_dly[s] <= 1'b0;
            end
        end else begin
            data_mid3_dly[0]    <= data_unpacked[3];
            sh_exp_mid3_dly[0]  <= shared_exponent_i;
            load_en_mid3_dly[0] <= load_en_i;
            for (int s = 1; s < MID3_DELAY; s++) begin
                data_mid3_dly[s]    <= data_mid3_dly[s-1];
                sh_exp_mid3_dly[s]  <= sh_exp_mid3_dly[s-1];
                load_en_mid3_dly[s] <= load_en_mid3_dly[s-1];
            end
        end
    end

    // Mid4 delay line (8 cycles)
    logic [79:0]          data_mid4_dly   [0:MID4_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_mid4_dly [0:MID4_DELAY-1];
    logic                 load_en_mid4_dly[0:MID4_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < MID4_DELAY; s++) begin
                data_mid4_dly[s]    <= '0;
                sh_exp_mid4_dly[s]  <= '0;
                load_en_mid4_dly[s] <= 1'b0;
            end
        end else begin
            data_mid4_dly[0]    <= data_unpacked[4];
            sh_exp_mid4_dly[0]  <= shared_exponent_i;
            load_en_mid4_dly[0] <= load_en_i;
            for (int s = 1; s < MID4_DELAY; s++) begin
                data_mid4_dly[s]    <= data_mid4_dly[s-1];
                sh_exp_mid4_dly[s]  <= sh_exp_mid4_dly[s-1];
                load_en_mid4_dly[s] <= load_en_mid4_dly[s-1];
            end
        end
    end

    // Mid5 delay line (10 cycles)
    logic [79:0]          data_mid5_dly   [0:MID5_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_mid5_dly [0:MID5_DELAY-1];
    logic                 load_en_mid5_dly[0:MID5_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < MID5_DELAY; s++) begin
                data_mid5_dly[s]    <= '0;
                sh_exp_mid5_dly[s]  <= '0;
                load_en_mid5_dly[s] <= 1'b0;
            end
        end else begin
            data_mid5_dly[0]    <= data_unpacked[5];
            sh_exp_mid5_dly[0]  <= shared_exponent_i;
            load_en_mid5_dly[0] <= load_en_i;
            for (int s = 1; s < MID5_DELAY; s++) begin
                data_mid5_dly[s]    <= data_mid5_dly[s-1];
                sh_exp_mid5_dly[s]  <= sh_exp_mid5_dly[s-1];
                load_en_mid5_dly[s] <= load_en_mid5_dly[s-1];
            end
        end
    end

    // Mid6 delay line (12 cycles)
    logic [79:0]          data_mid6_dly   [0:MID6_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_mid6_dly [0:MID6_DELAY-1];
    logic                 load_en_mid6_dly[0:MID6_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < MID6_DELAY; s++) begin
                data_mid6_dly[s]    <= '0;
                sh_exp_mid6_dly[s]  <= '0;
                load_en_mid6_dly[s] <= 1'b0;
            end
        end else begin
            data_mid6_dly[0]    <= data_unpacked[6];
            sh_exp_mid6_dly[0]  <= shared_exponent_i;
            load_en_mid6_dly[0] <= load_en_i;
            for (int s = 1; s < MID6_DELAY; s++) begin
                data_mid6_dly[s]    <= data_mid6_dly[s-1];
                sh_exp_mid6_dly[s]  <= sh_exp_mid6_dly[s-1];
                load_en_mid6_dly[s] <= load_en_mid6_dly[s-1];
            end
        end
    end

    // Bot delay line (14 cycles)
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
            data_bot_dly[0]    <= data_unpacked[7];
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

    // Mid1 PE
    logic [31:0] fp32_dot_out_col1_mid1;
    logic [31:0] fp32_dot_out_col2_mid1;
    logic [31:0] fp32_cascade_out_col1_mid1;
    logic [31:0] fp32_cascade_out_col2_mid1;
    logic [3:0]  fp32_flags_col1_mid1;
    logic [3:0]  fp32_flags_col2_mid1;

    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_mid1 (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_mid1_dly[MID1_DELAY-1]),
        .data_i(data_mid1_dly[MID1_DELAY-1]),
        .shared_exponent_i(sh_exp_mid1_dly[MID1_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_top),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_top),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_mid1),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_mid1),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_mid1),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_mid1),
        .fp32_flags_col1_o(fp32_flags_col1_mid1),
        .fp32_flags_col2_o(fp32_flags_col2_mid1)
    );

    // Mid2 PE
    logic [31:0] fp32_dot_out_col1_mid2;
    logic [31:0] fp32_dot_out_col2_mid2;
    logic [31:0] fp32_cascade_out_col1_mid2;
    logic [31:0] fp32_cascade_out_col2_mid2;
    logic [3:0]  fp32_flags_col1_mid2;
    logic [3:0]  fp32_flags_col2_mid2;

    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_mid2 (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_mid2_dly[MID2_DELAY-1]),
        .data_i(data_mid2_dly[MID2_DELAY-1]),
        .shared_exponent_i(sh_exp_mid2_dly[MID2_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_mid1),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_mid1),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_mid2),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_mid2),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_mid2),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_mid2),
        .fp32_flags_col1_o(fp32_flags_col1_mid2),
        .fp32_flags_col2_o(fp32_flags_col2_mid2)
    );

    // Mid3 PE
    logic [31:0] fp32_dot_out_col1_mid3;
    logic [31:0] fp32_dot_out_col2_mid3;
    logic [31:0] fp32_cascade_out_col1_mid3;
    logic [31:0] fp32_cascade_out_col2_mid3;
    logic [3:0]  fp32_flags_col1_mid3;
    logic [3:0]  fp32_flags_col2_mid3;

    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_mid3 (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_mid3_dly[MID3_DELAY-1]),
        .data_i(data_mid3_dly[MID3_DELAY-1]),
        .shared_exponent_i(sh_exp_mid3_dly[MID3_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_mid2),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_mid2),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_mid3),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_mid3),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_mid3),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_mid3),
        .fp32_flags_col1_o(fp32_flags_col1_mid3),
        .fp32_flags_col2_o(fp32_flags_col2_mid3)
    );

    // Mid4 PE
    logic [31:0] fp32_dot_out_col1_mid4;
    logic [31:0] fp32_dot_out_col2_mid4;
    logic [31:0] fp32_cascade_out_col1_mid4;
    logic [31:0] fp32_cascade_out_col2_mid4;
    logic [3:0]  fp32_flags_col1_mid4;
    logic [3:0]  fp32_flags_col2_mid4;

    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_mid4 (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_mid4_dly[MID4_DELAY-1]),
        .data_i(data_mid4_dly[MID4_DELAY-1]),
        .shared_exponent_i(sh_exp_mid4_dly[MID4_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_mid3),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_mid3),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_mid4),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_mid4),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_mid4),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_mid4),
        .fp32_flags_col1_o(fp32_flags_col1_mid4),
        .fp32_flags_col2_o(fp32_flags_col2_mid4)
    );

    // Mid5 PE
    logic [31:0] fp32_dot_out_col1_mid5;
    logic [31:0] fp32_dot_out_col2_mid5;
    logic [31:0] fp32_cascade_out_col1_mid5;
    logic [31:0] fp32_cascade_out_col2_mid5;
    logic [3:0]  fp32_flags_col1_mid5;
    logic [3:0]  fp32_flags_col2_mid5;

    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_mid5 (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_mid5_dly[MID5_DELAY-1]),
        .data_i(data_mid5_dly[MID5_DELAY-1]),
        .shared_exponent_i(sh_exp_mid5_dly[MID5_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_mid4),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_mid4),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_mid5),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_mid5),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_mid5),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_mid5),
        .fp32_flags_col1_o(fp32_flags_col1_mid5),
        .fp32_flags_col2_o(fp32_flags_col2_mid5)
    );

    // Mid6 PE
    logic [31:0] fp32_dot_out_col1_mid6;
    logic [31:0] fp32_dot_out_col2_mid6;
    logic [31:0] fp32_cascade_out_col1_mid6;
    logic [31:0] fp32_cascade_out_col2_mid6;
    logic [3:0]  fp32_flags_col1_mid6;
    logic [3:0]  fp32_flags_col2_mid6;

    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_mid6 (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_mid6_dly[MID6_DELAY-1]),
        .data_i(data_mid6_dly[MID6_DELAY-1]),
        .shared_exponent_i(sh_exp_mid6_dly[MID6_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_mid5),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_mid5),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_mid6),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_mid6),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_mid6),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_mid6),
        .fp32_flags_col1_o(fp32_flags_col1_mid6),
        .fp32_flags_col2_o(fp32_flags_col2_mid6)
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
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_mid6),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_mid6),
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
