/*
* Fixed Input MXFP dot product implementation
*
* 8 * 10
* 2 * 8
* 1 * 7
* 5 * 5
*
* Supports: E2M1 K16, E2M3 K11, K3M2 K8, E0M7 K10
* Supports E4M3 K5-8 as FP format input
*
* Expects fixed point two's complement input
*/

import pkg_aitb::*;

module fixed_input_e4m3_mxfp_dot #(
	parameter E3M2_DOT_LENGTH  =  8,
	parameter FIXED_DOT_LENGTH = 10,
	parameter E2M3_DOT_LENGTH  = 11,
	parameter E2M1_DOT_LENGTH  = 16,

	parameter E4M3_DOT_LENGTH  = 6,

	parameter E3M2_OPS  = E3M2_DOT_LENGTH,
	parameter FIXED_OPS = FIXED_DOT_LENGTH - E3M2_DOT_LENGTH,
	parameter E2M3_OPS  = E2M3_DOT_LENGTH - FIXED_DOT_LENGTH,
	parameter E2M1_OPS  = E2M1_DOT_LENGTH - E2M3_DOT_LENGTH,

	parameter E4M3_OPS = E4M3_DOT_LENGTH,

	parameter E3M2_INPUT_WIDTH  = 10, // 1 + (M + 1) + (2^E - 2)
	parameter FIXED_INPUT_WIDTH =  8,
	parameter E2M3_INPUT_WIDTH  =  7,
	parameter E2M1_INPUT_WIDTH  =  5,

	parameter E4M3_PROD_WIDTH   = 37,
	parameter E4M3_RESULT_WIDTH = E4M3_PROD_WIDTH + $clog2(E4M3_OPS),

	parameter OUTPUT_WIDTH = E4M3_RESULT_WIDTH
)(
	// Configuration
	input mxfp_mode_e i_mxfp_mode,

	// Data
	input logic signed [E3M2_INPUT_WIDTH-1:0] i_e3m2_a [E3M2_OPS],
	input logic signed [E3M2_INPUT_WIDTH-1:0] i_e3m2_b [E3M2_OPS],

	input logic signed [FIXED_INPUT_WIDTH-1:0] i_fixed_a [FIXED_OPS],
	input logic signed [FIXED_INPUT_WIDTH-1:0] i_fixed_b [FIXED_OPS],

	input logic signed [E2M3_INPUT_WIDTH-1:0] i_e2m3_a [E2M3_OPS],
	input logic signed [E2M3_INPUT_WIDTH-1:0] i_e2m3_b [E2M3_OPS],

	input logic signed [E2M1_INPUT_WIDTH-1:0] i_e2m1_a [E2M1_OPS],
	input logic signed [E2M1_INPUT_WIDTH-1:0] i_e2m1_b [E2M1_OPS],

	output logic signed [OUTPUT_WIDTH-1:0] o_fixed_result
);
// Output widths of the individual dots
localparam E3M2_RESULT_WIDTH  = (2 * E3M2_INPUT_WIDTH) + $clog2(E3M2_OPS);
localparam FIXED_RESULT_WIDTH = (2 * FIXED_INPUT_WIDTH) + $clog2(FIXED_OPS);
localparam E2M3_RESULT_WIDTH  = (2 * E2M3_INPUT_WIDTH) + $clog2(E2M3_OPS);
localparam E2M1_RESULT_WIDTH  = (2 * E2M1_INPUT_WIDTH) + $clog2(E2M1_OPS);

localparam E2M1_PROD_WIDTH  = 2 * E2M1_INPUT_WIDTH;
localparam FIXED_PROD_WIDTH = 2 * FIXED_INPUT_WIDTH;

logic e4m3_mode;

assign e4m3_mode = i_mxfp_mode == MXFP8_43;

// Outputs of individual dots
logic signed [E3M2_RESULT_WIDTH-1:0]  e3m2_dot_result;
logic signed [FIXED_RESULT_WIDTH-1:0] fixed_dot_result;
logic signed [E2M3_RESULT_WIDTH-1:0]  e2m3_dot_result;
logic signed [E2M1_RESULT_WIDTH-1:0]  e2m1_dot_result;
logic signed [E4M3_RESULT_WIDTH-1:0]  e4m3_dot_result;

logic signed [E3M2_RESULT_WIDTH-1:0] fixed_input_sum;

