// Build any length FP16 dot product
// For non-powers of two, builds several power-of-two dps and sums their
// results
// Note: There are edge cases where this is not the most DSP-efficient
// approach, and zero padding the vector may be favourable
// e.g. k=3 will be implemented with 3 DSPs, where it can be implemented with
// 2 for k=4, this would also result in a higher latency, so this edge case is handled, 
// for k=31 this is even worse, k=31 and k=32 would use the same
// number of DSPs (16), but this approach will use 5 extra DSPs (latency is
// the same regardless)
// In general, if you're close enough to a power of two, it may be benificial
// to zero pad
module direct_vector_dp #(
	parameter k = 32,
	parameter FP16_MODE = "extended" // bfloat16
)(
	input logic clk,
	input logic rst,
	input logic [15:0] fp16_in_a [k],
	input logic [15:0] fp16_in_b [k],
	output logic [31:0] fp32_out
);
// Find the largest power of 2 dp that can be built
localparam MAX_POW2    = 2 ** ($clog2(k + 1) - 1);
localparam LATENCY     = k > 2 ? (6 + ($clog2(k) - 2) * 3) : 6; // Expected total latency (fp32_add has a latency of 3, so this works for pow2 and non-pow2)
localparam MP2_LATENCY = MAX_POW2 > 2 ? (6 + ($clog2(MAX_POW2) - 2) * 3) : 6; // Expected latency for largest dp

generate
	if (k == MAX_POW2) begin
		// Terminate
		pow2_direct_vector_dp #(
			.k(k),
			.FP16_MODE(FP16_MODE)
		) u_pow2_direct_vector_dp_pow2 (
			.clk(clk),
			.rst(rst),
			.fp16_in_a(fp16_in_a),
			.fp16_in_b(fp16_in_b),
			.fp32_out(fp32_out)
		);
	end else if (k == 3) begin
		// Special case where latency calculation is inaccurate and
		// DSP usage is wasteful, zero pad instead
		logic [15:0] fp16_in_a_k4 [4];
		logic [15:0] fp16_in_b_k4 [4];

		for (genvar i = 0; i < 3; i++) begin
			assign fp16_in_a_k4[i] = fp16_in_a[i];
			assign fp16_in_b_k4[i] = fp16_in_b[i];
		end

		assign fp16_in_a_k4[3] = 16'b0;
		assign fp16_in_b_k4[3] = 16'b0;

		pow2_direct_vector_dp #(
			.k(4),
			.FP16_MODE(FP16_MODE)
		) u_pow2_direct_vector_dp_k4 (
			.clk(clk),
			.rst(rst),
			.fp16_in_a(fp16_in_a_k4),
			.fp16_in_b(fp16_in_b_k4),
			.fp32_out(fp32_out)
		);
	end else begin
		localparam REMAINDER   = k - MAX_POW2; // Remaining elements
		localparam REM_LATENCY = REMAINDER > 2 ? (6 + ($clog2(REMAINDER) - 2) * 3) : 6; // Expected latency for next call

		logic [31:0] max_fp32, rem_fp32, rem_fp32_q;

		// Largest dp for current k
		pow2_direct_vector_dp #(
			.k(MAX_POW2),
			.FP16_MODE(FP16_MODE)
		) u_pow2_direct_vector_dp_max (
			.clk(clk),
			.rst(rst),
			.fp16_in_a(fp16_in_a[0+:MAX_POW2]),
			.fp16_in_b(fp16_in_b[0+:MAX_POW2]),
			.fp32_out(max_fp32)
		);

		// Remainder
		direct_vector_dp #(
			.k(REMAINDER),
			.FP16_MODE(FP16_MODE)
		) u_direct_vector_dp_rem (
			.clk(clk),
			.rst(rst),
			.fp16_in_a(fp16_in_a[MAX_POW2+:REMAINDER]),
			.fp16_in_b(fp16_in_b[MAX_POW2+:REMAINDER]),
			.fp32_out(rem_fp32)
		);

		// Balance latency for remainder fp32
		pipeline #(
			.width(32),
			.depth(MP2_LATENCY - REM_LATENCY)
		) u_pipeline_rem_fp32 (
			.clk(clk),
			.rst(rst),
			.data(rem_fp32),
			.data_q(rem_fp32_q)
		);

		// Sum up fp32 outputs (3 cycle latency)
		fp32_add 
		u_fp32_add (
			.clk(clk),
			.clr0(rst),
			.clr1(rst),
			.ena(3'b111),
			.fp32_adder_a(max_fp32),
			.fp32_adder_b(rem_fp32_q),
			.fp32_result(fp32_out)
		);
	end
endgenerate

endmodule

// Chained FP16 DSPs creating a dot product
// K must be a power of two, in order to create non-power of two dot products,
// build smaller dps and sum together while balancing latencies
module pow2_direct_vector_dp #(
	parameter k = 32,
	parameter FP16_MODE = "extended" // bfloat16
)(
	input logic clk,
	input logic rst,
	input logic [15:0] fp16_in_a [k],
	input logic [15:0] fp16_in_b [k],
	output logic [31:0] fp32_out
);

