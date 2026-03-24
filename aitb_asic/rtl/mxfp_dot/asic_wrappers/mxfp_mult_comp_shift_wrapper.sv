import pkg_aitb::*;

module mxfp_mult_comp_shift_wrapper #(
	parameter MAX_EXP_BITS = 5,
	parameter MAX_MAN_BITS = 3,
	parameter OUTPUT_WIDTH = MXFP8_PRODUCT_WIDTH,

	parameter FIXED_MULT   = 1,
	parameter MULT_WIDTH   = FIXED_MULT ? 8 : MAX_MAN_BITS + 1
)(
	// Fixed or MXFP input
	input logic fixed_mode,

	// Input MXFP components
	input logic                    sign_a,
	input logic                    sign_b,
	input logic [MAX_EXP_BITS-1:0] exp_a,
	input logic [MAX_EXP_BITS-1:0] exp_b,
	input logic [MAX_MAN_BITS:0]   sig_a,
	input logic [MAX_MAN_BITS:0]   sig_b,

	output logic signed [OUTPUT_WIDTH-1:0] mxfp_mult_fixed
);

mxfp_mult_comp_shift #(
	.MAX_EXP_BITS(MAX_EXP_BITS),
	.MAX_MAN_BITS(MAX_MAN_BITS),
	.FIXED_MULT(FIXED_MULT),
	.MULT_WIDTH(MULT_WIDTH),
	.OUTPUT_WIDTH(OUTPUT_WIDTH)
) u_mxfp_mult_comp_shift (
	.fixed_mode(fixed_mode),
	.sign_a(sign_a),
	.sign_b(sign_b),
	.exp_a(exp_a),
	.exp_b(exp_b),
	.sig_a(sig_a),
	.sig_b(sig_b),
	.mxfp_mult_fixed(mxfp_mult_fixed)
);

endmodule
