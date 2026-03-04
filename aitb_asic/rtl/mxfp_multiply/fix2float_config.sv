/*
* Runtime configurable fix2float module
* Intended only for MXFP dot product of length 16
* As a result, does not support subnormals
*/

module config_fix2float #(
	parameter INPUT_WIDTH = 32,

	parameter EXP_BITS = 8,
	parameter MAN_BITS = 23,

	// Setting max possible values, but point position can be smaller
	parameter FIXED_MSB_WIDTH      = $clog2(INPUT_WIDTH),
	parameter POINT_POSITION_WIDTH = $clog2(INPUT_WIDTH),

	parameter OUTPUT_WIDTH = 1 + EXP_BITS + MAN_BITS
)(
	// Configuration
	input logic [FIXED_MSB_WIDTH-1:0]      fixed_msb,
	input logic [POINT_POSITION_WIDTH-1:0] point_position,

	// Data
	input logic signed [INPUT_WIDTH-1:0] i_fixed,
	output logic [OUTPUT_WIDTH-1:0]      o_fp
);

logic                sign;
logic [MAN_BITS-1:0] mantissa;
logic [EXP_BITS-1:0] exponent;

logic [INPUT_WIDTH-2:0] unsigned_fixed;

// Get sign bit, take two's complement if necessary
assign sign = i_fixed[fixed_msb]; // TODO: is this necessary, will it always be sign extended?
assign unsigned_fixed = sign ? (-i_fixed)[INPUT_WIDTH-2:0] : i_fixed[INPUT_WIDTH-2:0];

// Count leading zeros
// Leading zero counter needs to start from MSB of input width
// Can't make it start from fixed_msb

// Exp = FP32_Bias + Leading_1-pos - Point_position

// Shift/form mantissa - no subnormal support

// Form final FP32
endmodule
