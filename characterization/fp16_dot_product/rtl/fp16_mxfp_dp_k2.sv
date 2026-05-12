// Length 2 dot product, for testing without DSP chaining

module fp16_mxfp_dp_k2 #(
   	parameter exp_width = 2,
    	parameter man_width = 1,
	parameter k = 2,
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
	localparam latency = 6;

	genvar i;
	
	logic [15:0] fp16_in_a [k];
	logic [15:0] fp16_in_b [k];

	logic [31:0] fp32_dp_out;
	
	generate
		for (i = 0; i < k; i++) begin : mxfp_to_fp16_loop
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

	sum_of_two u0 (
		.fp16_mult_top_a (fp16_in_a[0]), //   input,  width = 16, fp16_mult_top_a.fp16_mult_top_a
		.fp16_mult_top_b (fp16_in_b[0]), //   input,  width = 16, fp16_mult_top_b.fp16_mult_top_b
		.fp16_mult_bot_a (fp16_in_a[1]), //   input,  width = 16, fp16_mult_bot_a.fp16_mult_bot_a
		.fp16_mult_bot_b (fp16_in_b[1]), //   input,  width = 16, fp16_mult_bot_b.fp16_mult_bot_b
		.fp32_chainin    (32'b0),    //   input,  width = 32,    fp32_chainin.fp32_chainin
		.clr0            (rst),            //   input,   width = 1,            clr0.reset
		.clr1            (rst),            //   input,   width = 1,            clr1.reset
		.clk             (clk),             //   input,   width = 1,             clk.clk
		.ena             (3'b111),             //   input,   width = 3,             ena.ena
		.fp32_result     (fp32_dp_out)      //  output,  width = 32,     fp32_result.fp32_result
	);

	//assign fp32_out = fp32_dp_out;

	logic [15:0] shared_exp;
	logic [15:0] shared_exp_q;
	logic [7:0]  shared_exp_in_a_q;
	logic [7:0]  shared_exp_in_b_q;

	assign shared_exp = {shared_exp_in_a, shared_exp_in_b};
	assign {shared_exp_in_a_q, shared_exp_in_b_q} = shared_exp_q;

	pipeline #(
		.width(16), 
		.depth(latency)
	) u_pipeline (
		.clk(clk),
		.rst(rst),
		.data(shared_exp),
		.data_q(shared_exp_q)
	);

	add_shared_exp 
	u_add_shared_exp (
		.fp32_in(fp32_dp_out),
		.shared_exp_in_a(shared_exp_in_a_q),
		.shared_exp_in_b(shared_exp_in_b_q),
		.fp32_out(fp32_out)
	);

endmodule
