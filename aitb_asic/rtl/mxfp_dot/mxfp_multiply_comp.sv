/*
* Multiply input MXFP components and output two's complement mantissa and
* summed exponents
*
* Supports exponents up to 5 bits
* Supports mantissas up to 3 bits
*
* Suports 8 bit fixed point input
*/

import pkg_aitb::*;

module mxfp_multiply_comp #(
	parameter MAX_EXP_BITS = 5,
	parameter MAX_MAN_BITS = 3,
	parameter FIXED_WIDTH  = 8,
	
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
	output logic        [MAX_EXP_BITS:0]   exp_sum,
	output logic signed [MAN_PROD_WIDTH:0] man_prd_signed,
	output logic signed [PROD_WIDTH-1:0]   fixed_prd_signed
);

logic [MAN_PROD_WIDTH-1:0] man_prd;

logic a_norm, b_norm;

assign a_norm = |exp_a;
assign b_norm = |exp_b;

generate
	if (FIXED_MULT == 1) begin : fixed_mult
		logic signed [FIXED_WIDTH-1:0] fixed_a, fixed_b;

		// Instantiate multiplier
		logic signed [PROD_WIDTH-1:0] mult_prd;
		logic signed [MULT_WIDTH-1:0] op_a, op_b;

		assign fixed_a = {sign_a, exp_a[FIXED_EXP_ENC-1:0], sig_a[FIXED_MAN_ENC-1:0]};
		assign fixed_b = {sign_b, exp_b[FIXED_EXP_ENC-1:0], sig_b[FIXED_MAN_ENC-1:0]};

		assign mult_prd = op_a * op_b;
		
		assign op_a = fixed_mode ? fixed_a // Multiply the signed fixed point numbers
					 : sig_a;  // Multiply the unsigned significands
		assign op_b = fixed_mode ? fixed_b
					 : sig_b;

		assign man_prd = mult_prd[MAN_PROD_WIDTH-1:0];

		assign fixed_prd_signed = mult_prd;
	end else begin : mxfp_mult
		// Multiply the unsigned significands
		assign man_prd = sig_a * sig_b;

		assign fixed_prd_signed = 'b0;
	end
endgenerate

// Add exponents, take away 1 if it's a normal number
assign exp_sum = exp_a + exp_b - a_norm - b_norm;

// Apply sign to manissa product
assign man_prd_signed = (sign_a ^ sign_b) ? -man_prd : man_prd;

endmodule
