/*
* Naive implementation of MXFP AITB
*/

import pkg_aitb::*;

module naive_mxfp_aitb_top #(
	parameter PACKED_REDUCTION = 0
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
logic signed [FIXED_DATA_WIDTH-1:0] fixed_c1      [FIXED_ELEMENTS];
logic signed [FIXED_DATA_WIDTH-1:0] fixed_c2      [FIXED_ELEMENTS];
logic signed [FIXED_DATA_WIDTH-1:0] fixed_data_in [FIXED_ELEMENTS];
logic        [MXFP8_DATA_WIDTH-1:0] mxfp8_c1      [MXFP8_ELEMENTS];
logic        [MXFP8_DATA_WIDTH-1:0] mxfp8_c2      [MXFP8_ELEMENTS];
logic        [MXFP8_DATA_WIDTH-1:0] mxfp8_data_in [MXFP8_ELEMENTS];
logic        [MXFP6_DATA_WIDTH-1:0] mxfp6_c1      [MXFP6_ELEMENTS];
logic        [MXFP6_DATA_WIDTH-1:0] mxfp6_c2      [MXFP6_ELEMENTS];
logic        [MXFP6_DATA_WIDTH-1:0] mxfp6_data_in [MXFP6_ELEMENTS];
logic        [MXFP4_DATA_WIDTH-1:0] mxfp4_c1      [MXFP4_ELEMENTS];
logic        [MXFP4_DATA_WIDTH-1:0] mxfp4_c2      [MXFP4_ELEMENTS];
logic        [MXFP4_DATA_WIDTH-1:0] mxfp4_data_in [MXFP4_ELEMENTS];

logic signed [FIXED_DATA_WIDTH-1:0] fixed_c1_pipe      [FIXED_ELEMENTS];
logic signed [FIXED_DATA_WIDTH-1:0] fixed_c2_pipe      [FIXED_ELEMENTS];
logic signed [FIXED_DATA_WIDTH-1:0] fixed_data_in_pipe [FIXED_ELEMENTS];
logic        [MXFP8_DATA_WIDTH-1:0] mxfp8_c1_pipe      [MXFP8_ELEMENTS];
logic        [MXFP8_DATA_WIDTH-1:0] mxfp8_c2_pipe      [MXFP8_ELEMENTS];
logic        [MXFP8_DATA_WIDTH-1:0] mxfp8_data_in_pipe [MXFP8_ELEMENTS];
logic        [MXFP6_DATA_WIDTH-1:0] mxfp6_c1_pipe      [MXFP6_ELEMENTS];
logic        [MXFP6_DATA_WIDTH-1:0] mxfp6_c2_pipe      [MXFP6_ELEMENTS];
logic        [MXFP6_DATA_WIDTH-1:0] mxfp6_data_in_pipe [MXFP6_ELEMENTS];
logic        [MXFP4_DATA_WIDTH-1:0] mxfp4_c1_pipe      [MXFP4_ELEMENTS];
logic        [MXFP4_DATA_WIDTH-1:0] mxfp4_c2_pipe      [MXFP4_ELEMENTS];
logic        [MXFP4_DATA_WIDTH-1:0] mxfp4_data_in_pipe [MXFP4_ELEMENTS];

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
logic [2:0] sign_shift;
logic [2:0] exp_bits;
logic [1:0] man_bits;
logic [4:0] exp_mask;
logic [2:0] man_mask;

logic signed [7:0] exponent_correction;

config_gen 
u_config_gen (
	.i_mxfp_mode(i_mxfp_mode),
	.o_sign_shift(sign_shift),
	.o_exp_bits(exp_bits),
	.o_man_bits(man_bits),
	.o_exp_mask(exp_mask),
	.o_man_mask(man_mask),
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
input_preparation_mxfp #(
	.FLAT_WIDTH(FLAT_DATA_WIDTH), 
	.FIXED_WIDTH(FIXED_DATA_WIDTH),
	.FIXED_ELEMENTS(FIXED_ELEMENTS),
	.FP8_ELEMENTS(MXFP8_ELEMENTS),
	.FP6_ELEMENTS(MXFP6_ELEMENTS),
	.FP4_ELEMENTS(MXFP4_ELEMENTS)
) u_input_preparation_col1 (
	.i_mxfp_mode(i_mxfp_mode),
	.i_flat(w_reg_c1),
	.o_fixed(fixed_c1),
	.o_fp8(mxfp8_c1),
	.o_fp6(mxfp6_c1),
	.o_fp4(mxfp4_c1)
);

