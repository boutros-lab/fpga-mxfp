module fp16_mxfp_dp_32 #(
   	parameter exp_width = 2,
    	parameter man_width = 1,
	parameter k = 32,
   	parameter bit_width = 1 + exp_width + man_width
) (
	input logic clk,
	input logic rst,
	input logic [bit_width-1:0] mxfp_in_a [k],
	input logic [bit_width-1:0] mxfp_in_b [k],
	input logic [7:0] shared_exp_in_a,
	input logic [7:0] shared_exp_in_b,
	output logic [31:0] fp32_out
);
	genvar i;
	
	logic [15:0] fp16_in_a [k];
	logic [15:0] fp16_in_b [k];

	logic [31:0] fp32_dp_out;
	
	generate
		for (i = 0; i < k; i++) begin
			mxfp_to_fp #(
				.exp_bits_i(exp_width), 
				.man_bits_i(man_width), 
				.exp_bits_o(5), 
				.man_bits_o(10)
			) u_mxfp_to_fp_a (
				.clk(clk),
				.rst(rst),
				.i_mxfp(mxfp_in_a[i]),
				.o_fp(fp16_in_a[i])
			);
	
			mxfp_to_fp #(
				.exp_bits_i(exp_width), 
				.man_bits_i(man_width), 
				.exp_bits_o(5), 
				.man_bits_o(10)
			) u_mxfp_to_fp_b (
				.clk(clk),
				.rst(rst),
				.i_mxfp(mxfp_in_b[i]),
				.o_fp(fp16_in_b[i])
			);
		end
	endgenerate

	fp16_32_dp #(
		.k(k)
	) u_fp16_32_dp (
		.clk(clk),
		.rst(rst),
		.fp16_in_a(fp16_in_a),
		.fp16_in_b(fp16_in_b),
		.fp32_out(fp32_dp_out)
	);

	// TODO: need to pipeline shared_exp_in_a/b
	
	add_shared_exp 
	u_add_shared_exp (
		.fp32_in(fp32_dp_out),
		.shared_exp_in_a(shared_exp_in_a),
		.shared_exp_in_b(shared_exp_in_b),
		.fp32_out(fp32_out),
	);

endmodule
