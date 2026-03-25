/*
* Naive MXFP dot product implementation
*/
import pkg_aitb::*;

module naive_mxfp_comp_dot #(
	parameter FIXED_DOT_LENGTH = 10,
	parameter FP8_DOT_LENGTH   =  8,
	parameter FP6_DOT_LENGTH   = 12,
	parameter FP4_DOT_LENGTH   = 16,

	parameter FIXED_OPS = FIXED_DOT_LENGTH,
	parameter FP8_OPS   = FP8_DOT_LENGTH,
	parameter FP6_OPS   = FP6_DOT_LENGTH - FP8_DOT_LENGTH,
	parameter FP4_OPS   = FP4_DOT_LENGTH - FP6_DOT_LENGTH,

	parameter PACKED_REDUCTION = 0
)(
	// Configuration
	//   Reduction
	input mxfp_mode_e i_mxfp_mode,
	//   Fix2Float
	input logic signed [7:0] i_exponent_correction,

	// Data
	//  FP8
	input logic                     i_mxfp8_sign_a [FP8_OPS],
	input logic                     i_mxfp8_sign_b [FP8_OPS],
	input logic [MXFP8_MAX_EXP-1:0] i_mxfp8_exp_a  [FP8_OPS],
	input logic [MXFP8_MAX_EXP-1:0] i_mxfp8_exp_b  [FP8_OPS],
	input logic [MXFP8_MAX_MAN:0]   i_mxfp8_sig_a  [FP8_OPS],
	input logic [MXFP8_MAX_MAN:0]   i_mxfp8_sig_b  [FP8_OPS],

	//  FP6
	input logic                     i_mxfp6_sign_a [FP6_OPS],
	input logic                     i_mxfp6_sign_b [FP6_OPS],
	input logic [MXFP6_MAX_EXP-1:0] i_mxfp6_exp_a  [FP6_OPS],
	input logic [MXFP6_MAX_EXP-1:0] i_mxfp6_exp_b  [FP6_OPS],
	input logic [MXFP6_MAX_MAN:0]   i_mxfp6_sig_a  [FP6_OPS],
	input logic [MXFP6_MAX_MAN:0]   i_mxfp6_sig_b  [FP6_OPS],

	//  FP4
	input logic                     i_mxfp4_sign_a [FP4_OPS],
	input logic                     i_mxfp4_sign_b [FP4_OPS],
	input logic [MXFP4_MAX_EXP-1:0] i_mxfp4_exp_a  [FP4_OPS],
	input logic [MXFP4_MAX_EXP-1:0] i_mxfp4_exp_b  [FP4_OPS],
	input logic [MXFP4_MAX_MAN:0]   i_mxfp4_sig_a  [FP4_OPS],
	input logic [MXFP4_MAX_MAN:0]   i_mxfp4_sig_b  [FP4_OPS],

	input logic [7:0] i_shared_exp_a,
	input logic [7:0] i_shared_exp_b,

	output logic [31:0] o_fp32_result
);

// Output of reduction tree
logic signed [FIXED_RESULT_WIDTH-1:0] fixed_result;

naive_mxfp_comp_dot_fixed #(
	.FIXED_DOT_LENGTH(FIXED_DOT_LENGTH),
	.FP8_DOT_LENGTH(FP8_DOT_LENGTH),
	.FP6_DOT_LENGTH(FP6_DOT_LENGTH),
	.FP4_DOT_LENGTH(FP4_DOT_LENGTH),
	.PACKED_REDUCTION(PACKED_REDUCTION)
) u_naive_mxfp_comp_dot_fixed (
	.i_mxfp_mode(i_mxfp_mode),

	.i_mxfp8_sign_a(i_mxfp8_sign_a),
	.i_mxfp8_sign_b(i_mxfp8_sign_b),
	.i_mxfp8_exp_a(i_mxfp8_exp_a),
	.i_mxfp8_exp_b(i_mxfp8_exp_b),
	.i_mxfp8_sig_a(i_mxfp8_sig_a),
	.i_mxfp8_sig_b(i_mxfp8_sig_b),

	.i_mxfp6_sign_a(i_mxfp6_sign_a),
	.i_mxfp6_sign_b(i_mxfp6_sign_b),
	.i_mxfp6_exp_a(i_mxfp6_exp_a),
	.i_mxfp6_exp_b(i_mxfp6_exp_b),
	.i_mxfp6_sig_a(i_mxfp6_sig_a),
	.i_mxfp6_sig_b(i_mxfp6_sig_b),

	.i_mxfp4_sign_a(i_mxfp4_sign_a),
	.i_mxfp4_sign_b(i_mxfp4_sign_b),
	.i_mxfp4_exp_a(i_mxfp4_exp_a),
	.i_mxfp4_exp_b(i_mxfp4_exp_b),
	.i_mxfp4_sig_a(i_mxfp4_sig_a),
	.i_mxfp4_sig_b(i_mxfp4_sig_b),

	.o_fixed_result(fixed_result)
);

// Convert to FP32
config_fix2fp32  #(
	.INPUT_WIDTH(FIXED_RESULT_WIDTH)
) u_fix2fp32 (
	.i_exponent_correction(i_exponent_correction),
	.i_fixed(fixed_result),
	.i_shared_exp_a(i_shared_exp_a),
	.i_shared_exp_b(i_shared_exp_b),
	.o_fp(o_fp32_result)
);

endmodule