// E4M3 and E2M1 Products
logic signed [FIXED_PROD_WIDTH-1:0] fixed_prod [FIXED_OPS];
logic signed [E2M1_PROD_WIDTH-1:0]  e2m1_prod  [E2M1_OPS];
logic signed [E4M3_PROD_WIDTH-1:0]  e4m3_prod  [E4M3_OPS];

// Instantiate dot modules for the individual input formats
dot #(
	.INPUT_WIDTH(E3M2_INPUT_WIDTH),
	.DOT_LENGTH(E3M2_OPS)
) u_e3m2_dot (
	.data_in(i_e3m2_a),
	.w_reg(i_e3m2_b),
	.dot_out(e3m2_dot_result)
);

// For E2M1, E2M3, FIXED, Share multipliers with FP MULT E4M3
// Expect E4M3 to be encoded on i_e3m2_* inputs
generate
	if (E4M3_OPS > (E2M1_OPS + E2M3_OPS)) begin
		for (genvar i = 0; i < FIXED_OPS; i++) begin : fixed_mults
			mxfp_multiply_dual #(
				.FIXED_WIDTH(FIXED_INPUT_WIDTH)
			) u_mxfp_multiply_dual_fixed (
				.i_mxfp_mode(e4m3_mode),
				.i_mxfp_a(i_e3m2_a[i+E2M1_OPS+E2M3_OPS][7:0]),
				.i_mxfp_b(i_e3m2_b[i+E2M1_OPS+E2M3_OPS][7:0]),
				.i_fixed_a(i_fixed_a[i]),
				.i_fixed_b(i_fixed_b[i]),
				.o_prod(fixed_prod[i]),
				.o_prod_shifted(e4m3_prod[i+E2M1_OPS+E2M3_OPS])
			);
		end

		always_comb begin
			fixed_dot_result = 'b0;

			for(int i = 0; i < FIXED_OPS; i++) begin
				fixed_dot_result += fixed_prod[i];
			end
		end
	end else begin
		dot #(
			.INPUT_WIDTH(FIXED_INPUT_WIDTH),
			.DOT_LENGTH(FIXED_OPS)
		) u_fixed_dot (
			.data_in(i_fixed_a),
			.w_reg(i_fixed_b),
			.dot_out(fixed_dot_result)
		);
	end

	if (E4M3_OPS > E2M1_OPS) begin
		mxfp_multiply_dual #(
			.FIXED_WIDTH(E2M3_INPUT_WIDTH)
		) u_mxfp_multiply_dual_e2m3 (
			.i_mxfp_mode(e4m3_mode),
			.i_mxfp_a(i_e3m2_a[E2M1_OPS][7:0]),
			.i_mxfp_b(i_e3m2_b[E2M1_OPS][7:0]),
			.i_fixed_a(i_e2m3_a[0]),
			.i_fixed_b(i_e2m3_b[0]),
			.o_prod(e2m3_dot_result),
			.o_prod_shifted(e4m3_prod[E2M1_OPS])
		);
	end else begin
		dot #(
			.INPUT_WIDTH(E2M3_INPUT_WIDTH),
			.DOT_LENGTH(E2M3_OPS)
		) u_e2m3_dot (
			.data_in(i_e2m3_a),
			.w_reg(i_e2m3_b),
			.dot_out(e2m3_dot_result)
		);
	end

	for (genvar i = 0; i < E2M1_OPS; i++) begin : e2m1_mults
		mxfp_multiply_dual #(
			.FIXED_WIDTH(E2M1_INPUT_WIDTH)
		) u_mxfp_multiply_dual_e2m1 (
			.i_mxfp_mode(e4m3_mode),
			.i_mxfp_a(i_e3m2_a[i][7:0]),
			.i_mxfp_b(i_e3m2_b[i][7:0]),
			.i_fixed_a(i_e2m1_a[i]),
			.i_fixed_b(i_e2m1_b[i]),
			.o_prod(e2m1_prod[i]),
			.o_prod_shifted(e4m3_prod[i])
		);
	end
endgenerate

always_comb begin
	e2m1_dot_result = 'b0;
	e4m3_dot_result = 'b0;

	for(int i = 0; i < E2M1_OPS; i++) begin
		e2m1_dot_result += e2m1_prod[i];
	end

	for(int i = 0; i < E4M3_OPS; i++) begin
		e4m3_dot_result += e4m3_prod[i];
	end
end

// Sum up all the individual dots
assign fixed_input_sum = e3m2_dot_result + fixed_dot_result 
		       + e2m3_dot_result + e2m1_dot_result;

assign o_fixed_result = e4m3_mode ? e4m3_dot_result
				  : fixed_input_sum;

endmodule
