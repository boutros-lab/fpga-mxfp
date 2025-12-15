module fp16_32_dp #(
	parameter k = 32
) (
	input logic clk,
	input logic rst,
	input logic [15:0] fp16_in_a [k],
	input logic [15:0] fp16_in_b [k],
	output logic [31:0] fp32_out
);

	logic [31:0] fp32_input  [k/2];
	logic [31:0] fp32_result [k/2];
	logic [31:0] fp32_chain  [k/2];

	// No chain in to final DSP
	assign fp32_chain[k/2 - 1] = 'b0;

	// DSP 0 is sum_of_two, does not accept FP32 adder input, this signal
	// will go unused
	assign fp32_input[0] = 'b0;

	assign fp32_out = fp32_result[3];

	// Sum of Two mode:
	// 	FP32 result is sum of FP32 chainin and FP16 products
	//
	// Vector Two mode:
	// 	Fp32 result is sum of FP32 chainin and FP32 adder_a
	// 	Fp32 chain out is sum of FP16 products
	//
	// Vector One mode:
	// 	Fp32 result is sum of FP16 products and FP32 adder_a
	// 	FP32 chainout is FP32 adder_a

	always_comb begin
		// DSP Result-input chaining
		// TODO: currently not correct, needs to be fixed

		// v2
		fp32_input[1] = fp32_result[0]; // AB + CD + EF + GH
		// v1
		fp32_input[2] = fp32_result[2]; // IJ + KL + MN + OP
		// v2
		fp32_input[3] = fp32_result[1]; // AB + CD + EF + GH + IJ + KL + MN + OP
		// v1
		fp32_input[4] = fp32_result[5]; // QR + ST + UV + WX + YZ + ab + cd + ef

		for (int i = 5; i < k/2; i++) begin
			fp32_input[i] = fp32_result[i - 1];
		end
	end

	genvar i;

	generate
		for (i = 0; i < k/2; i++) begin
			if (i == 0) begin
				// Terminal sum_of_two
				sum_of_two u_sum_of_two (
					.fp16_mult_top_a (fp16_in_a[i*2]), //   input,  width = 16, fp16_mult_top_a.fp16_mult_top_a
					.fp16_mult_top_b (fp16_in_b[i*2]), //   input,  width = 16, fp16_mult_top_b.fp16_mult_top_b
					.fp16_mult_bot_a (fp16_in_a[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_a.fp16_mult_bot_a
					.fp16_mult_bot_b (fp16_in_b[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_b.fp16_mult_bot_b
					.fp32_chainin    (fp32_chain[i]),    //   input,  width = 32,    fp32_chainin.fp32_chainin
					.clr0            (rst),            //   input,   width = 1,            clr0.reset
					.clr1            (rst),            //   input,   width = 1,            clr1.reset
					.clk             (clk),             //   input,   width = 1,             clk.clk
					.ena             (3'b111),             //   input,   width = 3,             ena.ena
					.fp32_result     (fp32_result[i])      //  output,  width = 32,     fp32_result.fp32_result
				);
			end else if ((i%2) == 1) begin
				// Vector two
				if (i != (k/2 -1)) begin
					vector_two u_vector_two_0 (
						.fp16_mult_top_a (fp16_in_a[i*2]), //   input,  width = 16, fp16_mult_top_a.fp16_mult_top_a
						.fp16_mult_top_b (fp16_in_b[i*2]), //   input,  width = 16, fp16_mult_top_b.fp16_mult_top_b
						.fp16_mult_bot_a (fp16_in_a[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_a.fp16_mult_bot_a
						.fp16_mult_bot_b (fp16_in_b[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_b.fp16_mult_bot_b
						.fp32_chainin    (fp32_chain[i]),    //   input,  width = 32,    fp32_chainin.fp32_chainin
						.fp32_adder_a    (fp32_input[i]),    //   input,  width = 32,    fp32_adder_a.fp32_adder_a
						.clr0            (rst),            //   input,   width = 1,            clr0.reset
						.clr1            (rst),            //   input,   width = 1,            clr1.reset
						.clk             (clk),             //   input,   width = 1,             clk.clk
						.ena             (3'b111),             //   input,   width = 3,             ena.ena
						.fp32_result     (fp32_result[i]),     //  output,  width = 32,     fp32_result.fp32_result
						.fp32_chainout   (fp32_chain[i-1])    //  output,  width = 32,   fp32_chainout.fp32_chainout
					);
				end else begin
					// Terminal DSP has no chain in
					vector_two_no_chainin u_vector_two_no_chainin (
						.fp16_mult_top_a (fp16_in_a[i*2]), //   input,  width = 16, fp16_mult_top_a.fp16_mult_top_a
						.fp16_mult_top_b (fp16_in_b[i*2]), //   input,  width = 16, fp16_mult_top_b.fp16_mult_top_b
						.fp16_mult_bot_a (fp16_in_a[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_a.fp16_mult_bot_a
						.fp16_mult_bot_b (fp16_in_b[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_b.fp16_mult_bot_b
						.fp32_adder_a    (fp32_input[i]),    //   input,  width = 32,    fp32_adder_a.fp32_adder_a
						.clr0            (rst),            //   input,   width = 1,            clr0.reset
						.clr1            (rst),            //   input,   width = 1,            clr1.reset
						.clk             (clk),             //   input,   width = 1,             clk.clk
						.ena             (3'b111),             //   input,   width = 3,             ena.ena
						.fp32_result     (fp32_result[i]),     //  output,  width = 32,     fp32_result.fp32_result
						.fp32_chainout   (fp32_chain[i-1])    //  output,  width = 32,   fp32_chainout.fp32_chainout
					);
				end
			end else begin
				// Vector one
				if (i != (k/2 -1)) begin
					vector_two u_vector_two_0 (
						.fp16_mult_top_a (fp16_in_a[i*2]), //   input,  width = 16, fp16_mult_top_a.fp16_mult_top_a
						.fp16_mult_top_b (fp16_in_b[i*2]), //   input,  width = 16, fp16_mult_top_b.fp16_mult_top_b
						.fp16_mult_bot_a (fp16_in_a[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_a.fp16_mult_bot_a
						.fp16_mult_bot_b (fp16_in_b[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_b.fp16_mult_bot_b
						.fp32_chainin    (fp32_chain[i]),    //   input,  width = 32,    fp32_chainin.fp32_chainin
						.fp32_adder_a    (fp32_input[i]),    //   input,  width = 32,    fp32_adder_a.fp32_adder_a
						.clr0            (rst),            //   input,   width = 1,            clr0.reset
						.clr1            (rst),            //   input,   width = 1,            clr1.reset
						.clk             (clk),             //   input,   width = 1,             clk.clk
						.ena             (3'b111),             //   input,   width = 3,             ena.ena
						.fp32_result     (fp32_result[i]),     //  output,  width = 32,     fp32_result.fp32_result
						.fp32_chainout   (fp32_chain[i-1])    //  output,  width = 32,   fp32_chainout.fp32_chainout
					);
				end else begin
					// Terminal DSP has no chain in
					vector_two_no_chainin u_vector_two_no_chainin (
						.fp16_mult_top_a (fp16_in_a[i*2]), //   input,  width = 16, fp16_mult_top_a.fp16_mult_top_a
						.fp16_mult_top_b (fp16_in_b[i*2]), //   input,  width = 16, fp16_mult_top_b.fp16_mult_top_b
						.fp16_mult_bot_a (fp16_in_a[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_a.fp16_mult_bot_a
						.fp16_mult_bot_b (fp16_in_b[i*2 + 1]), //   input,  width = 16, fp16_mult_bot_b.fp16_mult_bot_b
						.fp32_adder_a    (fp32_input[i]),    //   input,  width = 32,    fp32_adder_a.fp32_adder_a
						.clr0            (rst),            //   input,   width = 1,            clr0.reset
						.clr1            (rst),            //   input,   width = 1,            clr1.reset
						.clk             (clk),             //   input,   width = 1,             clk.clk
						.ena             (3'b111),             //   input,   width = 3,             ena.ena
						.fp32_result     (fp32_result[i]),     //  output,  width = 32,     fp32_result.fp32_result
						.fp32_chainout   (fp32_chain[i-1])    //  output,  width = 32,   fp32_chainout.fp32_chainout
					);
				end
			end
		end
	endgenerate

endmodule
