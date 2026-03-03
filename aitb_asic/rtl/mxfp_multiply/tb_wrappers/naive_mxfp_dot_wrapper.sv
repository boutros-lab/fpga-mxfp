/*
* TB Wrapper for Naive MXFP Dot Product circuit
* Only supports: MXFP8 K=8, MXFP6 K=12, MXFP4 K=16
*/

module naive_mxfp_dot_wrapper #(
	parameter exp_width = 5,
	parameter man_width = 2,
	parameter k = 8,

	parameter bit_width = 1 + exp_width + man_width
)(
	input  logic clk,
	input  logic rst,
	input  logic i_valid,
	output logic o_valid,
        input  logic [bit_width-1:0] i_vec_a [k],
        input  logic [bit_width-1:0] i_vec_b [k],
	input  logic [7:0] i_shared_exp_a,
	input  logic [7:0] i_shared_exp_b,
        output logic [31:0] o_result
);
localparam mxfp_mode = exp_width == 2 ? (man_width == 1 ? 0 : 1) 
				      : exp_width == 3 ? 2
				      : exp_width == 4 ? 3
				      : 4;

assign o_valid = i_valid;

logic [7:0] mxfp8_a [8];
logic [7:0] mxfp8_b [8];
logic [5:0] mxfp6_a [4];
logic [5:0] mxfp6_b [4];
logic [3:0] mxfp4_a [4];
logic [3:0] mxfp4_b [4];

genvar i;

// Prep TB inputs
generate
	for (i = 0; i < 8; i++) begin
		if (bit_width < 8) begin
			assign mxfp8_a[i] = i_vec_a[i];
			assign mxfp8_b[i] = i_vec_b[i];
		end else begin
			assign mxfp8_a[i] = {{(bit_width-8), 1'b0}, i_vec_a[i]};
			assign mxfp8_b[i] = {{(bit_width-8), 1'b0}, i_vec_b[i]};
		end
	end

	for (i = 0; i < 4; i++) begin
		if (k >= 12) begin
			if (bit_width < 6) begin
				assign mxfp6_a[i] = i_vec_a[i+8];
				assign mxfp6_b[i] = i_vec_b[i+8];
			end else begin
				assign mxfp6_a[i] = {{(bit_width-6), 1'b0}, i_vec_a[i]};
				assign mxfp6_b[i] = {{(bit_width-6), 1'b0}, i_vec_b[i]};
			end
		end else begin
			assign mxfp6_a[i] = 6'b0;
			assign mxfp6_b[i] = 6'b0;
		end
	end

	for (i = 0; i < 4; i++) begin
		if (k >= 16) begin
			assign mxfp4_a[i] = i_vec_a[i+12];
			assign mxfp4_b[i] = i_vec_b[i+12];
		end else begin
			assign mxfp4_a[i] = 6'b0;
			assign mxfp4_b[i] = 6'b0;
		end
	end
endgenerate

// Only works with MXFP8 K=8, MXFP6 K=12, MXFP4 K=16
naive_mxfp_dot 
u_naive_mxfp_dot (
	.sign_shift(exp_width + man_width),
	.exp_bits(exp_width),
	.man_bits(man_width),
	.mxfp_mode(exp_width), // 000: E2M1, 001: E2M3, 010: E3M2, 011: E4M3, 100: E5M2

	.mxfp8_a(mxfp8_a),
	.mxfp8_b(mxfp8_b),
	.mxfp6_a(mxfp6_a),
	.mxfp6_b(mxfp6_b),
	.mxfp4_a(mxfp4_a),
	.mxfp4_b(mxfp4_b),

	.o_fp32_result(o_result)
);

endmodule