localparam LATENCY = k > 2 ? (6 + ($clog2(k) - 2) * 3) : 6; // Expected latency

initial begin
	assert ((2 ** $clog2(k)) == k) else 
		$fatal ("ERROR: Direct vector dp K value must be a power of 2");
end

logic [31:0] fp32_chain [4];
logic [31:0] fp32_out_1 [4];
logic [31:0] fp32_out_3 [4];

generate
	if (k == 1) begin
		// Feed in 0 to bottom multiplier
		sum_of_two_no_chainin #(
			.FP16_MODE(FP16_MODE)
		) u_sum_of_two_no_chainin (
			.fp16_mult_top_a (fp16_in_a[0]), 
			.fp16_mult_top_b (fp16_in_b[0]), 
			.fp16_mult_bot_a (16'b0), 
			.fp16_mult_bot_b (16'b0), 
			.clr0            (rst),
			.clr1            (rst),
			.clk             (clk),
			.ena             (3'b111),
			.fp32_result     (fp32_out)
		);
	end else if (k == 2) begin
		sum_of_two_no_chainin #(
			.FP16_MODE(FP16_MODE)
		) u_sum_of_two_no_chainin (
			.fp16_mult_top_a (fp16_in_a[0]), 
			.fp16_mult_top_b (fp16_in_b[0]), 
			.fp16_mult_bot_a (fp16_in_a[1]), 
			.fp16_mult_bot_b (fp16_in_b[1]), 
			.clr0            (rst),
			.clr1            (rst),
			.clk             (clk),
			.ena             (3'b111),
			.fp32_result     (fp32_out)
		);
	end else if (k == 4) begin
		vector_two_no_chainin #(
			.FP16_MODE(FP16_MODE)
		) u_vector_two_no_chainin (
			.fp16_mult_top_a (fp16_in_a[2]),
			.fp16_mult_top_b (fp16_in_b[2]),
			.fp16_mult_bot_a (fp16_in_a[3]),
			.fp16_mult_bot_b (fp16_in_b[3]),
			.fp32_adder_a    (), // unneeded, no chainin
			.clr0            (rst),
			.clr1            (rst),
			.clk             (clk),
			.ena             (3'b111),
			.fp32_result     (),
			.fp32_chainout   (fp32_chain[0])
		);

		sum_of_two #(
			.FP16_MODE(FP16_MODE)
		) u_sum_of_two (
			.fp16_mult_top_a (fp16_in_a[0]), 
			.fp16_mult_top_b (fp16_in_b[0]), 
			.fp16_mult_bot_a (fp16_in_a[1]), 
			.fp16_mult_bot_b (fp16_in_b[1]), 
			.fp32_chainin    (fp32_chain[0]),
			.clr0            (rst),
			.clr1            (rst),
			.clk             (clk),
			.ena             (3'b111),
			.fp32_result     (fp32_out)
		);
	end else begin
		// Use recursive module
		recursive_direct_vector_dp #(
			.k(k),
			.FP16_MODE(FP16_MODE)
		) u_recursive_direct_vector_dp (
			.clk(clk),
			.rst(rst),
			.fp16_in_a(fp16_in_a),
			.fp16_in_b(fp16_in_b),
			.fp32_chain_in(),
			.fp32_in_0(),
			.fp32_in_3(),
			.fp32_chain_out(),
			.fp32_out_1(fp32_out),
			.fp32_out_3()
		);
	end
endgenerate

endmodule

// Module which implements any power of 2 (>4) FP16/BF16 dot products
// Uses K/2 DSPs
//
// DSP 3/out 3 is used to sum up adjacent blocks of 4
// DSP 0 fp32_in will go to DSP3 of the left block of 4 through chainin path
// DP3 in should be the output of the left block of 4, will be summed with
// right DSP0 chainout (which is right DSP0 fp32_in)
// So right side connects it's output to it's DSP0 fp32_in
// Left side connects it's output to it's DSP3 fp32_in
//
// Left side DSP3 <- feed in left side output
// Right side DSP0 <- feed in right side output
// Left side DSP3 output -> current block output
module recursive_direct_vector_dp #(
	parameter k     = 32,
	parameter FIRST = 1,
	parameter LAST  = 1,
	parameter FP16_MODE = "extended" // bfloat16
)(
	input  logic clk,
	input  logic rst,
	input  logic [15:0] fp16_in_a [k],
	input  logic [15:0] fp16_in_b [k],
	input  logic [31:0] fp32_chain_in,
	input  logic [31:0] fp32_in_0,
	input  logic [31:0] fp32_in_3,
	output logic [31:0] fp32_chain_out,
	output logic [31:0] fp32_out_1,
	output logic [31:0] fp32_out_3
);

generate
	if (k == 8) begin
		// Terminate
		four_dsp_block #(
			.FIRST(FIRST),
			.LAST(LAST),
			.FP16_MODE(FP16_MODE)
		) u_four_dsp_block_k16_left (
			.clk(clk),
			.rst(rst),
			.fp16_in_a(fp16_in_a[0:7]), // Bottom k elements
			.fp16_in_b(fp16_in_b[0:7]),
			.fp32_in_0(fp32_in_0), // this should be the output of the entire current right block
			.fp32_in_3(fp32_in_3), // out_1 of block 2
			.fp32_chain_in(fp32_chain_in),
			.fp32_out_1(fp32_out_1), // output of block 2
			.fp32_out_3(fp32_out_3), // output of blocks 2 and 3
			.fp32_chain_out(fp32_chain_out)
		);
	end else begin
		// Split into left and right blocks
		localparam k_shift = k >> 1;

		logic [31:0] fp32_out_1_left, fp32_out_1_right;
		logic [31:0] fp32_out_3_left, fp32_out_3_right;
		logic [31:0] fp32_chain_internal;

		recursive_direct_vector_dp #(
			.k(k_shift),
			.FIRST(0),
			.LAST(LAST),
			.FP16_MODE(FP16_MODE)
		) u_recursive_direct_vector_dp_right (
			.clk(clk),
			.rst(rst),
			.fp16_in_a(fp16_in_a[k_shift+:k_shift]),
			.fp16_in_b(fp16_in_b[k_shift+:k_shift]),
			.fp32_chain_in(fp32_chain_in),
			.fp32_in_0(fp32_out_1_right),
			.fp32_in_3(fp32_in_3),
			.fp32_chain_out(fp32_chain_internal),
			.fp32_out_1(fp32_out_1_right),
			.fp32_out_3(fp32_out_3_right)
		);

		recursive_direct_vector_dp #(
			.k(k_shift),
			.FIRST(FIRST),
			.LAST(0),
			.FP16_MODE(FP16_MODE)
		) u_recursive_direct_vector_dp_left (
			.clk(clk),
			.rst(rst),
			.fp16_in_a(fp16_in_a[0+:k_shift]),
			.fp16_in_b(fp16_in_b[0+:k_shift]),
			.fp32_chain_in(fp32_chain_internal),
			.fp32_in_0(fp32_in_0),
			.fp32_in_3(fp32_out_1_left),
			.fp32_chain_out(fp32_chain_out),
			.fp32_out_1(fp32_out_1_left),
			.fp32_out_3(fp32_out_3_left)
		);

		assign fp32_out_1 = fp32_out_3_left;  // Present block output
		assign fp32_out_3 = fp32_out_3_right; // Potential future block output
	end
endgenerate

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
	parameter LAST  = 0, // Rightmost DSP block
	parameter FP16_MODE = "extended" // bfloat16
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
		vector_two_no_chainin #(
			.FP16_MODE(FP16_MODE)
		) u_vector_two_no_chainin (
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
		vector_two #(
			.FP16_MODE(FP16_MODE)
		) u_vector_two_0 (
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
vector_one #(
	.FP16_MODE(FP16_MODE)
) u_vector_one_0 (
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
vector_two #(
	.FP16_MODE(FP16_MODE)
) u_vector_two_0 (
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
		sum_of_two #(
			.FP16_MODE(FP16_MODE)
		) u_sum_of_two (
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
		vector_one #(
			.FP16_MODE(FP16_MODE)
		) u_vector_one_0 (
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
