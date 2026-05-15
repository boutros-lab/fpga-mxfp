/*
* No E5M2 implementation of MXFP AITB
*/

import pkg_aitb::*;

module noe5m2_mxfp_aitb_comp_top #(
	parameter FIXED_INPUTS = FIXED_ELEMENTS
)(
	input logic clk,
	input logic rst,
	input logic acc_en,
	input logic zero_en,
	input logic load_bb_one,
	input logic load_bb_two,
	input logic load_buf_sel,

	input mxfp_mode_e i_mxfp_mode,

	input logic [FLAT_DATA_WIDTH-1:0] data_in,
	input logic [7:0] shared_exponent,
	input logic [31:0] fp32_cascade_in_col1,
	input logic [31:0] fp32_cascade_in_col2,

	output logic [31:0] fp32_dot_out_col1,
	output logic [31:0] fp32_dot_out_col2,
	output logic [31:0] fp32_cascade_out_col1,
	output logic [31:0] fp32_cascade_out_col2,
	output logic [3:0]  fp32_flags_col1,
	output logic [3:0]  fp32_flags_col2

);
localparam MXFP8_MAX_EXP      = 4;
localparam FIXED_RESULT_WIDTH = (1 + 2*((1 << 4) + 3 - 1)) + $clog2(MXFP8_ELEMENTS); // 40

// Input
logic [FLAT_DATA_WIDTH-1:0] data_in_pipe;
logic [SH_EXP_WIDTH-1:0]    data_in_sh_exp_pipe;
logic [SH_EXP_WIDTH-1:0]    data_in_sh_exp_pipe2;
logic [SH_EXP_WIDTH-1:0]    data_in_sh_exp_pipe3;
logic [FLAT_DATA_WIDTH-1:0] w_reg_c1;
logic [SH_EXP_WIDTH-1:0]    w_reg_c1_sh_exp;
logic [SH_EXP_WIDTH-1:0]    w_reg_c1_sh_exp_pipe2;
logic [SH_EXP_WIDTH-1:0]    w_reg_c1_sh_exp_pipe3;
logic [FLAT_DATA_WIDTH-1:0] w_reg_c2;
logic [SH_EXP_WIDTH-1:0]    w_reg_c2_sh_exp;
logic [SH_EXP_WIDTH-1:0]    w_reg_c2_sh_exp_pipe2;
logic [SH_EXP_WIDTH-1:0]    w_reg_c2_sh_exp_pipe3;

// Unpacked data
logic                     mxfp8_sign_c1      [MXFP8_ELEMENTS];
logic                     mxfp8_sign_c2      [MXFP8_ELEMENTS];
logic                     mxfp8_sign_data_in [MXFP8_ELEMENTS];
logic [MXFP8_MAX_EXP-1:0] mxfp8_exp_c1       [MXFP8_ELEMENTS];
logic [MXFP8_MAX_EXP-1:0] mxfp8_exp_c2       [MXFP8_ELEMENTS];
logic [MXFP8_MAX_EXP-1:0] mxfp8_exp_data_in  [MXFP8_ELEMENTS];
logic [MXFP8_MAX_MAN:0]   mxfp8_sig_c1       [MXFP8_ELEMENTS];
logic [MXFP8_MAX_MAN:0]   mxfp8_sig_c2       [MXFP8_ELEMENTS];
logic [MXFP8_MAX_MAN:0]   mxfp8_sig_data_in  [MXFP8_ELEMENTS];