input_preparation_mxfp #(
	.FLAT_WIDTH(FLAT_DATA_WIDTH), 
	.FIXED_WIDTH(FIXED_DATA_WIDTH),
	.FIXED_ELEMENTS(FIXED_ELEMENTS),
	.FP8_ELEMENTS(MXFP8_ELEMENTS),
	.FP6_ELEMENTS(MXFP6_ELEMENTS),
	.FP4_ELEMENTS(MXFP4_ELEMENTS)
) u_input_preparation_col2 (
	.i_mxfp_mode(i_mxfp_mode),
	.i_flat(w_reg_c2),
	.o_fixed(fixed_c2),
	.o_fp8(mxfp8_c2),
	.o_fp6(mxfp6_c2),
	.o_fp4(mxfp4_c2)
);

input_preparation_mxfp #(
	.FLAT_WIDTH(FLAT_DATA_WIDTH), 
	.FIXED_WIDTH(FIXED_DATA_WIDTH),
	.FIXED_ELEMENTS(FIXED_ELEMENTS),
	.FP8_ELEMENTS(MXFP8_ELEMENTS),
	.FP6_ELEMENTS(MXFP6_ELEMENTS),
	.FP4_ELEMENTS(MXFP4_ELEMENTS)
) u_input_preparation_data_in (
	.i_mxfp_mode(i_mxfp_mode),
	.i_flat(data_in_pipe),
	.o_fixed(fixed_data_in),
	.o_fp8(mxfp8_data_in),
	.o_fp6(mxfp6_data_in),
	.o_fp4(mxfp4_data_in)
);

