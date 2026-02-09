// dot_fp with input and output register stages

module dot_fp_fp32 #(
   	parameter exp_width = 2,
    	parameter man_width = 1,
   	parameter k         = 32,
   	parameter bit_width = 1 + exp_width + man_width,
   	parameter out_width = 2 * ((1<<exp_width) + man_width) + $clog2(k),

	parameter input_stages  = 1,
	parameter dot_fp_stages = 1,
	parameter pipeline_add  = 1,
	parameter fp32_stages   = 1,
	parameter output_stages = 1
)(
	input  logic clk,
	input  logic rst,
	input  logic signed [bit_width-1:0] i_vec_a [k],
	input  logic signed [bit_width-1:0] i_vec_b [k],
	output logic        [33:0]          o_fp32_q // Flopoco FP32
);
	logic signed [bit_width-1:0] i_vec_a_q [k];
	logic signed [bit_width-1:0] i_vec_b_q [k];
	logic [out_width-1:0] o_dp;
	logic [out_width-1:0] o_dp_q;
	logic [33:0]          o_fp32; // Flopoco FP32

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

	dot_fp #(
		.exp_width(exp_width), 
		.man_width(man_width), 
		.k(k),
		.pipeline_stages(dot_fp_stages),
		.pipeline_add(pipeline_add)
	) u_dot_fp (
		.clk(clk),
		.rst(rst),
		.i_vec_a(i_vec_a_q),
		.i_vec_b(i_vec_b_q),
		.o_dp(o_dp)
	);

	pipeline #(
		.width(out_width), 
		.depth(fp32_stages)
	) u_pipeline_dp (
		.clk(clk), 
		.rst(rst), 
		.data(o_dp), 
		.data_q(o_dp_q)
	);

	generate
		if (exp_width == 2 && man_width == 1) begin
			MXFP_E2M1_to_FP32 
			fix_to_fp32 (
				.I(o_dp_q), 
				.O(o_fp32)
			);
		end else if (exp_width == 2 && man_width == 3) begin
			MXFP_E2M3_to_FP32 
			fix_to_fp32 (
				.I(o_dp_q), 
				.O(o_fp32)
			);
		end else if (exp_width == 3 && man_width == 2) begin
			MXFP_E3M2_to_FP32 
			fix_to_fp32 (
				.I(o_dp_q[23:0]), 
				.O(o_fp32)
			);
		end else if (exp_width == 4 && man_width == 3) begin
			MXFP_E4M3_to_FP32 
			fix_to_fp32 (
				.I(o_dp_q), 
				.O(o_fp32)
			);
		end else if (exp_width == 5 && man_width == 2) begin
			MXFP_E5M2_to_FP32 
			fix_to_fp32 (
				.I(o_dp_q), 
				.O(o_fp32)
			);
		end else begin
			$fatal("ERROR: Illegal MXFP Format");
		end
	endgenerate

	pipeline #(
		.width(34), 
		.depth(output_stages)
	) u_pipeline_out (
		.clk(clk), 
		.rst(rst), 
		.data(o_fp32), 
		.data_q(o_fp32_q)
	);

endmodule
