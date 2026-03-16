/*
* Naive MXFP dot product implementation
*/
import pkg_aitb::*;

module naive_mxfp_dot_fixed #(
	parameter FIXED_DOT_LENGTH = 10,
	parameter FP8_DOT_LENGTH   =  8,
	parameter FP6_DOT_LENGTH   = 12,
	parameter FP4_DOT_LENGTH   = 16,

	parameter FIXED_OPS = FIXED_DOT_LENGTH,
	parameter FP8_OPS   = FP8_DOT_LENGTH,
	parameter FP6_OPS   = FP6_DOT_LENGTH - FP8_DOT_LENGTH,
	parameter FP4_OPS   = FP4_DOT_LENGTH - FP6_DOT_LENGTH,

	parameter PACKED_REDUCTION = 0
)(
	// Configuration
	//   MXFP Multiply
	input logic [2:0] i_sign_shift,
	input logic [2:0] i_exp_bits,
	input logic [1:0] i_man_bits,
	input logic [4:0] i_exp_mask,
	input logic [2:0] i_man_mask,
	//   Reduction
	input mxfp_mode_e i_mxfp_mode,

	// Data
	input logic signed [7:0] i_fixed_a [FIXED_OPS],
	input logic signed [7:0] i_fixed_b [FIXED_OPS],

	input logic [7:0] i_mxfp8_a [FP8_OPS],
	input logic [7:0] i_mxfp8_b [FP8_OPS],
	input logic [5:0] i_mxfp6_a [FP6_OPS],
	input logic [5:0] i_mxfp6_b [FP6_OPS],
	input logic [3:0] i_mxfp4_a [FP4_OPS],
	input logic [3:0] i_mxfp4_b [FP4_OPS],

	output logic signed [FIXED_RESULT_WIDTH-1:0] o_fixed_result
);
// Used fixed point multiplier result
logic fixed_mult;

assign fixed_mult = i_mxfp_mode == FIXED;

// Output fixed point results of mxfp_mult modules
logic signed [MXFP8_PRODUCT_WIDTH-1:0] mxfp8_mult_result [FP8_OPS];
logic signed [MXFP6_PRODUCT_WIDTH-1:0] mxfp6_mult_result [FP6_OPS];
logic signed [MXFP4_PRODUCT_WIDTH-1:0] mxfp4_mult_result [FP4_OPS];

logic inf_vec [FP8_OPS];
logic nan_vec [FP8_OPS];

genvar i;