// Pipe 2
generate
	// TODO This is creating a lot of unnecessary registers
	// should be a better way of doing this, only ever 80 useful registers
	// Fixed Point
	for (genvar i = 0; i < FIXED_ELEMENTS; i++) begin
		pipeline #(.W(FIXED_DATA_WIDTH), .STAGES(1)) PIPE_2_fixed_c1 (
			.clk(clk),
			.rst(rst),
			.pipe_in(fixed_c1[i]),
			.pipe_out(fixed_c1_pipe[i])
		);

		pipeline #(.W(FIXED_DATA_WIDTH), .STAGES(1)) PIPE_2_fixed_c2 (
			.clk(clk),
			.rst(rst),
			.pipe_in(fixed_c2[i]),
			.pipe_out(fixed_c2_pipe[i])
		);

		pipeline #(.W(FIXED_DATA_WIDTH), .STAGES(1)) PIPE_2_fixed_data_in (
			.clk(clk),
			.rst(rst),
			.pipe_in(fixed_data_in[i]),
			.pipe_out(fixed_data_in_pipe[i])
		);
	end

	// MXFP8
	for (genvar i = 0; i < MXFP8_ELEMENTS; i++) begin
		pipeline #(.W(MXFP8_DATA_WIDTH), .STAGES(1)) PIPE_2_fp8_c1 (
			.clk(clk),
			.rst(rst),
			.pipe_in(mxfp8_c1[i]),
			.pipe_out(mxfp8_c1_pipe[i])
		);

		pipeline #(.W(MXFP8_DATA_WIDTH), .STAGES(1)) PIPE_2_fp8_c2 (
			.clk(clk),
			.rst(rst),
			.pipe_in(mxfp8_c2[i]),
			.pipe_out(mxfp8_c2_pipe[i])
		);

		pipeline #(.W(MXFP8_DATA_WIDTH), .STAGES(1)) PIPE_2_fp8_data_in (
			.clk(clk),
			.rst(rst),
			.pipe_in(mxfp8_data_in[i]),
			.pipe_out(mxfp8_data_in_pipe[i])
		);
	end

	// MXFP6
	for (genvar i = 0; i < MXFP6_ELEMENTS; i++) begin
		pipeline #(.W(MXFP6_DATA_WIDTH), .STAGES(1)) PIPE_2_fp6_c1 (
			.clk(clk),
			.rst(rst),
			.pipe_in(mxfp6_c1[i]),
			.pipe_out(mxfp6_c1_pipe[i])
		);

		pipeline #(.W(MXFP6_DATA_WIDTH), .STAGES(1)) PIPE_2_fp6_c2 (
			.clk(clk),
			.rst(rst),
			.pipe_in(mxfp6_c2[i]),
			.pipe_out(mxfp6_c2_pipe[i])
		);

		pipeline #(.W(MXFP6_DATA_WIDTH), .STAGES(1)) PIPE_2_fp6_data_in (
			.clk(clk),
			.rst(rst),
			.pipe_in(mxfp6_data_in[i]),
			.pipe_out(mxfp6_data_in_pipe[i])
		);
	end

	// MXFP4
	for (genvar i = 0; i < MXFP4_ELEMENTS; i++) begin
		pipeline #(.W(MXFP4_DATA_WIDTH), .STAGES(1)) PIPE_2_fp4_c1 (
			.clk(clk),
			.rst(rst),
			.pipe_in(mxfp4_c1[i]),
			.pipe_out(mxfp4_c1_pipe[i])
		);

		pipeline #(.W(MXFP4_DATA_WIDTH), .STAGES(1)) PIPE_2_fp4_c2 (
			.clk(clk),
			.rst(rst),
			.pipe_in(mxfp4_c2[i]),
			.pipe_out(mxfp4_c2_pipe[i])
		);

		pipeline #(.W(MXFP4_DATA_WIDTH), .STAGES(1)) PIPE_2_fp4_data_in (
			.clk(clk),
			.rst(rst),
			.pipe_in(mxfp4_data_in[i]),
			.pipe_out(mxfp4_data_in_pipe[i])
		);
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
naive_mxfp_dot_fixed #(
	.PACKED_REDUCTION(PACKED_REDUCTION)
) u_naive_mxfp_dot_fixed_col1 (
	.i_sign_shift(sign_shift),
	.i_exp_bits(exp_bits),
	.i_man_bits(man_bits),
	.i_exp_mask(exp_mask),
	.i_man_mask(man_mask),
	.i_mxfp_mode(i_mxfp_mode),

	.i_fixed_a(fixed_data_in_pipe),
	.i_fixed_b(fixed_c1_pipe),

	.i_mxfp8_a(mxfp8_data_in_pipe),
	.i_mxfp8_b(mxfp8_c1_pipe),
	.i_mxfp6_a(mxfp6_data_in_pipe),
	.i_mxfp6_b(mxfp6_c1_pipe),
	.i_mxfp4_a(mxfp4_data_in_pipe),
	.i_mxfp4_b(mxfp4_c1_pipe),

	.o_fixed_result(dot_out_col1)
);

naive_mxfp_dot_fixed #(
	.PACKED_REDUCTION(PACKED_REDUCTION)
) u_naive_mxfp_dot_fixed_col2 (
	.i_sign_shift(sign_shift),
	.i_exp_bits(exp_bits),
	.i_man_bits(man_bits),
	.i_exp_mask(exp_mask),
	.i_man_mask(man_mask),
	.i_mxfp_mode(i_mxfp_mode),

	.i_fixed_a(fixed_data_in_pipe),
	.i_fixed_b(fixed_c2_pipe),

	.i_mxfp8_a(mxfp8_data_in_pipe),
	.i_mxfp8_b(mxfp8_c2_pipe),
	.i_mxfp6_a(mxfp6_data_in_pipe),
	.i_mxfp6_b(mxfp6_c2_pipe),
	.i_mxfp4_a(mxfp4_data_in_pipe),
	.i_mxfp4_b(mxfp4_c2_pipe),

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