logic                     mxfp6_sign_c1      [MXFP6_ELEMENTS];
logic                     mxfp6_sign_c2      [MXFP6_ELEMENTS];
logic                     mxfp6_sign_data_in [MXFP6_ELEMENTS];
logic [MXFP6_MAX_EXP-1:0] mxfp6_exp_c1       [MXFP6_ELEMENTS];
logic [MXFP6_MAX_EXP-1:0] mxfp6_exp_c2       [MXFP6_ELEMENTS];
logic [MXFP6_MAX_EXP-1:0] mxfp6_exp_data_in  [MXFP6_ELEMENTS];
logic [MXFP6_MAX_MAN:0]   mxfp6_sig_c1       [MXFP6_ELEMENTS];
logic [MXFP6_MAX_MAN:0]   mxfp6_sig_c2       [MXFP6_ELEMENTS];
logic [MXFP6_MAX_MAN:0]   mxfp6_sig_data_in  [MXFP6_ELEMENTS];

logic                     mxfp4_sign_c1      [MXFP4_ELEMENTS];
logic                     mxfp4_sign_c2      [MXFP4_ELEMENTS];
logic                     mxfp4_sign_data_in [MXFP4_ELEMENTS];
logic [MXFP4_MAX_EXP-1:0] mxfp4_exp_c1       [MXFP4_ELEMENTS];
logic [MXFP4_MAX_EXP-1:0] mxfp4_exp_c2       [MXFP4_ELEMENTS];
logic [MXFP4_MAX_EXP-1:0] mxfp4_exp_data_in  [MXFP4_ELEMENTS];
logic [MXFP4_MAX_MAN:0]   mxfp4_sig_c1       [MXFP4_ELEMENTS];
logic [MXFP4_MAX_MAN:0]   mxfp4_sig_c2       [MXFP4_ELEMENTS];
logic [MXFP4_MAX_MAN:0]   mxfp4_sig_data_in  [MXFP4_ELEMENTS];

//      After pipe stage 2
logic                     mxfp8_sign_c1_pipe      [MXFP8_ELEMENTS];
logic                     mxfp8_sign_c2_pipe      [MXFP8_ELEMENTS];
logic                     mxfp8_sign_data_in_pipe [MXFP8_ELEMENTS];
logic [MXFP8_MAX_EXP-1:0] mxfp8_exp_c1_pipe       [MXFP8_ELEMENTS];
logic [MXFP8_MAX_EXP-1:0] mxfp8_exp_c2_pipe       [MXFP8_ELEMENTS];
logic [MXFP8_MAX_EXP-1:0] mxfp8_exp_data_in_pipe  [MXFP8_ELEMENTS];
logic [MXFP8_MAX_MAN:0]   mxfp8_sig_c1_pipe       [MXFP8_ELEMENTS];
logic [MXFP8_MAX_MAN:0]   mxfp8_sig_c2_pipe       [MXFP8_ELEMENTS];
logic [MXFP8_MAX_MAN:0]   mxfp8_sig_data_in_pipe  [MXFP8_ELEMENTS];

logic                     mxfp6_sign_c1_pipe      [MXFP6_ELEMENTS];
logic                     mxfp6_sign_c2_pipe      [MXFP6_ELEMENTS];
logic                     mxfp6_sign_data_in_pipe [MXFP6_ELEMENTS];
logic [MXFP6_MAX_EXP-1:0] mxfp6_exp_c1_pipe       [MXFP6_ELEMENTS];
logic [MXFP6_MAX_EXP-1:0] mxfp6_exp_c2_pipe       [MXFP6_ELEMENTS];
logic [MXFP6_MAX_EXP-1:0] mxfp6_exp_data_in_pipe  [MXFP6_ELEMENTS];
logic [MXFP6_MAX_MAN:0]   mxfp6_sig_c1_pipe       [MXFP6_ELEMENTS];
logic [MXFP6_MAX_MAN:0]   mxfp6_sig_c2_pipe       [MXFP6_ELEMENTS];
logic [MXFP6_MAX_MAN:0]   mxfp6_sig_data_in_pipe  [MXFP6_ELEMENTS];