// Instantiate MXFP Multipliers
generate
	// MXFP8
	for (i = 0; i < FP8_OPS; i++) begin : inst_mxfp8_mult
		mxfp_mult_shift #(
			.MAX_EXP_BITS(5), 
			.MAX_MAN_BITS(3),
			.MXFP_WIDTH(8),
			.FIXED_MULT(1),
			.OUTPUT_WIDTH(MXFP8_PRODUCT_WIDTH)
		) u_mxfp_mult_shift_mxfp8 (
			.fixed(fixed_mult),
			.sign_shift(i_sign_shift),
			.exp_bits(i_exp_bits),
			.man_bits(i_man_bits),
			.exp_mask(i_exp_mask),
			.man_mask(i_man_mask),

			.fixed_a(i_fixed_a[i]),
			.fixed_b(i_fixed_b[i]),
			.mxfp_a(i_mxfp8_a[i]),
			.mxfp_b(i_mxfp8_b[i]),

			.mxfp_mult_fixed(mxfp8_mult_result[i]),

			.inf(inf_vec[i]),
			.nan(nan_vec[i])
		);
	end

	// MXFP6
	for (i = 0; i < FP6_OPS; i++) begin : inst_mxfp6_mult
		// Only use FIXED_MULT up to the number of fixed_point inputs
		if (i + FP8_OPS < FIXED_OPS) begin
			mxfp_mult_shift #(
				.MAX_EXP_BITS(3), 
				.MAX_MAN_BITS(3),
				.MXFP_WIDTH(6),
				.FIXED_MULT(1),
				.OUTPUT_WIDTH(MXFP6_PRODUCT_WIDTH)
			) u_mxfp_mult_shift_mxfp6 (
				.fixed(fixed_mult),
				.sign_shift(i_sign_shift),
				.exp_bits(i_exp_bits),
				.man_bits(i_man_bits),
				.exp_mask(i_exp_mask),
				.man_mask(i_man_mask),

				.fixed_a(i_fixed_a[i+FP8_OPS]),
				.fixed_b(i_fixed_b[i+FP8_OPS]),
				.mxfp_a(i_mxfp6_a[i]),
				.mxfp_b(i_mxfp6_b[i]),

				.mxfp_mult_fixed(mxfp6_mult_result[i]),

				.inf(),
				.nan()
			);
		end else begin
			logic [MXFP6_PRODUCT_WIDTH-1:0] mxfp_mult_fixed;

			mxfp_mult_shift #(
				.MAX_EXP_BITS(3), 
				.MAX_MAN_BITS(3),
				.MXFP_WIDTH(6),
				.FIXED_MULT(0),
				.OUTPUT_WIDTH(MXFP6_PRODUCT_WIDTH)
			) u_mxfp_mult_shift_mxfp6 (
				.fixed(),
				.sign_shift(i_sign_shift),
				.exp_bits(i_exp_bits),
				.man_bits(i_man_bits),
				.exp_mask(i_exp_mask),
				.man_mask(i_man_mask),

				.fixed_a(),
				.fixed_b(),
				.mxfp_a(i_mxfp6_a[i]),
				.mxfp_b(i_mxfp6_b[i]),

				.mxfp_mult_fixed(mxfp_mult_fixed),

				.inf(),
				.nan()
			);

			// Force to 0 if using fixed point modes
			// Fixed point modes use the same adders as FP6
			assign mxfp6_mult_result[i] = fixed_mult == 1'b1 ? 'b0 : mxfp_mult_fixed;
		end
	end

	// MXFP4
	for (i = 0; i < FP4_OPS; i++) begin : inst_mxfp4_mult
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

			.mxfp_mult_fixed(mxfp4_mult_result[i]),

			.inf(),
			.nan()
		);
	end
endgenerate

// Sum products
generate
	if (PACKED_REDUCTION == 0) begin
		naive_reduction #(
			.FP8_INPUTS(FP8_OPS),
			.FP6_INPUTS(FP6_OPS),
			.FP4_INPUTS(FP4_OPS),
		
			.FP8_INPUT_WIDTH(MXFP8_PRODUCT_WIDTH),
			.FP6_INPUT_WIDTH(MXFP6_PRODUCT_WIDTH),
			.FP4_INPUT_WIDTH(MXFP4_PRODUCT_WIDTH)
		) u_naive_reduction (
			.i_mxfp_mode(i_mxfp_mode),
		
			.i_fp8_ops(mxfp8_mult_result),
			.i_fp6_ops(mxfp6_mult_result),
			.i_fp4_ops(mxfp4_mult_result),
		
			.o_sum(o_fixed_result)
		);
	end else begin
		packed_reduction #(
			.FP8_INPUTS(FP8_OPS),
			.FP6_INPUTS(FP6_OPS),
			.FP4_INPUTS(FP4_OPS),
		
			.FP8_INPUT_WIDTH(MXFP8_PRODUCT_WIDTH),
			.FP6_INPUT_WIDTH(MXFP6_PRODUCT_WIDTH),
			.FP4_INPUT_WIDTH(MXFP4_PRODUCT_WIDTH)
		) u_packed_reduction (
			.i_mxfp_mode(i_mxfp_mode),
		
			.i_fp8_ops(mxfp8_mult_result),
			.i_fp6_ops(mxfp6_mult_result),
			.i_fp4_ops(mxfp4_mult_result),
		
			.o_sum(o_fixed_result)
		);
	end
endgenerate

endmodule
