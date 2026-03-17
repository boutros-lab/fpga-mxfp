/*
* Sum/reduce input fixed point numbers (converted 
* from MXFP) for packed dot product structure
* Single adder tree for MXFP8, additional adder at output for MXFP4/6
*/

import pkg_aitb::*;

module packed_reduction #(
	parameter FP8_INPUTS = 8,
	parameter FP6_INPUTS = 4,
	parameter FP4_INPUTS = 4,

	parameter FP8_INPUT_WIDTH = 64,
	parameter FP6_INPUT_WIDTH = 20,
	parameter FP4_INPUT_WIDTH = 10,

	parameter FP8_LEVELS = $clog2(FP8_INPUTS),
	parameter FP6_LEVELS = $clog2(FP6_INPUTS + FP8_INPUTS),
	parameter FP4_LEVELS = $clog2(FP4_INPUTS + FP6_INPUTS + FP8_INPUTS),

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
localparam PADDING     = FP8_LEVELS;
localparam PADDING_FP4 = PADDING + FP6_INPUT_WIDTH - FP4_INPUT_WIDTH;
localparam EXTEND_FP4  = FP6_INPUT_WIDTH - FP4_INPUT_WIDTH;
localparam OFFSET      = FP6_INPUT_WIDTH + PADDING;

logic signed [FP8_INPUT_WIDTH-1:0]  adder_in [FP8_INPUTS];
logic signed [FP8_OUTPUT_WIDTH-1:0] tree_sum;
logic signed [FP6_OUTPUT_WIDTH-1:0] fp6_fp4_sum;

// Assign adder inputs
// If input is not MXFP8, pack 2 inputs into the first level of the adder tree
always_comb begin
	for (int i = 0; i < FP8_INPUTS; i++) begin
		if (i_mxfp_mode == MXFP8_52 || i_mxfp_mode == MXFP8_43) begin
			// FP8 modes, 1:1
			adder_in[i] = i_fp8_ops[i];
		end else begin
			if (i < FP8_INPUTS/2) begin
				if (i < FIXED_ELEMENTS/2) begin
					// Pack FP6/FP4/FIXED results
					adder_in[i] = $signed({1'b0, i_fp8_ops[i][FP6_INPUT_WIDTH-1:0], {PADDING{1'b0}}, i_fp6_ops[i]});
				end else begin
					// Fixed point inputs will only use some of fp6_ops
					adder_in[i] = i_mxfp_mode == FIXED ? $signed({1'b0, i_fp8_ops[i][FP6_INPUT_WIDTH-1:0]})
									   : $signed({1'b0, i_fp8_ops[i][FP6_INPUT_WIDTH-1:0], {PADDING{1'b0}}, i_fp6_ops[i]});
				end
			end else begin
				// Pack FP4 results
				// Extend FP4 to FP6 bits
				adder_in[i] = i_mxfp_mode == MXFP4 ? $signed({1'b0, i_fp8_ops[i][FP6_INPUT_WIDTH-1:0], {PADDING{1'b0}}, 
								     {EXTEND_FP4{i_fp4_ops[i-(FP8_INPUTS/2)][FP4_INPUT_WIDTH-1]}}, i_fp4_ops[i-(FP8_INPUTS/2)]})
								   : $signed({1'b0, i_fp8_ops[i][FP6_INPUT_WIDTH-1:0]});
			end
		end
	end
end

// Single shared reduction for all formats
pow2_reduction #(
	.INPUTS(FP8_INPUTS), 
	.INPUT_WIDTH(FP8_INPUT_WIDTH)
) u_reduction (
	.i_op(adder_in),
	.o_sum(tree_sum)
);

// Output at final stage of reduction is 2 numbers for non-MXFP8 modes
// Add them together to form final output
logic [FP6_OUTPUT_WIDTH:0] op0, op1;

assign op0 = tree_sum[OFFSET+:(FP6_OUTPUT_WIDTH-1)];
assign op1 = tree_sum[0+:(FP6_OUTPUT_WIDTH-1)];

assign fp6_fp4_sum = $signed(tree_sum[OFFSET+:(FP6_OUTPUT_WIDTH-1)]) + $signed(tree_sum[0+:(FP6_OUTPUT_WIDTH-1)]);

assign o_sum = (i_mxfp_mode == MXFP8_43 || i_mxfp_mode == MXFP8_52) ? tree_sum
								    : fp6_fp4_sum;

endmodule