logic                     mxfp4_sign_c1_pipe      [MXFP4_ELEMENTS];
logic                     mxfp4_sign_c2_pipe      [MXFP4_ELEMENTS];
logic                     mxfp4_sign_data_in_pipe [MXFP4_ELEMENTS];
logic [MXFP4_MAX_EXP-1:0] mxfp4_exp_c1_pipe       [MXFP4_ELEMENTS];
logic [MXFP4_MAX_EXP-1:0] mxfp4_exp_c2_pipe       [MXFP4_ELEMENTS];
logic [MXFP4_MAX_EXP-1:0] mxfp4_exp_data_in_pipe  [MXFP4_ELEMENTS];
logic [MXFP4_MAX_MAN:0]   mxfp4_sig_c1_pipe       [MXFP4_ELEMENTS];
logic [MXFP4_MAX_MAN:0]   mxfp4_sig_c2_pipe       [MXFP4_ELEMENTS];
logic [MXFP4_MAX_MAN:0]   mxfp4_sig_data_in_pipe  [MXFP4_ELEMENTS];

// Dot Product
logic signed [FIXED_RESULT_WIDTH-1:0] dot_out_col1;
logic signed [FIXED_RESULT_WIDTH-1:0] dot_out_col2;
logic signed [FIXED_RESULT_WIDTH-1:0] dot_out_col1_pipe;
logic signed [FIXED_RESULT_WIDTH-1:0] dot_out_col2_pipe;
logic signed [FIXED_RESULT_WIDTH-1:0] adder_out_col1;
logic signed [FIXED_RESULT_WIDTH-1:0] adder_out_col2;

// Fix2Float
logic [31:0] fix2float_out_col1;
logic [31:0] fix2float_out_col2;
logic [31:0] fix2float_out_col1_pipe;
logic [31:0] fix2float_out_col2_pipe;
logic [31:0] fp32_cascade_in_col1_pipe;
logic [31:0] fp32_cascade_in_col2_pipe;
logic [31:0] acc_mux_out_col1;
logic [31:0] acc_mux_out_col2;
logic [31:0] fp32_alu_out_col1;
logic [31:0] fp32_alu_out_col2;

// Configuration
logic signed [7:0] exponent_correction;

config_gen #(
	.FIXED_WIDTH_LOCAL(FIXED_RESULT_WIDTH-1)
) u_config_gen (
	.i_mxfp_mode(i_mxfp_mode),
	.o_sign_shift(),
	.o_exp_bits(),
	.o_man_bits(),
	.o_exp_mask(),
	.o_man_mask(),
	.o_exponent_correction(exponent_correction)
);

// Input register bank
in_reg_bank in_reg_bank (
	.clk(clk),
	.rst(rst),
	.data_in(data_in),
	.data_in_sh_exp(shared_exponent),
	.load_bb_one(load_bb_one),
	.load_bb_two(load_bb_two),
	.load_buf_sel(load_buf_sel),
	.w_reg_c1(w_reg_c1),
	.w_reg_c1_sh_exp(w_reg_c1_sh_exp),
	.w_reg_c2(w_reg_c2),
	.w_reg_c2_sh_exp(w_reg_c2_sh_exp)
);

// Pipe 1 (Input stage)
pipeline #(.W(FLAT_DATA_WIDTH), .STAGES(1)) PIPE_1_data_in (
	.clk(clk),
	.rst(rst),
	.pipe_in(data_in),
	.pipe_out(data_in_pipe)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_1_sh_exp (
	.clk(clk),
	.rst(rst),
	.pipe_in(shared_exponent),
	.pipe_out(data_in_sh_exp_pipe)
);

