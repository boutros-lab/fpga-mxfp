/*
* Naive MXFP dot product implementation
*/
import pkg_aitb::*;

module naive_mxfp_dot #(
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
	//   MXFP Multiply
	input logic [2:0] i_sign_shift,
	input logic [2:0] i_exp_bits,
	input logic [1:0] i_man_bits,
	input logic [4:0] i_exp_mask,
	input logic [2:0] i_man_mask,
	//   Reduction
	input mxfp_mode_e i_mxfp_mode,
	//   Fix2Float
	input logic signed [7:0] i_exponent_correction,

	// Data
	input logic signed [7:0] i_fixed_a [FIXED_OPS],
	input logic signed [7:0] i_fixed_b [FIXED_OPS],

	input logic [7:0] i_mxfp8_a [FP8_OPS],
	input logic [7:0] i_mxfp8_b [FP8_OPS],
	input logic [5:0] i_mxfp6_a [FP6_OPS],
	input logic [5:0] i_mxfp6_b [FP6_OPS],
	input logic [3:0] i_mxfp4_a [FP4_OPS],
	input logic [3:0] i_mxfp4_b [FP4_OPS],

	input logic [7:0] i_shared_exp_a,
	input logic [7:0] i_shared_exp_b,

	output logic [31:0] o_fp32_result
);

// Output of reduction tree
logic signed [FIXED_RESULT_WIDTH-1:0] fixed_result;

naive_mxfp_dot_fixed #(
	.FIXED_DOT_LENGTH(FIXED_DOT_LENGTH),
	.FP8_DOT_LENGTH(FP8_DOT_LENGTH),
	.FP6_DOT_LENGTH(FP6_DOT_LENGTH),
	.FP4_DOT_LENGTH(FP4_DOT_LENGTH),
	.PACKED_REDUCTION(PACKED_REDUCTION)
) u_naive_mxfp_dot_fixed (
	.i_sign_shift(i_sign_shift),
	.i_exp_bits(i_exp_bits),
	.i_man_bits(i_man_bits),
	.i_exp_mask(i_exp_mask),
	.i_man_mask(i_man_mask),
	.i_mxfp_mode(i_mxfp_mode),

	.i_fixed_a(i_fixed_a),
	.i_fixed_b(i_fixed_b),

	.i_mxfp8_a(i_mxfp8_a),
	.i_mxfp8_b(i_mxfp8_b),
	.i_mxfp6_a(i_mxfp6_a),
	.i_mxfp6_b(i_mxfp6_b),
	.i_mxfp4_a(i_mxfp4_a),
	.i_mxfp4_b(i_mxfp4_b),

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
