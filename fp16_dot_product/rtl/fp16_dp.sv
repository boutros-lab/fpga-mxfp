module fp16_dp #(
	parameter k = 2
) (
	input logic clk,
	input logic rst,
	input logic [15:0] fp16_in [k],
	input logic [31:0] fp32_in,
	output logic [31:0] fp32_out
);

	sum_of_two u0 (
		.fp16_mult_top_a (fp16_in[0]), //   input,  width = 16, fp16_mult_top_a.fp16_mult_top_a
		.fp16_mult_top_b (fp16_in[1]), //   input,  width = 16, fp16_mult_top_b.fp16_mult_top_b
		.fp16_mult_bot_a (fp16_in[2]), //   input,  width = 16, fp16_mult_bot_a.fp16_mult_bot_a
		.fp16_mult_bot_b (fp16_in[3]), //   input,  width = 16, fp16_mult_bot_b.fp16_mult_bot_b
		.fp32_chainin    (fp32_in),    //   input,  width = 32,    fp32_chainin.fp32_chainin
		.clr0            (rst),            //   input,   width = 1,            clr0.reset
		.clr1            (rst),            //   input,   width = 1,            clr1.reset
		.clk             (clk),             //   input,   width = 1,             clk.clk
		.ena             (3'b111),             //   input,   width = 3,             ena.ena
		.fp32_result     (fp32_out)      //  output,  width = 32,     fp32_result.fp32_result
	);

endmodule
