/*
* Naive MXFP dot product implementation
*/

module naive_mxfp_dot #(
	parameter FIXED_DOT_LENGTH = 10,
	parameter FP8_DOT_LENGTH   =  8,
	parameter FP6_DOT_LENGTH   = 12,
	parameter FP4_DOT_LENGTH   = 16,

	parameter FIXED_OPS = FIXED_DOT_LENGTH,
	parameter FP8_OPS   = FP8_DOT_LENGTH,
	parameter FP6_OPS   = FP6_DOT_LENGTH - FP8_DOT_LENGTH,
	parameter FP4_OPS   = FP4_DOT_LENGTH - FP6_DOT_LENGTH
)(
	// Configuration
	//   MXFP Multiply
	input logic [2:0] i_sign_shift,
	input logic [3:0] i_exp_bits,
	input logic [1:0] i_man_bits,
	input logic [4:0] i_exp_mask,
	input logic [2:0] i_man_mask,
	//   Reduction
	input logic [2:0] i_mxfp_mode, // 000: E2M1, 001: E2M3, 010: E3M2, 011: E4M3, 100: E5M2, default: Fixed
	//   Fix2Float
	input logic signed [7:0] i_exponent_correction,

	// Data
	input logic signed [7:0] i_fixed_a [FIXED_OPS],
	input logic signed [7:0] i_fixed_b [FIXED_OPS],

	input logic [7:0] i_mxfp8_a [FP8_OPS],
	input logic [7:0] i_mxfp8_b [FP8_OPS],
	input logic [5:0] i_mxfp6_a [FP6_OPS],
	input logic [5:0] i_mxfp6_b [FP6_OPS],
	input logic [3:0] i_mxfp4_a [FP4_OPS],
	input logic [3:0] i_mxfp4_b [FP4_OPS],

	input logic [7:0] i_shared_exp_a,
	input logic [7:0] i_shared_exp_b,

	output logic [31:0] o_fp32_result
);
localparam MXFP8_MAX_EXP = 5;
localparam MXFP8_MAX_MAN = 3;
localparam MXFP8_WIDTH   = 8;
localparam MXFP6_MAX_EXP = 3;
localparam MXFP6_MAX_MAN = 3;
localparam MXFP6_WIDTH   = 6;
localparam MXFP4_MAX_EXP = 2;
localparam MXFP4_MAX_MAN = 1;
localparam MXFP4_WIDTH   = 4;

localparam MXFP8_PRODUCT_WIDTH = 2 * ((1 << MXFP8_MAX_EXP) + MXFP8_MAX_MAN); // TODO, these can be smaller
localparam MXFP6_PRODUCT_WIDTH = 2 * ((1 << MXFP6_MAX_EXP) + MXFP6_MAX_MAN);
localparam MXFP4_PRODUCT_WIDTH = 2 * ((1 << MXFP4_MAX_EXP) + MXFP4_MAX_MAN);

localparam FIXED_RESULT_WIDTH = MXFP8_PRODUCT_WIDTH + $clog2(FP8_OPS);

// Used fixed point multiplier result
logic fixed_mult;

assign fixed_mult = i_mxfp_mode > 3'b100;

// Output fixed point results of mxfp_mult modules
logic signed [MXFP8_PRODUCT_WIDTH-1:0] mxfp8_mult_result [FP8_OPS];
logic signed [MXFP6_PRODUCT_WIDTH-1:0] mxfp6_mult_result [FP6_OPS];
logic signed [MXFP4_PRODUCT_WIDTH-1:0] mxfp4_mult_result [FP4_OPS];

logic inf_vec [FP8_OPS];
logic nan_vec [FP8_OPS];

// Output of reduction tree
logic signed [FIXED_RESULT_WIDTH-1:0] fixed_result;

genvar i;

// Instantiate MXFP Multipliers
generate
	// MXFP8
	for (i = 0; i < FP8_OPS; i++) begin : inst_mxfp8_mult
		mxfp_mult_shift #(
			.MAX_EXP_BITS(5), 
			.MAX_MAN_BITS(3),
			.MXFP_WIDTH(8),
			.FIXED_MULT(1)
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
				.FIXED_MULT(1)
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
				.FIXED_MULT(0)
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
			.FIXED_MULT(0)
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
naive_reduction #(
	.FP8_INPUTS(FP8_OPS),
	.FP6_INPUTS(FP6_OPS),
	.FP4_INPUTS(FP4_OPS),

	.FP8_INPUT_WIDTH(MXFP8_PRODUCT_WIDTH),
	.FP6_INPUT_WIDTH(MXFP6_PRODUCT_WIDTH),
	.FP4_INPUT_WIDTH(MXFP4_PRODUCT_WIDTH)
) u_naive_reduction (
	.mxfp_mode(i_mxfp_mode),

	.i_fp8_ops(mxfp8_mult_result),
	.i_fp6_ops(mxfp6_mult_result),
	.i_fp4_ops(mxfp4_mult_result),

	.o_sum(fixed_result)
);

// Convert to FP32
config_fix2fp32 
u_fix2fp32 (
	.i_exponent_correction(i_exponent_correction),
	.i_fixed(fixed_result[68:0]),
	.i_shared_exp_a(i_shared_exp_a),
	.i_shared_exp_b(i_shared_exp_b),
	.o_fp(o_fp32_result)
);

endmodule
