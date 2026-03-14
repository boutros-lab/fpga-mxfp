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

	// Input fixed point numbers
	input logic signed [MULT_WIDTH-1:0] fixed_a,
	input logic signed [MULT_WIDTH-1:0] fixed_b,

	// Input MXFP numbers
	input logic [MXFP_WIDTH-1:0] mxfp_a,
	input logic [MXFP_WIDTH-1:0] mxfp_b,

	// Result of multiply
	output logic        [MAX_EXP_BITS:0]     exp_sum,
	output logic signed [PROD_WIDTH:0]       man_prd_signed,
	output logic signed [(MULT_WIDTH*2)-1:0] fixed_prd_signed,

	// Inf/Nan
	output logic inf,
	output logic nan
);

// MXFP components
logic sign_a, sign_b;
logic [MAX_EXP_BITS-1:0] exp_a, exp_b;
logic [MAX_MAN_BITS:0]   man_a, man_b;

logic [PROD_WIDTH-1:0] man_prd;

logic a_norm, b_norm;

// Inf/NaN handling
logic [MAX_EXP_BITS-1:0] max_exp;
logic inf_nan;
logic man_a_or, man_b_or;

generate
	// Special simpler case for E2M1
	if (MXFP_WIDTH == 4 && MAX_EXP_BITS == 2 && MAX_MAN_BITS == 1) begin
		// Break out MXFP inputs into their components
		assign sign_a = mxfp_a[3];
		assign sign_b = mxfp_b[3];

		assign exp_a = mxfp_a[2:1];
		assign exp_b = mxfp_b[2:1];

		assign a_norm = |exp_a;
		assign b_norm = |exp_b;

		assign man_a = {a_norm, mxfp_a[0]};
		assign man_b = {b_norm, mxfp_b[0]};
	end else begin
		always_comb begin
			// Break out MXFP inputs into their components
			sign_a = (mxfp_a >> sign_shift) & 1'b1;
			sign_b = (mxfp_b >> sign_shift) & 1'b1;
		
			exp_a = (mxfp_a >> man_bits) & exp_mask;
			exp_b = (mxfp_b >> man_bits) & exp_mask;

			a_norm = |exp_a;
			b_norm = |exp_b;
		
			man_a = (a_norm << man_bits) | (mxfp_a & man_mask);
			man_b = (b_norm << man_bits) | (mxfp_b & man_mask);
		end
	end
endgenerate

generate
	if (FIXED_MULT == 1) begin : fixed_mult
		// Instantiate multiplier
		logic signed [(MULT_WIDTH*2)-1:0] mult_prd;
		logic signed [MULT_WIDTH-1:0]     op_a, op_b;

		assign mult_prd = op_a * op_b;
		
		assign op_a = fixed ? fixed_a // Multiply the signed fixed point numbers
				    : man_a;  // Multiply the unsigned mantissas
		assign op_b = fixed ? fixed_b
				    : man_b;

		assign man_prd = mult_prd[PROD_WIDTH-1:0];

		assign fixed_prd_signed = mult_prd;
	end else begin : mxfp_mult
		// Multiply the unsigned mantissas
		assign man_prd = man_a * man_b;

		assign fixed_prd_signed = 'b0;
	end
endgenerate

// Add exponents, take away 1 if it's a normal number
assign exp_sum = exp_a + exp_b - a_norm - b_norm;

// Apply sign to manissa product
assign man_prd_signed = (sign_a ^ sign_b) ? -man_prd : man_prd;

generate
	if (MXFP_WIDTH == 8) begin
		// Inf/NaN handling
		assign max_exp = (1 << exp_bits) - 1;

		assign inf_nan = (exp_a == max_exp) || (exp_b == max_exp);
		
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
