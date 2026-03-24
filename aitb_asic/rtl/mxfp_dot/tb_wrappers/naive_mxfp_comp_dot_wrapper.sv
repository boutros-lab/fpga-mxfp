/*
* TB Wrapper for Naive MXFP Dot Product circuit
* Only supports: MXFP8 K=8, MXFP6 K=12, MXFP4 K=16
*/
import pkg_aitb::*;

module naive_mxfp_comp_dot_wrapper #(
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
assign o_valid = i_valid;

localparam point_position = exp_width == 0 ? 0 // Fixed point
					   : ((1 << (exp_width - 1)) - 2 + man_width) * 2;

// Formula: UNSIGNED_WIDTH + FP32_BIAS - point_position <- correction without shared exponents
//          -2 * FP32_BIAS <- correction for shared exponents
localparam signed [7:0] exponent_correction = (FIXED_RESULT_WIDTH - 1) + FP32_BIAS - point_position - 1 - (FP32_BIAS * 2);

mxfp_mode_e mxfp_mode;

assign mxfp_mode = exp_width == 2 ? (man_width == 1 ? MXFP4 : MXFP6_23) 
				  : exp_width == 3 ? MXFP6_32
				  : exp_width == 4 ? MXFP8_43
				  : exp_width == 0 ? FIXED
				  : MXFP8_52;

// Flatten inputs
logic [FLAT_DATA_WIDTH-1:0] flat_a, flat_b;

genvar i;

generate
	if (exp_width != 0) begin
		for (i = 0; i < FLAT_DATA_WIDTH/bit_width; i++) begin
			assign flat_a[i*bit_width+:bit_width] = i_vec_a[i];
			assign flat_b[i*bit_width+:bit_width] = i_vec_b[i];
		end
	end else begin
		for (i = 0; i < FLAT_DATA_WIDTH/bit_width; i++) begin
			assign flat_a[i*bit_width+:bit_width] = i_vec_a[i][bit_width-1] ? -i_vec_a[i][bit_width-2:0] 
											: i_vec_a[i][bit_width-2:0];
			assign flat_b[i*bit_width+:bit_width] = i_vec_b[i][bit_width-1] ? -i_vec_b[i][bit_width-2:0] 
											: i_vec_b[i][bit_width-2:0];
		end
	end
endgenerate

// Break into components
logic                     mxfp8_sign_a [MXFP8_ELEMENTS];
logic                     mxfp8_sign_b [MXFP8_ELEMENTS];
logic [MXFP8_MAX_EXP-1:0] mxfp8_exp_a  [MXFP8_ELEMENTS];
logic [MXFP8_MAX_EXP-1:0] mxfp8_exp_b  [MXFP8_ELEMENTS];
logic [MXFP8_MAX_MAN:0]   mxfp8_sig_a  [MXFP8_ELEMENTS];
logic [MXFP8_MAX_MAN:0]   mxfp8_sig_b  [MXFP8_ELEMENTS];

logic                     mxfp6_sign_a [MXFP6_ELEMENTS];
logic                     mxfp6_sign_b [MXFP6_ELEMENTS];
logic [MXFP6_MAX_EXP-1:0] mxfp6_exp_a  [MXFP6_ELEMENTS];
logic [MXFP6_MAX_EXP-1:0] mxfp6_exp_b  [MXFP6_ELEMENTS];
logic [MXFP6_MAX_MAN:0]   mxfp6_sig_a  [MXFP6_ELEMENTS];
logic [MXFP6_MAX_MAN:0]   mxfp6_sig_b  [MXFP6_ELEMENTS];

logic                     mxfp4_sign_a [MXFP4_ELEMENTS];
logic                     mxfp4_sign_b [MXFP4_ELEMENTS];
logic [MXFP4_MAX_EXP-1:0] mxfp4_exp_a  [MXFP4_ELEMENTS];
logic [MXFP4_MAX_EXP-1:0] mxfp4_exp_b  [MXFP4_ELEMENTS];
logic [MXFP4_MAX_MAN:0]   mxfp4_sig_a  [MXFP4_ELEMENTS];
logic [MXFP4_MAX_MAN:0]   mxfp4_sig_b  [MXFP4_ELEMENTS];

input_preparation_mxfp_comp 
u_input_preparation_mxfp_a (
	.i_mxfp_mode(mxfp_mode),
	.i_flat(flat_a),

	.o_fp8_sign(mxfp8_sign_a),
	.o_fp8_exp(mxfp8_exp_a),
	.o_fp8_sig(mxfp8_sig_a),

	.o_fp6_sign(mxfp6_sign_a),
	.o_fp6_exp(mxfp6_exp_a),
	.o_fp6_sig(mxfp6_sig_a),

	.o_fp4_sign(mxfp4_sign_a),
	.o_fp4_exp(mxfp4_exp_a),
	.o_fp4_sig(mxfp4_sig_a)
);

input_preparation_mxfp_comp 
u_input_preparation_mxfp_b (
	.i_mxfp_mode(mxfp_mode),
	.i_flat(flat_b),

	.o_fp8_sign(mxfp8_sign_b),
	.o_fp8_exp(mxfp8_exp_b),
	.o_fp8_sig(mxfp8_sig_b),

	.o_fp6_sign(mxfp6_sign_b),
	.o_fp6_exp(mxfp6_exp_b),
	.o_fp6_sig(mxfp6_sig_b),

	.o_fp4_sign(mxfp4_sign_b),
	.o_fp4_exp(mxfp4_exp_b),
	.o_fp4_sig(mxfp4_sig_b)
);

// Only works with MXFP8 K=8, MXFP6 K=12, MXFP4 K=16, INT8 K=10
naive_mxfp_comp_dot #(
	.PACKED_REDUCTION(0)
) u_naive_mxfp_comp_dot (
	.i_mxfp_mode(mxfp_mode),
	.i_exponent_correction(exponent_correction),

	.i_mxfp8_sign_a(mxfp8_sign_a),
	.i_mxfp8_sign_b(mxfp8_sign_b),
	.i_mxfp8_exp_a(mxfp8_exp_a),
	.i_mxfp8_exp_b(mxfp8_exp_b),
	.i_mxfp8_sig_a(mxfp8_sig_a),
	.i_mxfp8_sig_b(mxfp8_sig_b),

	.i_mxfp6_sign_a(mxfp6_sign_a),
	.i_mxfp6_sign_b(mxfp6_sign_b),
	.i_mxfp6_exp_a(mxfp6_exp_a),
	.i_mxfp6_exp_b(mxfp6_exp_b),
	.i_mxfp6_sig_a(mxfp6_sig_a),
	.i_mxfp6_sig_b(mxfp6_sig_b),

	.i_mxfp4_sign_a(mxfp4_sign_a),
	.i_mxfp4_sign_b(mxfp4_sign_b),
	.i_mxfp4_exp_a(mxfp4_exp_a),
	.i_mxfp4_exp_b(mxfp4_exp_b),
	.i_mxfp4_sig_a(mxfp4_sig_a),
	.i_mxfp4_sig_b(mxfp4_sig_b),

	.i_shared_exp_a(i_shared_exp_a),
	.i_shared_exp_b(i_shared_exp_b),

	.o_fp32_result(o_result)
);

endmodule
