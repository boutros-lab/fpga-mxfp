/*
* Naive MXFP dot product implementation
*/
import pkg_aitb::*;

module e2m1_mxfp_dot_fixed #(
	parameter FIXED_DOT_LENGTH = 10,
	parameter FP4_DOT_LENGTH   = 16,

	parameter FIXED_OPS = FIXED_DOT_LENGTH,
	parameter FP4_OPS   = FP4_DOT_LENGTH,

	parameter PACKED_REDUCTION = 0,
	parameter FIXED_RESULT_WIDTH = 16 + $clog2(FIXED_DOT_LENGTH)
)(
	// Configuration
	input mxfp_mode_e i_mxfp_mode,

	// Data
	input logic signed [7:0] i_fixed_a [FIXED_OPS],
	input logic signed [7:0] i_fixed_b [FIXED_OPS],

	input logic [3:0] i_mxfp4_a [FP4_OPS],
	input logic [3:0] i_mxfp4_b [FP4_OPS],

	output logic signed [FIXED_RESULT_WIDTH-1:0] o_fixed_result
);
localparam FIXED_PRODUCT_WIDTH = 16;
localparam FP4_ONLY_OPS        = FP4_OPS - FIXED_OPS;

// Use fixed point multiplier result
logic fixed_mult;

assign fixed_mult = i_mxfp_mode == FIXED;

// Output fixed point results of mxfp_mult modules
logic signed [FIXED_PRODUCT_WIDTH-1:0] mxfp4_fixed_mult_result [FIXED_OPS];
logic signed [MXFP4_PRODUCT_WIDTH-1:0] mxfp4_mult_result       [FP4_ONLY_OPS];

genvar i;

// Instantiate MXFP Multipliers
generate
	// MXFP6
	for (i = 0; i < FP4_OPS; i++) begin : inst_mxfp6_mult
		// Only use FIXED_MULT up to the number of fixed_point inputs
		if (i < FIXED_OPS) begin
			mxfp_mult_shift #(
				.MAX_EXP_BITS(2), 
				.MAX_MAN_BITS(1),
				.MXFP_WIDTH(4),
				.FIXED_MULT(1),
				.OUTPUT_WIDTH(FIXED_PRODUCT_WIDTH)
			) u_mxfp_mult_shift_mxfp4 (
				.fixed(fixed_mult),
				.sign_shift(),
				.exp_bits(),
				.man_bits(),
				.exp_mask(),
				.man_mask(),

				.fixed_a(i_fixed_a[i]),
				.fixed_b(i_fixed_b[i]),
				.mxfp_a(i_mxfp4_a[i]),
				.mxfp_b(i_mxfp4_b[i]),

				.mxfp_mult_fixed(mxfp4_fixed_mult_result[i]),

				.inf(),
				.nan()
			);
		end else begin
			mxfp_mult_shift #(
				.MAX_EXP_BITS(2), 
				.MAX_MAN_BITS(1),
				.MXFP_WIDTH(4),
				.FIXED_MULT(0),
				.OUTPUT_WIDTH(MXFP4_PRODUCT_WIDTH)
			) u_mxfp_mult_shift_mxfp4 (
				.fixed(),
				.sign_shift(),
				.exp_bits(),
				.man_bits(),
				.exp_mask(),
				.man_mask(),

				.fixed_a(),
				.fixed_b(),
				.mxfp_a(i_mxfp4_a[i]),
				.mxfp_b(i_mxfp4_b[i]),

				.mxfp_mult_fixed(mxfp4_mult_result[i-FIXED_OPS]),

				.inf(),
				.nan()
			);
		end
	end
endgenerate

// Sum products
e2m1_reduction #(
	.FIXED_INPUTS(FIXED_OPS),
	.FP4_INPUTS(FP4_ONLY_OPS),

	.FIXED_INPUT_WIDTH(FIXED_PRODUCT_WIDTH),
	.FP4_INPUT_WIDTH(MXFP4_PRODUCT_WIDTH)
) u_naive_reduction (
	.i_mxfp_mode(i_mxfp_mode),

	.i_fixed_ops(mxfp4_fixed_mult_result),
	.i_fp4_ops(mxfp4_mult_result),

	.o_sum(o_fixed_result)
);

endmodule