// Arrange flat input into unpacked arrays
noe5m2_input_preparation_mxfp_comp #(
	.FLAT_WIDTH(FLAT_DATA_WIDTH), 
	.FIXED_WIDTH(FIXED_DATA_WIDTH),
	.FIXED_ELEMENTS(FIXED_INPUTS),
	.FP8_ELEMENTS(MXFP8_ELEMENTS),
	.FP6_ELEMENTS(MXFP6_ELEMENTS),
	.FP4_ELEMENTS(MXFP4_ELEMENTS)
) u_noe5m2_input_preparation_col1 (
	.i_mxfp_mode(i_mxfp_mode),
	.i_flat(w_reg_c1),

	.o_fp8_sign(mxfp8_sign_c1),
	.o_fp8_exp(mxfp8_exp_c1),
	.o_fp8_sig(mxfp8_sig_c1),

	.o_fp6_sign(mxfp6_sign_c1),
	.o_fp6_exp(mxfp6_exp_c1),
	.o_fp6_sig(mxfp6_sig_c1),

	.o_fp4_sign(mxfp4_sign_c1),
	.o_fp4_exp(mxfp4_exp_c1),
	.o_fp4_sig(mxfp4_sig_c1)
);

noe5m2_input_preparation_mxfp_comp #(
	.FLAT_WIDTH(FLAT_DATA_WIDTH), 
	.FIXED_WIDTH(FIXED_DATA_WIDTH),
	.FIXED_ELEMENTS(FIXED_INPUTS),
	.FP8_ELEMENTS(MXFP8_ELEMENTS),
	.FP6_ELEMENTS(MXFP6_ELEMENTS),
	.FP4_ELEMENTS(MXFP4_ELEMENTS)
) u_noe5m2_input_preparation_col2 (
	.i_mxfp_mode(i_mxfp_mode),
	.i_flat(w_reg_c2),

	.o_fp8_sign(mxfp8_sign_c2),
	.o_fp8_exp(mxfp8_exp_c2),
	.o_fp8_sig(mxfp8_sig_c2),

	.o_fp6_sign(mxfp6_sign_c2),
	.o_fp6_exp(mxfp6_exp_c2),
	.o_fp6_sig(mxfp6_sig_c2),

	.o_fp4_sign(mxfp4_sign_c2),
	.o_fp4_exp(mxfp4_exp_c2),
	.o_fp4_sig(mxfp4_sig_c2)
);

noe5m2_input_preparation_mxfp_comp #(
	.FLAT_WIDTH(FLAT_DATA_WIDTH), 
	.FIXED_WIDTH(FIXED_DATA_WIDTH),
	.FIXED_ELEMENTS(FIXED_INPUTS),
	.FP8_ELEMENTS(MXFP8_ELEMENTS),
	.FP6_ELEMENTS(MXFP6_ELEMENTS),
	.FP4_ELEMENTS(MXFP4_ELEMENTS)
) u_noe5m2_input_preparation_data_in (
	.i_mxfp_mode(i_mxfp_mode),
	.i_flat(data_in_pipe),

	.o_fp8_sign(mxfp8_sign_data_in),
	.o_fp8_exp(mxfp8_exp_data_in),
	.o_fp8_sig(mxfp8_sig_data_in),

	.o_fp6_sign(mxfp6_sign_data_in),
	.o_fp6_exp(mxfp6_exp_data_in),
	.o_fp6_sig(mxfp6_sig_data_in),

	.o_fp4_sign(mxfp4_sign_data_in),
	.o_fp4_exp(mxfp4_exp_data_in),
	.o_fp4_sig(mxfp4_sig_data_in)
);

