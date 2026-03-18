/*
* Sum/reduce input fixed point numbers (converted 
* from MXFP) for naive dot product structure
*/
import pkg_aitb::*;

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
	input mxfp_mode_e i_mxfp_mode,

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
pow2_reduction_norecurse #(
	.INPUTS(FP8_INPUTS), 
	.INPUT_WIDTH(FP8_INPUT_WIDTH)
) u_fp8_reduction_norecurse (
	.i_op(i_fp8_ops),
	.o_sum(fp8_sum)
);

// FP6
pow2_reduction_norecurse #(
	.INPUTS(FP6_INPUTS), 
	.INPUT_WIDTH(FP6_INPUT_WIDTH)
) u_fp6_reduction_norecurse (
	.i_op(i_fp6_ops),
	.o_sum(fp6_sum)
);

// FP4
pow2_reduction_norecurse #(
	.INPUTS(FP4_INPUTS), 
	.INPUT_WIDTH(FP4_INPUT_WIDTH)
) u_fp4_reduction (
	.i_op(i_fp4_ops),
	.o_sum(fp4_sum)
);

assign fp6_fp4_sum = i_mxfp_mode == MXFP4 ? $signed(fp4_sum) + $signed(fp6_sum) // FP4
					  : $signed(fp6_sum); // FP6/8 and fixed point

assign fp8_fp6_sum = (i_mxfp_mode == MXFP8_43 || i_mxfp_mode == MXFP8_52) ? $signed(fp8_sum) // FP8
									  : $signed(fp8_sum) + $signed(fp6_fp4_sum); // FP4/6 and fixed point

assign o_sum = fp8_fp6_sum;

endmodule
