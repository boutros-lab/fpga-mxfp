/*
* Multiply any input MXFP format and output two's complement fixed point
* representation
*
* Supports Inf/NaN
* Supports exponents up to 5 bits
* Supoorts mantissas up to 3 bits
*/

module mxfp_mult_shift #(
	parameter MAX_EXP_BITS = 5,
	parameter MAX_MAN_BITS = 3,
	parameter MXFP_WIDTH   = 8,
	parameter OUTPUT_WIDTH = 2 * ((1 << MAX_EXP_BITS) + MAX_MAN_BITS),

	parameter FIXED_MULT   = 0,
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

	// Input MXFP numbers
	input logic [MXFP_WIDTH-1:0] mxfp_a,
	input logic [MXFP_WIDTH-1:0] mxfp_b,

	// Result of multiply
	output logic signed [OUTPUT_WIDTH-1:0] mxfp_mult_fixed,

	// Inf/Nan
	output logic inf,
	output logic nan
);

// MXFP Multilpy Outputs
logic        [MAX_EXP_BITS:0] exp_sum;
logic signed [PROD_WIDTH:0]   man_prd_signed;

mxfp_multiply #(
	.MAX_EXP_BITS(MAX_EXP_BITS),
	.MAX_MAN_BITS(MAX_MAN_BITS),
	.MXFP_WIDTH(MXFP_WIDTH),
	.FIXED_MULT(FIXED_MULT),
	.MULT_WIDTH(MULT_WIDTH)
) u_mxfp_multiply (
	.fixed(fixed),
	.sign_shift(sign_shift),
	.exp_bits(exp_bits),
	.man_bits(man_bits),
	.exp_mask(exp_mask),
	.man_mask(man_mask),
	.mxfp_a(mxfp_a),
	.mxfp_b(mxfp_b),
	.exp_sum(exp_sum),
	.man_prd_signed(man_prd_signed),
	.inf(inf),
	.nan(nan)
);

assign mxfp_mult_fixed = man_prd_signed << $unsigned(exp_sum);

endmodule
