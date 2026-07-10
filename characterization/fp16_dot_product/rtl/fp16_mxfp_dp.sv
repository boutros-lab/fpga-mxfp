// Variable length FP16 dot product
// MXFP inputs, FP32 output, with shared exponent
// handling

module fp16_mxfp_dp #(
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
	localparam DP_LATENCY     = k > 2 ? (6 + ($clog2(k) - 2) * 3) : 6;
	localparam SH_EXP_LATENCY = 3 + DP_LATENCY;

	genvar i;

	logic [bit_width-1:0] mxfp_in_a_q [k];
	logic [bit_width-1:0] mxfp_in_b_q [k];
	logic [7:0] shared_exp_in_a_q;
	logic [7:0] shared_exp_in_b_q;
	
	logic [15:0] fp16_in_a   [k];
	logic [15:0] fp16_in_b   [k];
	logic [15:0] fp16_in_a_q [k];
	logic [15:0] fp16_in_b_q [k];

	logic [31:0] fp32_dp_out;
	logic [31:0] fp32_sh_in;
	logic [31:0] fp32_sh_out;

	// Register inputs/outputs
	always_ff @(posedge clk) begin
		if (rst) begin
			for (int i =0; i < k; i++) begin
				mxfp_in_a_q[i] <= 'b0;
				mxfp_in_b_q[i] <= 'b0;

				fp16_in_a_q[i] <= 'b0;
				fp16_in_b_q[i] <= 'b0;
			end

			fp32_sh_in <= 32'b0;
			fp32_out   <= 32'b0;
		end else begin
			for (int i =0; i < k; i++) begin
				mxfp_in_a_q[i] <= mxfp_in_a[i];
				mxfp_in_b_q[i] <= mxfp_in_b[i];

				fp16_in_a_q[i] <= fp16_in_a[i];
				fp16_in_b_q[i] <= fp16_in_b[i];
			end

			fp32_sh_in <= fp32_dp_out;
			fp32_out   <= fp32_sh_out;
		end
	end
	
	generate
		for (i = 0; i < k; i++) begin
			mxfp_to_fp #(
				.exp_bits_i(exp_width), 
				.man_bits_i(man_width), 
				.exp_bits_o(5), 
				.man_bits_o(10)
			) u_mxfp_to_fp_a (
				.i_mxfp(mxfp_in_a_q[i]),
				.o_fp(fp16_in_a[i])
			);
	
			mxfp_to_fp #(
				.exp_bits_i(exp_width), 
				.man_bits_i(man_width), 
				.exp_bits_o(5), 
				.man_bits_o(10)
			) u_mxfp_to_fp_b (
				.i_mxfp(mxfp_in_b_q[i]),
				.o_fp(fp16_in_b[i])
			);
		end
	endgenerate
	
	direct_vector_dp #(
		.k(k)
	) u_direct_vector_dp (
		.clk(clk),
		.rst(rst),
		.fp16_in_a(fp16_in_a_q),
		.fp16_in_b(fp16_in_b_q),
		.fp32_out(fp32_dp_out)
	);
	

	pipeline #(
		.width(16), 
		.depth(SH_EXP_LATENCY)
	) u_pipeline (
		.clk(clk),
		.rst(rst),
		.data({shared_exp_in_a, shared_exp_in_b}),
		.data_q({shared_exp_in_a_q, shared_exp_in_b_q})
	);

	add_shared_exp 
	u_add_shared_exp (
		.fp32_in(fp32_sh_in),
		.shared_exp_in_a(shared_exp_in_a_q),
		.shared_exp_in_b(shared_exp_in_b_q),
		.fp32_out(fp32_sh_out)
	);

endmodule
