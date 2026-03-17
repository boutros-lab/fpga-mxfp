import pkg_aitb::*;

module naive_reduction_wrapper #(
	parameter FP8_OPS = 8,
	parameter FP6_OPS = 4,
	parameter FP4_OPS = 4
)(
	input clk,
	input rst,
	input mxfp_mode_e i_mxfp_mode,
	input logic signed [MXFP8_PRODUCT_WIDTH-1:0] mxfp8_mult_result [FP8_OPS],
	input logic signed [MXFP6_PRODUCT_WIDTH-1:0] mxfp6_mult_result [FP6_OPS],
	input logic signed [MXFP4_PRODUCT_WIDTH-1:0] mxfp4_mult_result [FP4_OPS],
	output logic signed [FIXED_RESULT_WIDTH-1:0] o_fixed_result
);

mxfp_mode_e i_mxfp_mode_q;
logic signed [MXFP8_PRODUCT_WIDTH-1:0] mxfp8_mult_result_q [FP8_OPS];
logic signed [MXFP6_PRODUCT_WIDTH-1:0] mxfp6_mult_result_q [FP6_OPS];
logic signed [MXFP4_PRODUCT_WIDTH-1:0] mxfp4_mult_result_q [FP4_OPS];
logic signed [FIXED_RESULT_WIDTH-1:0]  o_fixed_result_d;

always_ff @(posedge clk) begin
	if (rst) begin
		i_mxfp_mode_q <= MXFP4;

		for (int i = 0; i < FP8_OPS; i++) begin
			mxfp8_mult_result_q[i] <= 'b0;
		end

		for (int i = 0; i < FP6_OPS; i++) begin
			mxfp6_mult_result_q[i] <= 'b0;
		end

		for (int i = 0; i < FP4_OPS; i++) begin
			mxfp4_mult_result_q[i] <= 'b0;
		end

		o_fixed_result <= 'b0;
	end else begin
		i_mxfp_mode_q <= i_mxfp_mode;

		for (int i = 0; i < FP8_OPS; i++) begin
			mxfp8_mult_result_q[i] <= mxfp8_mult_result[i];
		end

		for (int i = 0; i < FP6_OPS; i++) begin
			mxfp6_mult_result_q[i] <= mxfp6_mult_result[i];
		end

		for (int i = 0; i < FP4_OPS; i++) begin
			mxfp4_mult_result_q[i] <= mxfp4_mult_result[i];
		end

		o_fixed_result <= o_fixed_result_d;
	end
end

naive_reduction #(
	.FP8_INPUTS(FP8_OPS),
	.FP6_INPUTS(FP6_OPS),
	.FP4_INPUTS(FP4_OPS),

	.FP8_INPUT_WIDTH(MXFP8_PRODUCT_WIDTH),
	.FP6_INPUT_WIDTH(MXFP6_PRODUCT_WIDTH),
	.FP4_INPUT_WIDTH(MXFP4_PRODUCT_WIDTH)
) u_naive_reduction (
	.i_mxfp_mode(i_mxfp_mode_q),

	.i_fp8_ops(mxfp8_mult_result_q),
	.i_fp6_ops(mxfp6_mult_result_q),
	.i_fp4_ops(mxfp4_mult_result_q),

	.o_sum(o_fixed_result_d)
);

endmodule
