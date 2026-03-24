import pkg_aitb::*;

module mxfp_mult_shift_wrapper #(
	parameter MAX_EXP_BITS = 5,
	parameter MAX_MAN_BITS = 3,
	parameter MXFP_WIDTH   = 8,
	parameter OUTPUT_WIDTH = MXFP8_PRODUCT_WIDTH,

	parameter FIXED_MULT   = 1,
	parameter MULT_WIDTH   = FIXED_MULT ? 8 : MAX_MAN_BITS + 1,

	parameter SIGN_SHIFT_WIDTH = $clog2(MXFP_WIDTH - 1),
	parameter EXP_BITS_WIDTH   = $clog2(MAX_EXP_BITS),
	parameter MAN_BITS_WIDTH   = $clog2(MAX_MAN_BITS),
	parameter PROD_WIDTH       = 2*(MAX_MAN_BITS + 1)
)(
	// Fixed or MXFP input
	input logic fixed,

	// Configuration for MXFP format
	input logic [SIGN_SHIFT_WIDTH-1:0] sign_shift,
	input logic [EXP_BITS_WIDTH-1:0]   exp_bits,
	input logic [MAN_BITS_WIDTH-1:0]   man_bits,
	input logic [MAX_EXP_BITS-1:0]     exp_mask,
	input logic [MAX_MAN_BITS-1:0]     man_mask,

	// Input fixed point numbers
	input logic signed [MULT_WIDTH-1:0] fixed_a,
	input logic signed [MULT_WIDTH-1:0] fixed_b,

	// Input MXFP numbers
	input logic [MXFP_WIDTH-1:0] mxfp_a,
	input logic [MXFP_WIDTH-1:0] mxfp_b,

	output logic signed [OUTPUT_WIDTH-1:0] mxfp_mult_fixed
);

mxfp_mult_shift #(
	.MAX_EXP_BITS(MAX_EXP_BITS),
	.MAX_MAN_BITS(MAX_MAN_BITS),
	.MXFP_WIDTH(MXFP_WIDTH),
	.FIXED_MULT(FIXED_MULT),
	.MULT_WIDTH(MULT_WIDTH),
	.OUTPUT_WIDTH(OUTPUT_WIDTH)
) u_mxfp_mult_shift (
	.fixed(fixed),
	.sign_shift(sign_shift),
	.exp_bits(exp_bits),
	.man_bits(man_bits),
	.exp_mask(exp_mask),
	.man_mask(man_mask),
	.fixed_a(fixed_a),
	.fixed_b(fixed_b),
	.mxfp_a(mxfp_a),
	.mxfp_b(mxfp_b),
	.mxfp_mult_fixed(mxfp_mult_fixed),
	.inf(),
	.nan()
);

endmodule
