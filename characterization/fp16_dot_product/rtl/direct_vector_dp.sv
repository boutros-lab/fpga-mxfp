// Chained FP16 DSPs creating a dot product

module direct_vector_dp #(
	parameter k = 32
) (
	input logic clk,
	input logic rst,
	input logic [15:0] fp16_in_a [k],
	input logic [15:0] fp16_in_b [k],
	output logic [31:0] fp32_out
);

initial begin
	assert ((k % 8) == 0) else 
		$fatal ("ERROR: Direct vector dp K value must be a multiple of 8");
end

logic [31:0] fp32_chain [4];
logic [31:0] fp32_out_1 [4];
logic [31:0] fp32_out_3 [4];

// RIGHT
four_dsp_block  #(
	.LAST(1)
) u_four_dsp_block_3 (
	.clk(clk),
	.rst(rst),
	.fp16_in_a(fp16_in_a[24:31]),
	.fp16_in_b(fp16_in_b[24:31]),
	.fp32_in_0(fp32_out_1[3]), // out_1, of block 3
	.fp32_in_3(), // None, terminal
	.fp32_chain_in(), // None, terminal
	.fp32_out_1(fp32_out_1[3]), // output of block 3
	.fp32_out_3(), // no output
	.fp32_chain_out(fp32_chain[3])
);

four_dsp_block 
u_four_dsp_block_2 (
	.clk(clk),
	.rst(rst),
	.fp16_in_a(fp16_in_a[16:23]),
	.fp16_in_b(fp16_in_b[16:23]),
	.fp32_in_0(fp32_out_3[2]), // out_3 of block 2
	.fp32_in_3(fp32_out_1[2]), // out_1 of block 2
	.fp32_chain_in(fp32_chain[3]),
	.fp32_out_1(fp32_out_1[2]), // output of block 2
	.fp32_out_3(fp32_out_3[2]), // output of blocks 2 and 3
	.fp32_chain_out(fp32_chain[2])
);

four_dsp_block 
u_four_dsp_block_1 (
	.clk(clk),
	.rst(rst),
	.fp16_in_a(fp16_in_a[8:15]),
	.fp16_in_b(fp16_in_b[8:15]),
	.fp32_in_0(fp32_out_1[1]), // out_1, of block 1
	.fp32_in_3(fp32_out_3[0]), // out_3 of block 0
	.fp32_chain_in(fp32_chain[2]),
	.fp32_out_1(fp32_out_1[1]), // output of block 1
	.fp32_out_3(fp32_out_3[1]), // output of all blocks
	.fp32_chain_out(fp32_chain[1])
);

// LEFT
four_dsp_block #(
	.FIRST(1)
) u_four_dsp_block_0 (
	.clk(clk),
	.rst(rst),
	.fp16_in_a(fp16_in_a[0:7]),
	.fp16_in_b(fp16_in_b[0:7]),
	.fp32_in_0(), // None, terminal
	.fp32_in_3(fp32_out_1[0]), // out_1 of block 0
	.fp32_chain_in(fp32_chain[1]),
	.fp32_out_1(fp32_out_1[0]), // output of block 0
	.fp32_out_3(fp32_out_3[0]), // output of blocks 1 and 2
	.fp32_chain_out() // None, terminal
);

assign fp32_out = fp32_out_3[1];

endmodule

// Sum of Two mode:
// 	FP32 result is sum of FP32 chainin and FP16 products
//
// Vector Two mode:
// 	Fp32 result is sum of FP32 chainin and FP32 adder_a
// 	Fp32 chain out is sum of FP16 products
//
// Vector One mode:
// 	FP32 result is sum of FP32 chainin and FP16 products
// 	FP32 chainout is FP32 adder_a

// Block of 4 DSPs
module four_dsp_block #(
	parameter FIRST = 0, // Leftmost DSP block
	parameter LAST  = 0  // Rightmost DSP block
)(
	input logic clk,
	input logic rst,
	input logic [15:0] fp16_in_a [8],
	input logic [15:0] fp16_in_b [8],
	input logic [31:0] fp32_in_0,
	input logic [31:0] fp32_in_3,
	input logic [31:0] fp32_chain_in,
	output logic [31:0] fp32_out_1,
	output logic [31:0] fp32_out_3,
	output logic [31:0] fp32_chain_out
);
logic [31:0] fp32_chain [3]; // Internal DSP chain
logic [31:0] fp32_out_0, fp32_out_2; // Internal DSP outputs