// Pipe 2
generate
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			mxfp8_sign_c1_pipe      <= '{default: 'b0};
			mxfp8_sign_c2_pipe      <= '{default: 'b0};
			mxfp8_sign_data_in_pipe <= '{default: 'b0};
			mxfp8_exp_c1_pipe       <= '{default: 'b0};
			mxfp8_exp_c2_pipe       <= '{default: 'b0};
			mxfp8_exp_data_in_pipe  <= '{default: 'b0};
			mxfp8_sig_c1_pipe       <= '{default: 'b0};
			mxfp8_sig_c2_pipe       <= '{default: 'b0};
			mxfp8_sig_data_in_pipe  <= '{default: 'b0};
			
			mxfp6_sign_c1_pipe      <= '{default: 'b0};
			mxfp6_sign_c2_pipe      <= '{default: 'b0};
			mxfp6_sign_data_in_pipe <= '{default: 'b0};
			mxfp6_exp_c1_pipe       <= '{default: 'b0};
			mxfp6_exp_c2_pipe       <= '{default: 'b0};
			mxfp6_exp_data_in_pipe  <= '{default: 'b0};
			mxfp6_sig_c1_pipe       <= '{default: 'b0};
			mxfp6_sig_c2_pipe       <= '{default: 'b0};
			mxfp6_sig_data_in_pipe  <= '{default: 'b0};
			
			mxfp4_sign_c1_pipe      <= '{default: 'b0};
			mxfp4_sign_c2_pipe      <= '{default: 'b0};
			mxfp4_sign_data_in_pipe <= '{default: 'b0};
			mxfp4_exp_c1_pipe       <= '{default: 'b0};
			mxfp4_exp_c2_pipe       <= '{default: 'b0};
			mxfp4_exp_data_in_pipe  <= '{default: 'b0};
			mxfp4_sig_c1_pipe       <= '{default: 'b0};
			mxfp4_sig_c2_pipe       <= '{default: 'b0};
			mxfp4_sig_data_in_pipe  <= '{default: 'b0};
		end else begin
			mxfp8_sign_c1_pipe      <= mxfp8_sign_c1;
			mxfp8_sign_c2_pipe      <= mxfp8_sign_c2;
			mxfp8_sign_data_in_pipe <= mxfp8_sign_data_in;
			mxfp8_exp_c1_pipe       <= mxfp8_exp_c1;
			mxfp8_exp_c2_pipe       <= mxfp8_exp_c2;
			mxfp8_exp_data_in_pipe  <= mxfp8_exp_data_in;
			mxfp8_sig_c1_pipe       <= mxfp8_sig_c1;
			mxfp8_sig_c2_pipe       <= mxfp8_sig_c2;
			mxfp8_sig_data_in_pipe  <= mxfp8_sig_data_in;
			                           
			mxfp6_sign_c1_pipe      <= mxfp6_sign_c1;
			mxfp6_sign_c2_pipe      <= mxfp6_sign_c2;
			mxfp6_sign_data_in_pipe <= mxfp6_sign_data_in;
			mxfp6_exp_c1_pipe       <= mxfp6_exp_c1;
			mxfp6_exp_c2_pipe       <= mxfp6_exp_c2;
			mxfp6_exp_data_in_pipe  <= mxfp6_exp_data_in;
			mxfp6_sig_c1_pipe       <= mxfp6_sig_c1;
			mxfp6_sig_c2_pipe       <= mxfp6_sig_c2;
			mxfp6_sig_data_in_pipe  <= mxfp6_sig_data_in;
			                           
			mxfp4_sign_c1_pipe      <= mxfp4_sign_c1;
			mxfp4_sign_c2_pipe      <= mxfp4_sign_c2;
			mxfp4_sign_data_in_pipe <= mxfp4_sign_data_in;
			mxfp4_exp_c1_pipe       <= mxfp4_exp_c1;
			mxfp4_exp_c2_pipe       <= mxfp4_exp_c2;
			mxfp4_exp_data_in_pipe  <= mxfp4_exp_data_in;
			mxfp4_sig_c1_pipe       <= mxfp4_sig_c1;
			mxfp4_sig_c2_pipe       <= mxfp4_sig_c2;
			mxfp4_sig_data_in_pipe  <= mxfp4_sig_data_in;
		end
	end
endgenerate

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_2_sh_exp (
	.clk(clk),
	.rst(rst),
	.pipe_in(data_in_sh_exp_pipe),
	.pipe_out(data_in_sh_exp_pipe2)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_2_w_reg_c1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c1_sh_exp),
	.pipe_out(w_reg_c1_sh_exp_pipe2)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_2_w_reg_c2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c2_sh_exp),
	.pipe_out(w_reg_c2_sh_exp_pipe2)
);

