import pkg_aitb::*;

module mxfp_dot_prop_mxfp6_e3m2_fix #(
    parameter mxfp_mode_e MODE = MXFP6_32,
    parameter bit IS_SIM = 1,
    // Latency of 1 AITB
    parameter int LAT_AITB = 5,
    parameter E = 3,
    parameter M = 2,
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
    // 4 AITBs, each support up to 8 inputs.
    localparam int NUM_AITBS = 4;
    localparam int ELEMS_PER_AITB = 8;
    // For mxfp2fix
    // 10
    localparam int FIX_OUT_WIDTH = (1 << E) + M;

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


    // Instantiate mxfp2fix
    logic signed [FIX_OUT_WIDTH-1:0] fix_data [0:DOT_LEN-1];
    logic [E_SHARED-1:0] adjusted_sh_exp;

    mxfp2fix #(
        .E(E),
        .M(M),
        .FIX_OUT_WIDTH(FIX_OUT_WIDTH)
    ) u_mxfp2fix (
        .i_mxfp(mx_data_in_i),
        .i_sh_exp(shared_exponent_i),
        .o_fix(fix_data),
        .o_sh_exp(adjusted_sh_exp)
    );
    
    // Pack the fixed point (8 elements per AITB)
    logic [79:0] data_unpacked [0:NUM_AITBS-1];
    
    genvar i;
    generate
    for (i = 0; i < DOT_LEN; i++) begin : pack_fix
        localparam int aitb_idx = i / ELEMS_PER_AITB;
        localparam int word_idx = i % ELEMS_PER_AITB;
        assign data_unpacked[aitb_idx][word_idx*FIX_OUT_WIDTH +: FIX_OUT_WIDTH] = fix_data[i];
    end
    endgenerate

    // Delay inputs to the DSPs
    localparam int MID_HI_DELAY = STAGGER; // 2 cycles
    localparam int MID_LO_DELAY = 2 * STAGGER; // 4 cycles
    localparam int BOT_DELAY = 3 * STAGGER; // 6 cycles
    // Mid-hi delay line
    logic [79:0]          data_mid_hi_dly   [0:MID_HI_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_mid_hi_dly [0:MID_HI_DELAY-1];
    logic                 load_en_mid_hi_dly[0:MID_HI_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < MID_HI_DELAY; s++) begin
                data_mid_hi_dly[s]    <= '0;
                sh_exp_mid_hi_dly[s]  <= '0;
                load_en_mid_hi_dly[s] <= 1'b0;
            end
        end else begin
            data_mid_hi_dly[0]    <= data_unpacked[1];
            sh_exp_mid_hi_dly[0]  <= adjusted_sh_exp;
            load_en_mid_hi_dly[0] <= load_en_i;
            for (int s = 1; s < MID_HI_DELAY; s++) begin
                data_mid_hi_dly[s]    <= data_mid_hi_dly[s-1];
                sh_exp_mid_hi_dly[s]  <= sh_exp_mid_hi_dly[s-1];
                load_en_mid_hi_dly[s] <= load_en_mid_hi_dly[s-1];
            end
        end
    end

    // Mid-lo delay line
    logic [79:0]          data_mid_lo_dly   [0:MID_LO_DELAY-1];
    logic [E_SHARED-1:0]  sh_exp_mid_lo_dly [0:MID_LO_DELAY-1];
    logic                 load_en_mid_lo_dly[0:MID_LO_DELAY-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < MID_LO_DELAY; s++) begin
                data_mid_lo_dly[s]    <= '0;
                sh_exp_mid_lo_dly[s]  <= '0;
                load_en_mid_lo_dly[s] <= 1'b0;
            end
        end else begin
            data_mid_lo_dly[0]    <= data_unpacked[2];
            sh_exp_mid_lo_dly[0]  <= adjusted_sh_exp;
            load_en_mid_lo_dly[0] <= load_en_i;
            for (int s = 1; s < MID_LO_DELAY; s++) begin
                data_mid_lo_dly[s]    <= data_mid_lo_dly[s-1];
                sh_exp_mid_lo_dly[s]  <= sh_exp_mid_lo_dly[s-1];
                load_en_mid_lo_dly[s] <= load_en_mid_lo_dly[s-1];
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
            data_bot_dly[0]    <= data_unpacked[3];
            sh_exp_bot_dly[0]  <= adjusted_sh_exp;
            load_en_bot_dly[0] <= load_en_i;
            for (int s = 1; s < BOT_DELAY; s++) begin
                data_bot_dly[s]    <= data_bot_dly[s-1];
                sh_exp_bot_dly[s]  <= sh_exp_bot_dly[s-1];
                load_en_bot_dly[s] <= load_en_bot_dly[s-1];
            end
        end
    end

    // Chain the AITBs (top, mid-hi, mid-lo, bot)
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
        .shared_exponent_i(adjusted_sh_exp),
        //.fp32_cascade_in_col1_i('0),
        //.fp32_cascade_in_col2_i('0),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_top),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_top),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_top),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_top),
        .fp32_flags_col1_o(fp32_flags_col1_top),
        .fp32_flags_col2_o(fp32_flags_col2_top)
    );

    // Mid-hi PE
    logic [31:0] fp32_dot_out_col1_mid_hi;
    logic [31:0] fp32_dot_out_col2_mid_hi;
    logic [31:0] fp32_cascade_out_col1_mid_hi;
    logic [31:0] fp32_cascade_out_col2_mid_hi;
    logic [3:0]  fp32_flags_col1_mid_hi;
    logic [3:0]  fp32_flags_col2_mid_hi;

    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_mid_hi (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_mid_hi_dly[MID_HI_DELAY-1]),
        .data_i(data_mid_hi_dly[MID_HI_DELAY-1]),
        .shared_exponent_i(sh_exp_mid_hi_dly[MID_HI_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_top),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_top),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_mid_hi),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_mid_hi),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_mid_hi),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_mid_hi),
        .fp32_flags_col1_o(fp32_flags_col1_mid_hi),
        .fp32_flags_col2_o(fp32_flags_col2_mid_hi)
    );

    // Mid-lo PE
    logic [31:0] fp32_dot_out_col1_mid_lo;
    logic [31:0] fp32_dot_out_col2_mid_lo;
    logic [31:0] fp32_cascade_out_col1_mid_lo;
    logic [31:0] fp32_cascade_out_col2_mid_lo;
    logic [3:0]  fp32_flags_col1_mid_lo;
    logic [3:0]  fp32_flags_col2_mid_lo;

    fp_aitb_proposed #(
        .MODE(MODE),
        .IS_SIM(IS_SIM)
    ) aitb_mid_lo (
        .clk(clk),
        .rst(rst),
        .acc_en_i(1'b0),
        .zero_en_i(1'b0),
        .load_en_i(load_en_mid_lo_dly[MID_LO_DELAY-1]),
        .data_i(data_mid_lo_dly[MID_LO_DELAY-1]),
        .shared_exponent_i(sh_exp_mid_lo_dly[MID_LO_DELAY-1]),
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_mid_hi),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_mid_hi),
        .fp32_dot_out_col1_o(fp32_dot_out_col1_mid_lo),
        .fp32_dot_out_col2_o(fp32_dot_out_col2_mid_lo),
        .fp32_cascade_out_col1_o(fp32_cascade_out_col1_mid_lo),
        .fp32_cascade_out_col2_o(fp32_cascade_out_col2_mid_lo),
        .fp32_flags_col1_o(fp32_flags_col1_mid_lo),
        .fp32_flags_col2_o(fp32_flags_col2_mid_lo)
    );
    
    // Bot PE
    logic [31:0] fp32_dot_out_col1_bot;
    logic [31:0] fp32_dot_out_col2_bot;
    logic [31:0] fp32_cascade_out_col1_bot;
    logic [31:0] fp32_cascade_out_col2_bot;
    logic [3:0] fp32_flags_col1_bot;
    logic [3:0] fp32_flags_col2_bot;

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
        .fp32_cascade_in_col1_i(fp32_cascade_out_col1_mid_lo),
        .fp32_cascade_in_col2_i(fp32_cascade_out_col2_mid_lo),
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
