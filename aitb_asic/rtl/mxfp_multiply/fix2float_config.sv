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

module config_fix2float #(
	// Setting max possible value, but point position can be smaller
	parameter POINT_POSITION_WIDTH = $clog2(`INPUT_WIDTH)
)(
	// Configuration
	input logic [POINT_POSITION_WIDTH-1:0] i_point_position, // TODO Change this to a combined exponent correction

	// Data
	input logic signed [`INPUT_WIDTH-1:0] i_fixed,
	output logic [`OUTPUT_WIDTH-1:0]      o_fp
);
logic                 sign;
logic [`EXP_BITS-1:0] exponent;
logic [`MAN_BITS:0]   significand;

logic [`INPUT_WIDTH-2:0] unsigned_fixed;

logic [6:0] leading_zero_count;

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

assign exponent = unsigned_fixed == '0 ? 8'b0 
				       : (`INPUT_WIDTH - 1) - leading_zero_count + `FP32_BIAS - i_point_position - 1'b1; // TODO Collect this into a single term, exponent_correction

// Form final FP32
assign o_fp = {sign, exponent, significand[22:0]};

endmodule
