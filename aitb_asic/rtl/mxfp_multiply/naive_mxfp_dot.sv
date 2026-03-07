/*
* Naive MXFP dot product implementation
*/

module naive_mxfp_dot #(
	parameter FP8_DOT_LENGTH =  8,
	parameter FP6_DOT_LENGTH = 12,
	parameter FP4_DOT_LENGTH = 16,

	parameter FP8_OPS = FP8_DOT_LENGTH,
	parameter FP6_OPS = FP6_DOT_LENGTH - FP8_DOT_LENGTH,
	parameter FP4_OPS = FP4_DOT_LENGTH - FP6_DOT_LENGTH
)(
	// Configuration
	input logic [2:0] i_sign_shift,
	input logic [3:0] i_exp_bits,
	input logic [1:0] i_man_bits,
	input logic [2:0] i_mxfp_mode, // 000: E2M1, 001: E2M3, 010: E3M2, 011: E4M3, 100: E5M2
	input logic [$clog2(69)-1:0] i_point_position, //TODO

	// Data
	input logic [7:0] i_mxfp8_a [FP8_OPS],
	input logic [7:0] i_mxfp8_b [FP8_OPS],
	input logic [5:0] i_mxfp6_a [FP6_OPS],
	input logic [5:0] i_mxfp6_b [FP6_OPS],
	input logic [3:0] i_mxfp4_a [FP4_OPS],
	input logic [3:0] i_mxfp4_b [FP4_OPS],

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
			.MXFP_WIDTH(8)
		) u_mxfp_mul_shift_mxfp8 (
			.sign_shift(i_sign_shift),
			.exp_bits(i_exp_bits),
			.man_bits(i_man_bits),

			.mxfp_a(i_mxfp8_a[i]),
			.mxfp_b(i_mxfp8_b[i]),

			.mxfp_mult_fixed(mxfp8_mult_result[i]),

			.inf(inf_vec[i]),
			.nan(nan_vec[i])
		);
	end

	// MXFP6
	for (i = 0; i < FP6_OPS; i++) begin : inst_mxfp6_mult
		mxfp_mult_shift #(
			.MAX_EXP_BITS(3), 
			.MAX_MAN_BITS(3),
			.MXFP_WIDTH(6)
		) u_mxfp_mul_shift_mxfp8 (
			.sign_shift(i_sign_shift),
			.exp_bits(i_exp_bits),
			.man_bits(i_man_bits),

			.mxfp_a(i_mxfp6_a[i]),
			.mxfp_b(i_mxfp6_b[i]),

			.mxfp_mult_fixed(mxfp6_mult_result[i]),

			.inf(),
			.nan()
		);
	end

	// MXFP4
	for (i = 0; i < FP4_OPS; i++) begin : inst_mxfp4_mult
		mxfp_mult_shift #(
			.MAX_EXP_BITS(2), 
			.MAX_MAN_BITS(1),
			.MXFP_WIDTH(4)
		) u_mxfp_mul_shift_mxfp8 (
			.sign_shift(i_sign_shift),
			.exp_bits(i_exp_bits),
			.man_bits(i_man_bits),

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
config_fix2float 
u_fix2float (
	.i_point_position(i_point_position),
	.i_fixed(fixed_result[68:0]),
	.o_fp(o_fp32_result)
);

endmodule
