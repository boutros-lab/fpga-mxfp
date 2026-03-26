/*
* Naive MXFP dot product implementation
*/
import pkg_aitb::*;

module nofp8_mxfp_comp_dot_fixed #(
	parameter FIXED_DOT_LENGTH = 10,
	parameter FP6_DOT_LENGTH   = 12,
	parameter FP4_DOT_LENGTH   = 16,

	parameter FIXED_OPS = FIXED_DOT_LENGTH,
	parameter FP6_OPS   = FP6_DOT_LENGTH,
	parameter FP4_OPS   = FP4_DOT_LENGTH - FP6_DOT_LENGTH,

	parameter PACKED_REDUCTION = 0,
	parameter FIXED_RESULT_WIDTH = MXFP6_PRODUCT_WIDTH + $clog2(FP6_DOT_LENGTH)
)(
	// Configuration
	input mxfp_mode_e i_mxfp_mode,

	// Data
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

	output logic signed [FIXED_RESULT_WIDTH-1:0] o_fixed_result
);
// Use fixed point multiplier result
logic fixed_mult;

assign fixed_mult = i_mxfp_mode == FIXED;

// Output fixed point results of mxfp_mult modules
logic signed [MXFP6_PRODUCT_WIDTH-1:0] mxfp6_mult_result [FP6_OPS];
logic signed [MXFP4_PRODUCT_WIDTH-1:0] mxfp4_mult_result [FP4_OPS];

genvar i;

// Instantiate MXFP Multipliers
generate
	// MXFP6
	for (i = 0; i < FP6_OPS; i++) begin : inst_mxfp6_mult
		// Only use FIXED_MULT up to the number of fixed_point inputs
		if (i < FIXED_OPS) begin
			mxfp_mult_comp_shift #(
				.MAX_EXP_BITS(3), 
				.MAX_MAN_BITS(3),
				.FIXED_MULT(1),
				.OUTPUT_WIDTH(MXFP6_PRODUCT_WIDTH)
			) u_mxfp_mult_comp_shift_mxfp6 (
				.fixed_mode(fixed_mult),

				.sign_a(i_mxfp6_sign_a[i]),
				.sign_b(i_mxfp6_sign_b[i]),
				.exp_a(i_mxfp6_exp_a[i]),
				.exp_b(i_mxfp6_exp_b[i]),
				.sig_a(i_mxfp6_sig_a[i]),
				.sig_b(i_mxfp6_sig_b[i]),

				.mxfp_mult_fixed(mxfp6_mult_result[i])
			);
		end else begin
			logic [MXFP6_PRODUCT_WIDTH-1:0] mxfp_mult_fixed;

			mxfp_mult_comp_shift #(
				.MAX_EXP_BITS(3), 
				.MAX_MAN_BITS(3),
				.FIXED_MULT(0),
				.OUTPUT_WIDTH(MXFP6_PRODUCT_WIDTH)
			) u_mxfp_mult_comp_shift_mxfp6 (
				.fixed_mode(),

				.sign_a(i_mxfp6_sign_a[i]),
				.sign_b(i_mxfp6_sign_b[i]),
				.exp_a(i_mxfp6_exp_a[i]),
				.exp_b(i_mxfp6_exp_b[i]),
				.sig_a(i_mxfp6_sig_a[i]),
				.sig_b(i_mxfp6_sig_b[i]),

				.mxfp_mult_fixed(mxfp_mult_fixed)
			);

			// Force to 0 if using fixed point modes
			// Fixed point modes use the same adders as FP6
			assign mxfp6_mult_result[i] = fixed_mult == 1'b1 ? 'b0 : mxfp_mult_fixed;
		end
	end

	// MXFP4
	for (i = 0; i < FP4_OPS; i++) begin : inst_mxfp4_mult
		mxfp_mult_comp_shift #(
			.MAX_EXP_BITS(2), 
			.MAX_MAN_BITS(1),
			.FIXED_MULT(0),
			.OUTPUT_WIDTH(MXFP4_PRODUCT_WIDTH)
		) u_mxfp_mult_comp_shift_mxfp4 (
			.fixed_mode(),

			.sign_a(i_mxfp4_sign_a[i]),
			.sign_b(i_mxfp4_sign_b[i]),
			.exp_a(i_mxfp4_exp_a[i]),
			.exp_b(i_mxfp4_exp_b[i]),
			.sig_a(i_mxfp4_sig_a[i]),
			.sig_b(i_mxfp4_sig_b[i]),

			.mxfp_mult_fixed(mxfp4_mult_result[i])
		);
	end
endgenerate

// Sum products
nofp8_reduction #(
	.FP6_INPUTS(FP6_OPS),
	.FP4_INPUTS(FP4_OPS),

	.FP6_INPUT_WIDTH(MXFP6_PRODUCT_WIDTH),
	.FP4_INPUT_WIDTH(MXFP4_PRODUCT_WIDTH)
) u_naive_reduction (
	.i_mxfp_mode(i_mxfp_mode),

	.i_fp6_ops(mxfp6_mult_result),
	.i_fp4_ops(mxfp4_mult_result),

	.o_sum(o_fixed_result)
);

endmodule
