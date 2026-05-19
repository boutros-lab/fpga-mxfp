/*
* Runtime configurable fix2float module
* Input width is fixed, point_position configurable
* Intended only for MXFP dot product of length 16
* As a result, does not support subnormals
*
* Uses flopoco generated normalizer, current supported input widths:
*    70b (Naive, Packed), 69b (E5M2 4), 40b (No E5M2), <23b (No FP8)
*/

module config_fix2fp32 #(
	parameter INPUT_WIDTH = 70
)(
	// Configuration
	input logic signed [7:0] i_exponent_correction,

	// Data
	input logic signed [INPUT_WIDTH-1:0] i_fixed,
	input logic [7:0]                    i_shared_exp_a,
	input logic [7:0]                    i_shared_exp_b,

	output logic [31:0] o_fp
);
localparam LZC_WIDTH = (INPUT_WIDTH == 70)  || (INPUT_WIDTH == 69) ? 7 
								   : INPUT_WIDTH == 40 ? 6
								   : INPUT_WIDTH <= 23 ? 5 
								   : 0;

logic        sign;
logic [7:0]  exponent;
logic [23:0] significand;
logic [22:0] fraction;

logic [LZC_WIDTH-1:0] leading_zero_count;

// Shared exponent handling
logic overflow, underflow;
logic signed [9:0] shared_exponent_sum;

// Add shared exponents and exponent_correction before normalizer
assign shared_exponent_sum = $signed({1'b0, i_shared_exp_a}) + $signed({1'b0, i_shared_exp_b}) + $signed(i_exponent_correction);

// Get sign bit, take two's complement if necessary
assign sign = i_fixed[INPUT_WIDTH-1];

// Currently using RTZ
generate
	// Use flopoco normalizer based on input width
	if (INPUT_WIDTH == 70) begin
		normalizer_sgn_70b 
		u_normalizer (
			.X(i_fixed), 
			.OZb(sign), 
			.Count(leading_zero_count), 
			.R(significand)
		);
	end else if (INPUT_WIDTH == 69) begin
		normalizer_sgn_69b 
		u_normalizer (
			.X(i_fixed), 
			.OZb(sign), 
			.Count(leading_zero_count), 
			.R(significand)
		);
	end else if (INPUT_WIDTH == 40) begin
		// Unsigned normalizer more area efficient at lower input widths
		logic [INPUT_WIDTH-2:0] unsigned_fixed;

		assign unsigned_fixed = sign ? -i_fixed : i_fixed;

		normalizer_39b 
		u_normalizer (
			.X(unsigned_fixed), 
			.Count(leading_zero_count), 
			.R(significand)
		);
	end else if (INPUT_WIDTH <= 23) begin
		// Unsigned normalizer more area efficient at lower input widths
		logic [INPUT_WIDTH-2:0] unsigned_fixed;

		assign unsigned_fixed = sign ? -i_fixed : i_fixed;

		normalizer_24b 
		u_normalizer (
			.X({{(24-(INPUT_WIDTH-1)){1'b0}}, unsigned_fixed}), 
			.Count(leading_zero_count), 
			.R(significand)
		);
	end else begin
		$error("Illegal config_fix2float input width %d", INPUT_WIDTH);
	end
endgenerate

logic zero_in, zero_sig;

assign zero_in  = i_fixed == 'b0;
assign zero_sig = significand == 'b0;

generate
	if (INPUT_WIDTH > 40) begin
		// Negative powers of 2 will result in zero significand, adjust by 1
		assign {underflow, overflow, exponent} = zero_in ? 'b0 
						       		 : $signed(shared_exponent_sum) - $unsigned(leading_zero_count) + zero_sig;
		
		// Take two's complement
		assign fraction = ({23{sign}} ^ significand[22:0]) + sign;
	end else begin
		assign {underflow, overflow, exponent} = zero_in ? 'b0 
						       		 : $signed(shared_exponent_sum) - $unsigned(leading_zero_count);
		
		assign fraction = significand[22:0];
	end
endgenerate

// Form final FP32
always_comb begin
	if (underflow || (!overflow && (exponent == 0))) begin // Underflow, Flush subnormals
		o_fp = {sign, 31'b0}; // 0
	end else if (overflow) begin // Overflow
		o_fp = {sign, 31'h7f800000}; // Inf
	end else begin // Normal
		o_fp = {sign, exponent, fraction};
	end
end

endmodule
