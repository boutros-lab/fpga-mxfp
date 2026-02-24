/*
* Multiply any input MXFP format and output two's complement fixed point
* representation
*
* Supports Inf/NaN
* Supports exponents up to 5 bits
* Supoorts mantissas up to 3 bits
*/

module mxfp_mult_shift # (
	parameter MAX_EXP_BITS = 5,
	parameter MAX_MAN_BITS = 3,
	parameter MXFP_WIDTH   = 8,
	parameter OUTPUT_WIDTH = 2 * ((1 << MAX_EXP_BITS) + MAX_MAN_BITS),

	parameter EXP_BITS_WIDTH = $clog2(MAX_EXP_BITS),
	parameter MAN_BITS_WIDTH = $clog2(MAX_MAN_BITS),
	parameter PROD_WIDTH     = 2*(MAX_MAN_BITS + 1)
)(
	// Configuration for MXFP format
	input logic [EXP_BITS_WIDTH-1:0] exp_bits;
	input logic [MAN_BITS_WIDTH-1:0] man_bits;
	//logic [2:0] mxfp_mode; // 000: E2M1, 001: E2M3, 010: E3M2, 011: E4M3, 100: E5M2

	// Input MXFP numbers
	input logic [MXFP_WIDTH-1:0] mxfp_a;
	input logic [MXFP_WIDTH-1:0] mxfp_b;

	// Result of multiply
	output logic signed [OUTPUT_WIDTH-1:0] mxfp_mult_fixed;

	// Inf/Nan
	output logic inf;
	output logic nan;
);

// MXFP Multilpy Outputs
logic        [MAX_EXP_BITS:0] exp_sum;
logic signed [PROD_WIDTH:0]   man_prd_signed;

mxfp_multiply 
u_mxfp_multiply (
	.exp_bits(exp_bits),
	.man_bits(man_bits),
	.mxfp_a(mxfp_a),
	.mxfp_b(mxfp_b),
	.exp_sum(exp_sum),
	.man_prd_signed(man_prd_signed),
	.inf(inf),
	.nan(nan)
);

assign mxfp_mult_fixed = man_prd_signed << $unsigned(exp_sum);

endmodule
