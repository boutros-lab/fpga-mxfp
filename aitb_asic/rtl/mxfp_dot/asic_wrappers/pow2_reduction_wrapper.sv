import pkg_aitb::*;

module pow2_reduction_wrapper #(
	parameter FP8_OPS = 8
)(
	input clk,
	input rst,
	input logic signed [MXFP8_PRODUCT_WIDTH-1:0] mxfp8_mult_result [FP8_OPS],
	output logic signed [FIXED_RESULT_WIDTH-1:0] o_fixed_result
);

logic signed [MXFP8_PRODUCT_WIDTH-1:0] mxfp8_mult_result_q [FP8_OPS];
logic signed [FIXED_RESULT_WIDTH-1:0]  o_fixed_result_d;

always_ff @(posedge clk) begin
	if (rst) begin
		for (int i = 0; i < FP8_OPS; i++) begin
			mxfp8_mult_result_q[i] <= 'b0;
		end

		o_fixed_result <= 'b0;
	end else begin
		for (int i = 0; i < FP8_OPS; i++) begin
			mxfp8_mult_result_q[i] <= mxfp8_mult_result[i];
		end

		o_fixed_result <= o_fixed_result_d;
	end
end

pow2_reduction #(
	.INPUTS(FP8_OPS), 
	.INPUT_WIDTH(MXFP8_PRODUCT_WIDTH)
) u_fp8_reduction (
	.i_op(mxfp8_mult_result_q),
	.o_sum(o_fixed_result_d)
);

endmodule