// Dot engine (out: 70b vector)
noe5m2_mxfp_comp_dot_fixed #(
	.FIXED_DOT_LENGTH(FIXED_INPUTS)
) u_noe5m2_mxfp_comp_dot_fixed_col1 (
	.i_mxfp_mode(i_mxfp_mode),

	.i_mxfp8_sign_a(mxfp8_sign_data_in_pipe),
	.i_mxfp8_sign_b(mxfp8_sign_c1_pipe),
	.i_mxfp8_exp_a(mxfp8_exp_data_in_pipe),
	.i_mxfp8_exp_b(mxfp8_exp_c1_pipe),
	.i_mxfp8_sig_a(mxfp8_sig_data_in_pipe),
	.i_mxfp8_sig_b(mxfp8_sig_c1_pipe),

	.i_mxfp6_sign_a(mxfp6_sign_data_in_pipe),
	.i_mxfp6_sign_b(mxfp6_sign_c1_pipe),
	.i_mxfp6_exp_a(mxfp6_exp_data_in_pipe),
	.i_mxfp6_exp_b(mxfp6_exp_c1_pipe),
	.i_mxfp6_sig_a(mxfp6_sig_data_in_pipe),
	.i_mxfp6_sig_b(mxfp6_sig_c1_pipe),

	.i_mxfp4_sign_a(mxfp4_sign_data_in_pipe),
	.i_mxfp4_sign_b(mxfp4_sign_c1_pipe),
	.i_mxfp4_exp_a(mxfp4_exp_data_in_pipe),
	.i_mxfp4_exp_b(mxfp4_exp_c1_pipe),
	.i_mxfp4_sig_a(mxfp4_sig_data_in_pipe),
	.i_mxfp4_sig_b(mxfp4_sig_c1_pipe),

	.o_fixed_result(dot_out_col1)
);

noe5m2_mxfp_comp_dot_fixed #(
	.FIXED_DOT_LENGTH(FIXED_INPUTS)
) u_noe5m2_mxfp_comp_dot_fixed_col2 (
	.i_mxfp_mode(i_mxfp_mode),

	.i_mxfp8_sign_a(mxfp8_sign_data_in_pipe),
	.i_mxfp8_sign_b(mxfp8_sign_c2_pipe),
	.i_mxfp8_exp_a(mxfp8_exp_data_in_pipe),
	.i_mxfp8_exp_b(mxfp8_exp_c2_pipe),
	.i_mxfp8_sig_a(mxfp8_sig_data_in_pipe),
	.i_mxfp8_sig_b(mxfp8_sig_c2_pipe),

	.i_mxfp6_sign_a(mxfp6_sign_data_in_pipe),
	.i_mxfp6_sign_b(mxfp6_sign_c2_pipe),
	.i_mxfp6_exp_a(mxfp6_exp_data_in_pipe),
	.i_mxfp6_exp_b(mxfp6_exp_c2_pipe),
	.i_mxfp6_sig_a(mxfp6_sig_data_in_pipe),
	.i_mxfp6_sig_b(mxfp6_sig_c2_pipe),

	.i_mxfp4_sign_a(mxfp4_sign_data_in_pipe),
	.i_mxfp4_sign_b(mxfp4_sign_c2_pipe),
	.i_mxfp4_exp_a(mxfp4_exp_data_in_pipe),
	.i_mxfp4_exp_b(mxfp4_exp_c2_pipe),
	.i_mxfp4_sig_a(mxfp4_sig_data_in_pipe),
	.i_mxfp4_sig_b(mxfp4_sig_c2_pipe),

	.o_fixed_result(dot_out_col2)
);

// Pipe 3 (out: 32b extended from the 20b) ?
pipeline #(.W(FIXED_RESULT_WIDTH), .STAGES(1)) PIPE_3_dot_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col1),
	.pipe_out(dot_out_col1_pipe)
);

