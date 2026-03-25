/*
* Sum/reduce input fixed point numbers (converted 
* from MXFP) for 4 input E5M2 dot product circuit
* Single adder tree for MXFP8 E5M2, rst of inputs are packed into this
*
* Minimum width for this reduction tree:
* For E4M3:
* 37 * 2 + 2 + 2 = 78
*
* For E3M2:
* 19 * 4 + 3 * (2 + 2) = 76 + 12 = 88
* OR
* 19 * 3 + 2 * (2 + 2) = 57 + 8 = 65
*
* One additional adder for E4M3, 39 + 39
* Two additional adders for E3M2, 21 + 21 + 21
* Four additional adders for E2M1, 11 + 11 + 11 + 11
*
* Can expand E4M3 reduction tree to 44 and pack one E3M2 adder inside of it
* Or expand to 50 and pack 2 E2M1 adders inside
*
* Would need to determine if this is better for area, vs. smaller trees
* outside
*/

import pkg_aitb::*;
/*
module e5m2_4_reduction #(
	parameter FP8_E5M2_INPUTS = 4,
	parameter FP8_E4M3_INPUTS = 4,
	parameter FP6_INPUTS      = 4,
	parameter FP4_INPUTS      = 4,

	parameter FP8_E5M2_INPUT_WIDTH = 67,
	parameter FP8_E4M3_INPUT_WIDTH = 37,
	parameter FP6_INPUT_WIDTH      = 19,
	parameter FP4_INPUT_WIDTH      =  9,

	parameter FP8_E5M2_LEVELS = $clog2(FP8_E5M2_INPUTS),
	parameter FP8_E4M3_LEVELS = $clog2(FP8_E5M2_INPUTS + FP8_E4M3_INPUTS),
	parameter FP6_LEVELS      = $clog2(FP6_INPUTS + FP8_E5M2_INPUTS + FP8_E4M3_INPUTS),
	parameter FP4_LEVELS      = $clog2(FP4_INPUTS + FP6_INPUTS + FP8_E5M2_INPUTS + FP8_E4M3_INPUTS),

	parameter FP8_E5M2_OUTPUT_WIDTH = FP8_E5M2_INPUT_WIDTH + FP8_E5M2_LEVELS,
	parameter FP8_E4M3_OUTPUT_WIDTH = FP8_E4M3_INPUT_WIDTH + FP8_E4M3_LEVELS,
	parameter FP6_OUTPUT_WIDTH      = FP6_INPUT_WIDTH + FP6_LEVELS,
	parameter FP4_OUTPUT_WIDTH      = FP4_INPUT_WIDTH + FP4_LEVELS
)(
	input mxfp_mode_e i_mxfp_mode,

	input logic signed [FP8_E5M2_INPUT_WIDTH-1:0] i_fp8_e5m2_ops [FP8_E5M2_INPUTS],
	input logic signed [FP8_E4M3_INPUT_WIDTH-1:0] i_fp8_e4m3_ops [FP8_E5M2_INPUTS],
	input logic signed [FP6_INPUT_WIDTH-1:0]      i_fp6_ops      [FP6_INPUTS],
	input logic signed [FP4_INPUT_WIDTH-1:0]      i_fp4_ops      [FP4_INPUTS],

	output logic signed [FP8_OUTPUT_WIDTH-1:0] o_sum
);
localparam PADDING     = FP8_LEVELS;
localparam SIGN_EXTEND = FP8_LEVELS;
localparam EXTEND_FP4  = FP6_INPUT_WIDTH - FP4_INPUT_WIDTH;
localparam OFFSET      = FP6_INPUT_WIDTH + PADDING;

localparam ADDER_LSB = FP6_INPUT_WIDTH + SIGN_EXTEND;
localparam ADDER_MSB = FP6_INPUT_WIDTH + PADDING;

logic signed [FP8_INPUT_WIDTH-1:0]  adder_in [FP8_INPUTS];
logic signed [FP8_OUTPUT_WIDTH-1:0] tree_sum;
logic signed [FP6_OUTPUT_WIDTH-1:0] fp6_fp4_sum;

// Assign adder inputs
// If input is not MXFP8, pack 2 inputs into the first level of the adder tree
always_comb begin
	for (int i = 0; i < FP8_INPUTS; i++) begin
		// Constant for all formats, FP8 is already sign extended FP6
		// in FP6 modes
		adder_in[i][FP8_INPUT_WIDTH-ADDER_MSB-1:0] = i_fp8_ops[i][FP8_INPUT_WIDTH-ADDER_MSB-1:0];

		if (i_mxfp_mode == MXFP8_52 || i_mxfp_mode == MXFP8_43) begin
			// FP8 modes, 1:1
			adder_in[i][FP8_INPUT_WIDTH-1:FP8_INPUT_WIDTH-ADDER_MSB] = i_fp8_ops[i][FP8_INPUT_WIDTH-1:FP8_INPUT_WIDTH-ADDER_MSB];
		end else begin
			// Apply padding for all non-MXFP8 formats
			adder_in[i][FP8_INPUT_WIDTH-ADDER_MSB+:PADDING] = 'b0;

			// Packing the FP6/4 inputs on the MSB allows us to
			// avoid sign extension for these inputs
			if (i < FP6_INPUTS) begin
				if (i < FIXED_ELEMENTS/2) begin
					// Pack FP6/FP4/FIXED results
					adder_in[i][(FP8_INPUT_WIDTH-1)-:FP6_INPUT_WIDTH] = i_fp6_ops[i];
				end else begin
					// Fixed point inputs will only use some of fp6_ops
					adder_in[i][(FP8_INPUT_WIDTH-1)-:FP6_INPUT_WIDTH] = 'b0;
				end
			end else begin
				// Pack FP4 results
				// Extend FP4 to FP6 bits
				if (i_mxfp_mode == MXFP4) begin
					adder_in[i][(FP8_INPUT_WIDTH-1)-:FP6_INPUT_WIDTH] = {{EXTEND_FP4{i_fp4_ops[i-FP6_INPUTS][FP4_INPUT_WIDTH-1]}}, i_fp4_ops[i-FP6_INPUTS]};
				end else begin
					// Zero for other formats
					adder_in[i][(FP8_INPUT_WIDTH-1)-:FP6_INPUT_WIDTH] = 'b0;
				end
			end
		end
	end
end

// Single shared reduction for all formats
pow2_reduction_norecurse #(
	.INPUTS(FP8_INPUTS), 
	.INPUT_WIDTH(FP8_INPUT_WIDTH)
) u_reduction (
	.i_op(adder_in),
	.o_sum(tree_sum)
);

// Output at final stage of reduction is 2 numbers for non-MXFP8 modes
// Add them together to form final output
logic signed [FP6_OUTPUT_WIDTH-2:0] op0, op1;

// MSB has 4 FP6, LSB has 8 FP6
assign op0 = tree_sum[0+:(FP6_OUTPUT_WIDTH-1)];
assign op1 = tree_sum[(FP8_OUTPUT_WIDTH-1)-:(FP6_OUTPUT_WIDTH-1)];

assign fp6_fp4_sum = op0 + op1;

assign o_sum = (i_mxfp_mode == MXFP8_43 || i_mxfp_mode == MXFP8_52) ? tree_sum
								    : fp6_fp4_sum;

endmodule*/