/*
* DSPs 1 and 2 have constant input connections within the block of 4
* DSPs 0 and 2 outputs always go to the same DSPs within the block of 4
*
* DSP 3 is used to combine partial sums across blocks
* It takes the outputs from left as fp32_adder_a, and output from right as
* fp32_chainin
*
* Right side must feed output into DSP 0 fp32_adder_a so that the output is
* provided properly through chainin
*/

// DSP 3
generate
	if (LAST == 1) begin
		vector_two_no_chainin u_vector_two_no_chainin (
			.fp16_mult_top_a (fp16_in_a[6]),
			.fp16_mult_top_b (fp16_in_b[6]),
			.fp16_mult_bot_a (fp16_in_a[7]),
			.fp16_mult_bot_b (fp16_in_b[7]),
			.fp32_adder_a    (), // unneeded, no chainin
			.clr0            (rst),
			.clr1            (rst),
			.clk             (clk),
			.ena             (3'b111),
			.fp32_result     (fp32_out_3),
			.fp32_chainout   (fp32_chain[2])
		);
	end else begin
		vector_two u_vector_two_0 (
			.fp16_mult_top_a (fp16_in_a[6]),
			.fp16_mult_top_b (fp16_in_b[6]),
			.fp16_mult_bot_a (fp16_in_a[7]),
			.fp16_mult_bot_b (fp16_in_b[7]),
			.fp32_chainin    (fp32_chain_in),
			.fp32_adder_a    (fp32_in_3),
			.clr0            (rst),
			.clr1            (rst),
			.clk             (clk),
			.ena             (3'b111),
			.fp32_result     (fp32_out_3),
			.fp32_chainout   (fp32_chain[2])
		);
	end
endgenerate

// DSP 2
vector_one u_vector_one_0 (
	.fp16_mult_top_a (fp16_in_a[4]), 
	.fp16_mult_top_b (fp16_in_b[4]), 
	.fp16_mult_bot_a (fp16_in_a[5]), 
	.fp16_mult_bot_b (fp16_in_b[5]), 
	.fp32_chainin    (fp32_chain[2]),
	.fp32_adder_a    (fp32_out_2),
	.clr0            (rst),
	.clr1            (rst),
	.clk             (clk),
	.ena             (3'b111),
	.fp32_result     (fp32_out_2),
	.fp32_chainout   (fp32_chain[1])
);

// DSP 1
vector_two u_vector_two_0 (
	.fp16_mult_top_a (fp16_in_a[2]),
	.fp16_mult_top_b (fp16_in_b[2]),
	.fp16_mult_bot_a (fp16_in_a[3]),
	.fp16_mult_bot_b (fp16_in_b[3]),
	.fp32_chainin    (fp32_chain[1]),
	.fp32_adder_a    (fp32_out_0),
	.clr0            (rst),
	.clr1            (rst),
	.clk             (clk),
	.ena             (3'b111),
	.fp32_result     (fp32_out_1),
	.fp32_chainout   (fp32_chain[0])
);

// DSP 0
generate
	if (FIRST == 1) begin
		// First DSP, no FP32_IN, no chainout, use sum_of_two
		sum_of_two u_sum_of_two (
			.fp16_mult_top_a (fp16_in_a[0]), 
			.fp16_mult_top_b (fp16_in_b[0]), 
			.fp16_mult_bot_a (fp16_in_a[1]), 
			.fp16_mult_bot_b (fp16_in_b[1]), 
			.fp32_chainin    (fp32_chain[0]),
			.clr0            (rst),
			.clr1            (rst),
			.clk             (clk),
			.ena             (3'b111),
			.fp32_result     (fp32_out_0)
		);
	end else begin
		vector_one u_vector_one_0 (
			.fp16_mult_top_a (fp16_in_a[0]), 
			.fp16_mult_top_b (fp16_in_b[0]), 
			.fp16_mult_bot_a (fp16_in_a[1]), 
			.fp16_mult_bot_b (fp16_in_b[1]), 
			.fp32_chainin    (fp32_chain[0]),
			.fp32_adder_a    (fp32_in_0),
			.clr0            (rst),
			.clr1            (rst),
			.clk             (clk),
			.ena             (3'b111),
			.fp32_result     (fp32_out_0),
			.fp32_chainout   (fp32_chain_out)
		);
	end
endgenerate

endmodule
