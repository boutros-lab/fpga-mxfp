/*
* Sum/reduce input fixed point numbers (converted 
* from MXFP) for fp4 aitb
*/
import pkg_aitb::*;

module e2m1_reduction #(
	parameter FIXED_INPUTS = 10,
	parameter FP4_INPUTS   = 6,

	parameter FIXED_INPUT_WIDTH = 16,
	parameter FP4_INPUT_WIDTH   =  9,

	parameter FIXED_LEVELS = $clog2(FIXED_INPUTS),
	parameter FP4_LEVELS   = $clog2(FP4_INPUTS),

	parameter FIXED_OUTPUT_WIDTH = FIXED_INPUT_WIDTH + FIXED_LEVELS,
	parameter FP4_OUTPUT_WIDTH   = FP4_INPUT_WIDTH + FP4_LEVELS
)(
	input mxfp_mode_e i_mxfp_mode,

	input logic signed [FIXED_INPUT_WIDTH-1:0] i_fixed_ops [FIXED_INPUTS],
	input logic signed [FP4_INPUT_WIDTH-1:0]   i_fp4_ops   [FP4_INPUTS],

	output logic signed [FIXED_OUTPUT_WIDTH-1:0] o_sum
);
localparam FP4_FULL_WIDTH = FP4_INPUT_WIDTH + $clog2(FIXED_INPUTS + FP4_INPUTS);

logic signed [FIXED_OUTPUT_WIDTH-1:0] fixed_sum;
logic signed [FP4_OUTPUT_WIDTH-1:0]   fp4_sum;

logic signed [FP4_FULL_WIDTH-1:0] fixed_fp4_sum;

// Reduce the different fixed point formats separately
// FP6
assign fixed_sum = i_fixed_ops[0] + i_fixed_ops[1] + i_fixed_ops[2] 
	         + i_fixed_ops[3] + i_fixed_ops[4] + i_fixed_ops[5] 
	         + i_fixed_ops[6] + i_fixed_ops[7] + i_fixed_ops[8] 
	         + i_fixed_ops[9];
// FP4
assign fp4_sum = i_fp4_ops[0] + i_fp4_ops[1] + i_fp4_ops[2] 
	       + i_fp4_ops[3] + i_fp4_ops[4] + i_fp4_ops[5];

assign fixed_fp4_sum = $signed(fp4_sum) + $signed(fixed_sum[FP4_OUTPUT_WIDTH-1:0]); // FP4

assign o_sum = i_mxfp_mode == MXFP4 ? fixed_fp4_sum : fixed_sum;

endmodule
