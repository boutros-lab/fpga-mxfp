/*
* Sum/reduce input fixed point numbers (converted 
* from MXFP) for naive dot product structure
*/

module naive_reduction #(
	parameter FP8_INPUTS = 8,
	parameter FP6_INPUTS = 4,
	parameter FP4_INPUTS = 4,

	parameter FP8_INPUT_WIDTH = 64,
	parameter FP6_INPUT_WIDTH = 20,
	parameter FP4_INPUT_WIDTH = 10,

	parameter FP8_LEVELS = $clog2(FP8_INPUTS),
	parameter FP6_LEVELS = $clog2(FP6_INPUTS),
	parameter FP4_LEVELS = $clog2(FP4_INPUTS),

	parameter FP8_OUTPUT_WIDTH = FP8_INPUT_WIDTH + FP8_LEVELS,
	parameter FP6_OUTPUT_WIDTH = FP6_INPUT_WIDTH + FP6_LEVELS,
	parameter FP4_OUTPUT_WIDTH = FP4_INPUT_WIDTH + FP4_LEVELS
)(
	input logic [2:0] mxfp_mode, // 000: E2M1, 001: E2M3, 010: E3M2, 011: E4M3, 100: E5M2 // TODO - create enum

	input logic signed [FP8_INPUT_WIDTH-1:0] i_fp8_ops [FP8_INPUTS],
	input logic signed [FP6_INPUT_WIDTH-1:0] i_fp6_ops [FP6_INPUTS],
	input logic signed [FP4_INPUT_WIDTH-1:0] i_fp4_ops [FP4_INPUTS],

	output logic signed [FP8_OUTPUT_WIDTH-1:0] o_sum
);

logic signed [FP8_OUTPUT_WIDTH-1:0] fp8_sum;
logic signed [FP6_OUTPUT_WIDTH-1:0] fp6_sum;
logic signed [FP4_OUTPUT_WIDTH-1:0] fp4_sum;

logic signed [FP6_OUTPUT_WIDTH-1:0] fp6_fp4_sum;
logic signed [FP8_OUTPUT_WIDTH-1:0] fp8_fp6_sum;

// Reduce the different fixed point formats separately
// FP8
pow2_reduction #(
	.INPUTS(FP8_INPUTS), 
	.INPUT_WIDTH(FP8_INPUT_WIDTH)
) u_fp8_reduction (
	.i_op(i_fp8_ops),
	.o_sum(fp8_sum)
);

// FP6
pow2_reduction #(
	.INPUTS(FP6_INPUTS), 
	.INPUT_WIDTH(FP6_INPUT_WIDTH)
) u_fp6_reduction (
	.i_op(i_fp6_ops),
	.o_sum(fp6_sum)
);

// FP4
pow2_reduction #(
	.INPUTS(FP4_INPUTS), 
	.INPUT_WIDTH(FP4_INPUT_WIDTH)
) u_fp4_reduction (
	.i_op(i_fp4_ops),
	.o_sum(fp4_sum)
);

assign fp6_fp4_sum = mxfp_mode == 3'b000 ? $signed(fp4_sum) + $signed(fp6_sum) // FP4
					 : $signed(fp6_sum); // FP6/8 and fixed point

assign fp8_fp6_sum = (mxfp_mode == 3'b011 || mxfp_mode == 3'b100) ? $signed(fp8_sum) // FP8
								  : $signed(fp8_sum) + $signed(fp6_fp4_sum); // FP4/6 and fixed point

assign o_sum = fp8_fp6_sum;

endmodule
