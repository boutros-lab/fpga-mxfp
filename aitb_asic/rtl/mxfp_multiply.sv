/*
* Multiply any input MXFP format and output two's complement mantissa and
* summed exponents
*
* Supports Inf/NaN
* Supports exponents up to 5 bits
* Supoorts mantissas up to 3 bits
*/

module mxfp_multiply #(
	parameter MAX_EXP_BITS = 5,
	parameter MAX_MAN_BITS = 3,
	parameter MXFP_WIDTH   = 8,

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
	output logic        [MAX_EXP_BITS:0] exp_sum;
	output logic signed [PROD_WIDTH:0]   man_prd_signed;

	// Inf/Nan
	output logic inf;
	output logic nan;
);

// MXFP components
logic sign_a, sign_b;
logic [MAX_EXP_BITS-1:0] exp_a, exp_b;
logic [MAX_MAN_BITS:0]   man_a, man_b;

logic [PROD_WIDTH-1:0] man_prd;

logic [MAX_EXP_BITS-1:0] exp_mask;
logic a_norm, b_norm;

// Inf/NaN handling
logic inf_nan;
logic man_a_or, man_b_or;

generate
	// Special simpler case for E2M1
	if (MXFP_WIDTH == 4 && MAX_EXP_WIDTH == 2 && MAX_MAN_WIDTH == 1) begin
		// Break out MXFP inputs into their components
		sign_a = mxfp_a[3];
		sign_b = mxfp_b[3];
		
		exp_a = mxfp_a[2:1];
		exp_b = mxfp_b[2:1];
		
		man_a = mxfp_a[0];
		man_b = mxfp_b[0];
	end else begin
		always_comb begin
			// Break out MXFP inputs into their components
			sign_a = mxfp_a >> (exp_bits + man_bits) & 1'b1;
			sign_b = mxfp_b >> (exp_bits + man_bits) & 1'b1;
		
			exp_mask = (1 << exp_bits) - 1'b1;
		
			exp_a = (mxfp_a >> exp_bits) & exp_mask;
			exp_b = (mxfp_b >> exp_bits) & exp_mask;
		
			man_a = mxfp_a[0 +: man_bits];
			man_b = mxfp_b[0 +: man_bits];
		end
	end
endgenerate

assign a_norm = |exp_a;
assign b_norm = |exp_b;

// Add exponents, take away 1 if it's a normal number
assign exp_sum = exp_a + exp_b - a_norm - b_norm;
// Multiply the unsigned mantissas
assign man_prd = man_a * man_b;

// Apply sign to manissa product
assign man_prd_signed = sign_a ^ sign_b ? -man_prd : man_prd;

generate
	if (MXFP_WIDTH == 8) begin
		// Inf/NaN handling
		assign inf_nan = &exp_a[0 +: exp_bits] || &exp_b[0 +: exp_bits];
		
		assign man_a_or = |man_a;
		assign man_b_or = |man_b;
		
		assign inf = inf_nan && (exp_bits == 3'h5) && (!man_a_or && !man_b_or);
		assign nan = inf_nan && (exp_bits >= 3'h4) && (man_a_or || man_b_or);
	end else begin
		// If paramaters don't allow MXFP8, don't generate Inf/NaN logic
		assign inf = 1'b0;
		assign nan = 1'b0;
	end
endgenerate

endmodule
