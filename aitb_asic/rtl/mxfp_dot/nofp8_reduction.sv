/*
* Sum/reduce input fixed point numbers (converted 
* from MXFP) for fp6/fp4 aitb
*/
import pkg_aitb::*;

module nofp8_reduction #(
	parameter FP6_INPUTS = 12,
	parameter FP4_INPUTS = 4,

	parameter FP6_INPUT_WIDTH = 19,
	parameter FP4_INPUT_WIDTH =  9,

	parameter FP6_LEVELS = $clog2(FP6_INPUTS),
	parameter FP4_LEVELS = $clog2(FP4_INPUTS),

	parameter FP6_OUTPUT_WIDTH = FP6_INPUT_WIDTH + FP6_LEVELS,
	parameter FP4_OUTPUT_WIDTH = FP4_INPUT_WIDTH + FP4_LEVELS
)(
	input mxfp_mode_e i_mxfp_mode,

	input logic signed [FP6_INPUT_WIDTH-1:0] i_fp6_ops [FP6_INPUTS],
	input logic signed [FP4_INPUT_WIDTH-1:0] i_fp4_ops [FP4_INPUTS],

	output logic signed [FP6_OUTPUT_WIDTH-1:0] o_sum
);
localparam FP4_FULL_WIDTH = FP4_INPUT_WIDTH + $clog2(FP6_INPUTS + FP4_INPUTS);

logic signed [FP6_OUTPUT_WIDTH-1:0] fp6_sum;
logic signed [FP4_OUTPUT_WIDTH-1:0] fp4_sum;

logic signed [FP4_FULL_WIDTH-1:0] fp6_fp4_sum;

// Reduce the different fixed point formats separately
// FP6
assign fp6_sum = i_fp6_ops[0] + i_fp6_ops[1] + i_fp6_ops[2] 
	       + i_fp6_ops[3] + i_fp6_ops[4] + i_fp6_ops[5] 
	       + i_fp6_ops[6] + i_fp6_ops[7] + i_fp6_ops[8] 
	       + i_fp6_ops[9] + i_fp6_ops[10] + i_fp6_ops[11];
// FP4
pow2_reduction_norecurse #(
	.INPUTS(FP4_INPUTS), 
	.INPUT_WIDTH(FP4_INPUT_WIDTH)
) u_fp4_reduction (
	.i_op(i_fp4_ops),
	.o_sum(fp4_sum)
);

assign fp6_fp4_sum = $signed(fp4_sum) + $signed(fp6_sum[FP4_OUTPUT_WIDTH-1:0]); // FP4

assign o_sum = i_mxfp_mode == MXFP4 ? fp6_fp4_sum : fp6_sum;

endmodule
