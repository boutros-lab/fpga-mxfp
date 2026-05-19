// dot_fp with input and output register stages

module dot_fp_staged #(
   	parameter exp_width = 2,
    	parameter man_width = 1,
   	parameter k         = 32,
   	parameter bit_width = 1 + exp_width + man_width,
   	parameter out_width = 2 * ((1<<exp_width) + man_width) + $clog2(k),

	parameter input_stages  = 1,
	parameter dot_fp_stages = 1,
	parameter output_stages = 1
)(
	input logic clk,
	input logic rst,
	input logic signed [bit_width-1:0] i_vec_a [k],
	input logic signed [bit_width-1:0] i_vec_b [k],
	output logic signed [out_width-1:0] o_dp_q
);
	logic signed [bit_width-1:0] i_vec_a_q [k];
	logic signed [bit_width-1:0] i_vec_b_q [k];
	logic [out_width-1:0] o_dp;

	genvar i;

	generate
		for (i = 0; i < k; i++) begin
			pipeline #(
				.width(2*bit_width), 
				.depth(input_stages)
			) u_pipeline_in (
				.clk(clk), 
				.rst(rst), 
				.data({i_vec_a[i], i_vec_b[i]}), 
				.data_q({i_vec_a_q[i], i_vec_b_q[i]})
			);
		end
	endgenerate

	pipeline #(
		.width(out_width), 
		.depth(output_stages)
	) u_pipeline_out (
		.clk(clk), 
		.rst(rst), 
		.data(o_dp), 
		.data_q(o_dp_q)
	);

	dot_fp #(
		.exp_width(exp_width), 
		.man_width(man_width), 
		.k(k),
		.pipeline_stages(dot_fp_stages)
	) u_dot_fp (
		.clk(clk),
		.rst(rst),
		.i_vec_a(i_vec_a_q),
		.i_vec_b(i_vec_b_q),
		.o_dp(o_dp)
	);

endmodule