pipeline #(.W(FIXED_RESULT_WIDTH), .STAGES(1)) PIPE_3_dot_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col2),
	.pipe_out(dot_out_col2_pipe)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_3_in_sh_exp (
	.clk(clk),
	.rst(rst),
	.pipe_in(data_in_sh_exp_pipe2),
	.pipe_out(data_in_sh_exp_pipe3)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_3_w_reg_c1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c1_sh_exp_pipe2),
	.pipe_out(w_reg_c1_sh_exp_pipe3)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_3_w_reg_c2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c2_sh_exp_pipe2),
	.pipe_out(w_reg_c2_sh_exp_pipe3)
);

// CPA Adder (used for FXP Tensor Mode but in this datapath nonetheless)
assign adder_out_col1 = dot_out_col1_pipe + '0; // TODO, not sure what to do about this
assign adder_out_col2 = dot_out_col2_pipe + '0;

// FXP to FP32
config_fix2fp32  #(
	.INPUT_WIDTH(FIXED_RESULT_WIDTH)
) u_fix2fp32_col1 (
	.i_exponent_correction(exponent_correction),
	.i_fixed(adder_out_col1),
	.i_shared_exp_a(data_in_sh_exp_pipe3),
	.i_shared_exp_b(w_reg_c1_sh_exp_pipe3),
	.o_fp(fix2float_out_col1)
);

config_fix2fp32  #(
	.INPUT_WIDTH(FIXED_RESULT_WIDTH)
) u_fix2fp32_col2 (
	.i_exponent_correction(exponent_correction),
	.i_fixed(adder_out_col2),
	.i_shared_exp_a(data_in_sh_exp_pipe3),
	.i_shared_exp_b(w_reg_c2_sh_exp_pipe3),
	.o_fp(fix2float_out_col2)
);

// Pipe 4
pipeline #(.W(32), .STAGES(1)) PIPE_3_fix2float_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fix2float_out_col1),
	.pipe_out(fix2float_out_col1_pipe)
);
pipeline #(.W(32), .STAGES(1)) PIPE_3_fix2float_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fix2float_out_col2),
	.pipe_out(fix2float_out_col2_pipe)
);

pipeline #(.W(32), .STAGES(1)) PIPE_cascade_in_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fp32_cascade_in_col1),
	.pipe_out(fp32_cascade_in_col1_pipe)
);
pipeline #(.W(32), .STAGES(1)) PIPE_cascade_in_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fp32_cascade_in_col2),
	.pipe_out(fp32_cascade_in_col2_pipe)
);

always_comb begin
	case({zero_en, acc_en})
		2'b00: begin
			acc_mux_out_col1 = fp32_cascade_in_col1_pipe;
			acc_mux_out_col2 = fp32_cascade_in_col2_pipe;
		end
		2'b01: begin
			acc_mux_out_col1 = fp32_dot_out_col1;
			acc_mux_out_col2 = fp32_dot_out_col2;
		end
		2'b10,
		2'b11: begin
			acc_mux_out_col1 = '0;
			acc_mux_out_col2 = '0;
		end
	endcase
end

// FP32 ALU
ieee_fp32_add FP32_ALU_col1 (
	.X(fix2float_out_col1_pipe),
	.Y(acc_mux_out_col1),
	.R(fp32_alu_out_col1)
);

ieee_fp32_add FP32_ALU_col2 (
	.X(fix2float_out_col2_pipe),
	.Y(acc_mux_out_col2),
	.R(fp32_alu_out_col2)
);

// Pipe 5 (Output)
pipeline #(.W(32), .STAGES(1)) PIPE_OUT_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fp32_alu_out_col1),
	.pipe_out(fp32_dot_out_col1)
);

pipeline #(.W(32), .STAGES(1)) PIPE_OUT_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fp32_alu_out_col2),
	.pipe_out(fp32_dot_out_col2)
);

assign fp32_cascade_out_col1 = fp32_dot_out_col1;
assign fp32_cascade_out_col2 = fp32_dot_out_col2;

endmodule 
