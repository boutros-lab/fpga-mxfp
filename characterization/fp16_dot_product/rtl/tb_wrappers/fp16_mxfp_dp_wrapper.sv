// TB Wrapper for Direct-Vector Dot Product

module fp16_mxfp_dp_wrapper #(
	parameter exp_width = 2,
	parameter man_width = 1,
	parameter k         = 3,
   	parameter bit_width = 1 + exp_width + man_width
) (
	input  logic clk,
	input  logic rst,
	input  logic i_valid,
	output logic o_valid,
	input  logic [bit_width-1:0] i_vec_a[k],
	input  logic [bit_width-1:0] i_vec_b[k],
	input  logic [7:0] i_shared_exp_a,
	input  logic [7:0] i_shared_exp_b,
	output logic [31:0] o_result
);

localparam latency = 4 + 6 + ($clog2(k) - 2) * 3;

logic [latency-1:0] valid_sr;

always_ff @(posedge clk) begin
	if (rst) begin
		valid_sr <= 'b0;
	end else begin
		valid_sr <= {valid_sr[latency-2:0], i_valid};
	end
end

assign o_valid = valid_sr[latency-1];

fp16_mxfp_dp #(
	.exp_width(exp_width),
	.man_width(man_width),
	.k(k)
) u_fp16_mxfp_dp (
	.clk(clk),
	.rst(rst),
	.mxfp_in_a(i_vec_a),
	.mxfp_in_b(i_vec_b),
	.shared_exp_in_a(i_shared_exp_a),
	.shared_exp_in_b(i_shared_exp_b),
	.fp32_out(o_result)
);

endmodule
