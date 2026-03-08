/*
* Runtime configurable fix2float module
* Input width is fixed, point_position configurable
* Intended only for MXFP dot product of length 16
* As a result, does not support subnormals
*/

// TODO, move to pkg
`define INPUT_WIDTH 69
`define EXP_BITS 8
`define MAN_BITS 23
`define OUTPUT_WIDTH `EXP_BITS + `MAN_BITS + 1
`define FP32_BIAS 8'd127

module config_fix2fp32 (
	// Configuration
	input logic signed [`EXP_BITS-1:0] i_exponent_correction,

	// Data
	input logic signed [`INPUT_WIDTH-1:0] i_fixed,
	input logic [7:0]                     i_shared_exp_a,
	input logic [7:0]                     i_shared_exp_b,
	output logic [`OUTPUT_WIDTH-1:0]      o_fp
);
logic                 sign;
logic [`EXP_BITS-1:0] exponent;
logic [`MAN_BITS:0]   significand;

logic [`INPUT_WIDTH-2:0] unsigned_fixed;

logic [6:0] leading_zero_count;

// Shared exponent handling
logic overflow, underflow;
logic [`EXP_BITS+1:0] shared_exponent_sum;

// Add shared exponents and exponent_correction before normalizer
assign shared_exponent_sum = $signed({1'b0, i_shared_exp_a}) + $signed({1'b0, i_shared_exp_b}) + $signed(i_exponent_correction);

// Get sign bit, take two's complement if necessary
assign sign = i_fixed[`INPUT_WIDTH-1];
assign unsigned_fixed = sign ? -i_fixed : i_fixed;

// TODO: Do we want round to even?
normalizer_68b 
u_normalizer (
	.X(unsigned_fixed), 
	.Count(leading_zero_count), 
	.R(significand)
);

assign {underflow, overflow, exponent} = unsigned_fixed == 'b0 ? 'b0 
				       			       : shared_exponent_sum - leading_zero_count;

// Form final FP32
always_comb begin
	if (underflow || (!overflow && (exponent == 0))) begin // Underflow, Flush subnormals
		o_fp = {sign, 31'b0}; // 0
	end else if (overflow) begin // Overflow
		o_fp = {sign, 31'h7f800000}; // Inf
	end else begin // Normal
		o_fp = {sign, exponent, significand[22:0]};
	end
end

endmodule
