/*
* Multiply any input MXFP components and output two's complement fixed point
* representation
*
* Supports exponents up to 5 bits
* Supoorts mantissas up to 3 bits
*
* Suports 8 bit fixed point input
*/

import pkg_aitb::*;

module mxfp_mult_comp_shift #(
	parameter MAX_EXP_BITS = 5,
	parameter MAX_MAN_BITS = 3,
	parameter FIXED_WIDTH  = 8,
	parameter OUTPUT_WIDTH = 2 * ((1 << MAX_EXP_BITS) + MAX_MAN_BITS),

	parameter FIXED_MULT   = 0,
	parameter MULT_WIDTH   = FIXED_MULT ? FIXED_WIDTH : MAX_MAN_BITS + 1,

	parameter MAN_PROD_WIDTH = 2 * (MAX_MAN_BITS + 1),
	parameter PROD_WIDTH     = 2 * MULT_WIDTH
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

	// Result of multiply
	output logic signed [OUTPUT_WIDTH-1:0] mxfp_mult_fixed
);

// MXFP Multilpy Outputs
logic        [MAX_EXP_BITS:0]   exp_sum;
logic signed [MAN_PROD_WIDTH:0] man_prd_signed;
logic signed [PROD_WIDTH-1:0]   fixed_prd_signed;

mxfp_multiply_comp #(
	.MAX_EXP_BITS(MAX_EXP_BITS),
	.MAX_MAN_BITS(MAX_MAN_BITS),
	.FIXED_WIDTH(FIXED_WIDTH),
	.FIXED_MULT(FIXED_MULT),
	.MULT_WIDTH(MULT_WIDTH)
) u_mxfp_multiply_comp (
	.fixed_mode(fixed_mode),
	.sign_a(sign_a),
	.sign_b(sign_b),
	.exp_a(exp_a),
	.exp_b(exp_b),
	.sig_a(sig_a),
	.sig_b(sig_b),
	.exp_sum(exp_sum),
	.man_prd_signed(man_prd_signed),
	.fixed_prd_signed(fixed_prd_signed)
);

generate
	if (FIXED_MULT == 1) begin
		assign mxfp_mult_fixed = fixed_mode ? $signed(fixed_prd_signed)
						    : man_prd_signed << $unsigned(exp_sum);
	end else begin
		assign mxfp_mult_fixed = man_prd_signed << $unsigned(exp_sum);
	end
endgenerate

endmodule
