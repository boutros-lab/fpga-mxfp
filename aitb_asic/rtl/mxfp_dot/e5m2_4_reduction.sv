/*
* Sum/reduce input fixed point numbers (converted 
* from MXFP) for 4 input E5M2 dot product circuit
* Single adder tree for MXFP8 E5M2, rest of inputs are packed into this
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
	input logic signed [FP8_E4M3_INPUT_WIDTH-1:0] i_fp8_e4m3_ops [FP8_E4M3_INPUTS],
	input logic signed [FP6_INPUT_WIDTH-1:0]      i_fp6_ops      [FP6_INPUTS],
	input logic signed [FP4_INPUT_WIDTH-1:0]      i_fp4_ops      [FP4_INPUTS],

	output logic signed [FP8_E5M2_OUTPUT_WIDTH-1:0] o_sum
);
localparam ADDER_SIZE  = 78;
localparam ADDER_OUT   = ADDER_SIZE + FP8_E5M2_LEVELS;
localparam SIGN_EXTEND = FP8_E5M2_LEVELS;
localparam PADDING     = FP8_E5M2_LEVELS;

localparam E4M3_PARTIAL_WIDTH = FP8_E4M3_INPUT_WIDTH + FP8_E5M2_LEVELS;
localparam E4M3_OFFSET        = E4M3_PARTIAL_WIDTH + PADDING;
localparam FP6_PARTIAL_WIDTH  = FP6_INPUT_WIDTH + FP8_E5M2_LEVELS;
localparam FP6_OFFSET         = FP6_PARTIAL_WIDTH + PADDING;
localparam FP4_PARTIAL_WIDTH  = FP4_INPUT_WIDTH + FP8_E5M2_LEVELS;
localparam FP4_OFFSET         = FP4_PARTIAL_WIDTH + PADDING;

logic signed [ADDER_SIZE-1:0] adder_in [FP8_E5M2_INPUTS];
logic signed [ADDER_OUT-1:0]  tree_sum;

// Partial sums
logic signed [E4M3_PARTIAL_WIDTH-1:0] e4m3_partial [2];
logic signed [FP6_PARTIAL_WIDTH-1:0]  fp6_partial  [3];
logic signed [FP4_PARTIAL_WIDTH-1:0]  fp4_partial  [4];

// Full sums
logic signed [FP8_E5M2_OUTPUT_WIDTH-1:0] e5m2_sum;
logic signed [FP8_E4M3_OUTPUT_WIDTH-1:0] e4m3_sum;
logic signed [FP6_OUTPUT_WIDTH-1:0]      fp6_sum;
logic signed [FP4_OUTPUT_WIDTH-1:0]      fp4_sum;

logic e5m2_mode, e4m3_mode, fp6_mode, fp4_mode;

assign e5m2_mode = i_mxfp_mode == MXFP8_52;
assign e4m3_mode = i_mxfp_mode == MXFP8_43;
assign fp6_mode  = (i_mxfp_mode == MXFP6_32) || (i_mxfp_mode == MXFP6_23) || (i_mxfp_mode == FIXED);
assign fp4_mode  = i_mxfp_mode == MXFP4;

// Assign adder inputs
// If input is not MXFP8, pack 2 inputs into the first level of the adder tree
always_comb begin
	for (int i = 0; i < FP8_E5M2_INPUTS; i++) begin
		if (e5m2_mode) begin
			adder_in[i] = {i_fp8_e5m2_ops[i], {(ADDER_SIZE-FP8_E5M2_INPUT_WIDTH){1'b0}}};
		end else if (e4m3_mode) begin
			adder_in[i] = {i_fp8_e4m3_ops[i], {PADDING{1'b0}}, i_fp8_e5m2_ops[i][FP8_E4M3_INPUT_WIDTH+SIGN_EXTEND-1:0]};
		end else if (fp6_mode) begin
			adder_in[i] = {{SIGN_EXTEND{i_fp6_ops[i][FP6_INPUT_WIDTH-1]}}, i_fp6_ops[i], 
				       {PADDING{1'b0}}, i_fp8_e4m3_ops[i][FP6_INPUT_WIDTH+SIGN_EXTEND-1:0], 
				       {PADDING{1'b0}}, i_fp8_e5m2_ops[i][FP6_INPUT_WIDTH+SIGN_EXTEND-1:0]};
		end else begin
			adder_in[i] = {{SIGN_EXTEND{i_fp4_ops[i][FP4_INPUT_WIDTH-1]}}, i_fp4_ops[i], 
				       {PADDING{1'b0}}, i_fp6_ops[i][FP4_INPUT_WIDTH+SIGN_EXTEND-1:0], 
				       {PADDING{1'b0}}, i_fp8_e4m3_ops[i][FP4_INPUT_WIDTH+SIGN_EXTEND-1:0], 
				       {PADDING{1'b0}}, i_fp8_e5m2_ops[i][FP4_INPUT_WIDTH+SIGN_EXTEND-1:0]};
		end
	end
end

// Single shared reduction for all formats
pow2_reduction_norecurse #(
	.INPUTS(FP8_E5M2_INPUTS), 
	.INPUT_WIDTH(ADDER_SIZE)
) u_reduction (
	.i_op(adder_in),
	.o_sum(tree_sum)
);

assign e5m2_sum = tree_sum[(ADDER_OUT-1)-:FP8_E5M2_OUTPUT_WIDTH];

// Get Partial Sums
generate
	for (genvar i = 0; i < 2; i++) begin
		assign e4m3_partial[i] = tree_sum[i*E4M3_OFFSET+:E4M3_PARTIAL_WIDTH];
	end

	for (genvar i = 0; i < 3; i++) begin
		assign fp6_partial[i] = tree_sum[i*FP6_OFFSET+:FP6_PARTIAL_WIDTH];
	end

	for (genvar i = 0; i < 4; i++) begin
		assign fp4_partial[i] = tree_sum[i*FP4_OFFSET+:FP4_PARTIAL_WIDTH];
	end
endgenerate

// Get final sums for each mode, TODO, could do more packing here
assign e4m3_sum = e4m3_partial[0] + e4m3_partial[1];
assign fp6_sum  = fp6_partial[0] + fp6_partial[1] + fp6_partial[2];
assign fp4_sum  = fp4_partial[0] + fp4_partial[1] + fp4_partial[2] + fp4_partial[3];

// Assign final sum
assign o_sum = e5m2_mode ? e5m2_sum
			 : e4m3_mode ? e4m3_sum 
			 : fp6_mode ? fp6_sum 
			 : fp4_sum;

endmodule
