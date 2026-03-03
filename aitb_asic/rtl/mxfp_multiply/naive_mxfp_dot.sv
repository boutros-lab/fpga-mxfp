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
	input logic [2:0] sign_shift,
	input logic [3:0] exp_bits,
	input logic [1:0] man_bits,
	logic [2:0] mxfp_mode, // 000: E2M1, 001: E2M3, 010: E3M2, 011: E4M3, 100: E5M2

	input logic [7:0] mxfp8_a [FP8_OPS],
	input logic [7:0] mxfp8_b [FP8_OPS],
	input logic [5:0] mxfp6_a [FP6_OPS],
	input logic [5:0] mxfp6_b [FP6_OPS],
	input logic [3:0] mxfp4_a [FP4_OPS],
	input logic [3:0] mxfp4_b [FP4_OPS],

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
			.sign_shift(sign_shift),
			.exp_bits(exp_bits),
			.man_bits(man_bits),

			.mxfp_a(mxfp8_a[i]),
			.mxfp_b(mxfp8_b[i]),

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
			.sign_shift(sign_shift),
			.exp_bits(exp_bits),
			.man_bits(man_bits),

			.mxfp_a(mxfp6_a[i]),
			.mxfp_b(mxfp6_b[i]),

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
			.sign_shift(sign_shift),
			.exp_bits(exp_bits),
			.man_bits(man_bits),

			.mxfp_a(mxfp6_a[i]),
			.mxfp_b(mxfp6_b[i]),

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
	.mxfp_mode(mxfp_mode),

	.i_fp8_ops(mxfp8_mult_result),
	.i_fp6_ops(mxfp6_mult_result),
	.i_fp4_ops(mxfp4_mult_result),

	.o_sum(fixed_result)
);

// Convert to FP32
// TODO: this should all become one module once configurable fix2float is
// available, code below is temporary
// The widths are off since we're using circuits intended for smaller formats,
// and intended for K=32

logic [33:0] flopoco_fp32 [5];

MXFP_E2M1_to_FP32 
ufix_to_fp32_e2m1 (
	.I(fixed_result[14:0]),
	.O(flopoco_fp32[0])
);

MXFP_E2M3_to_FP32 
ufix_to_fp32_e2m3 (
	.I(fixed_result[18:0]),
	.O(flopoco_fp32[1])
);

MXFP_E3M2_to_FP32 
ufix_to_fp32_e3m2 (
	.I(fixed_result[23:0]),
	.O(flopoco_fp32[2])
);

MXFP_E4M3_to_FP32 
ufix_to_fp32_e4m3 (
	.I(fixed_result[42:0]),
	.O(flopoco_fp32[3])
);

MXFP_E5M2_to_FP32 
ufix_to_fp32_e5m2 (
	.I(fixed_result[72:0]),
	.O(flopoco_fp32[4])
);

assign o_fp32_result = mxfp_mode == 3'b000 ? flopoco_fp32[0][31:0]
					   : mxfp_mode == 3'b001 ? flopoco_fp32[1][31:0]
					   : mxfp_mode == 3'b010 ? flopoco_fp32[2][31:0]
					   : mxfp_mode == 3'b011 ? flopoco_fp32[3][31:0]
					   : flopoco_fp32[4][31:0];

endmodule
