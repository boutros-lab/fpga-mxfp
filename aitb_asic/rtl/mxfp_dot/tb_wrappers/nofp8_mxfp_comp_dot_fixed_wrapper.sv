/*
* TB Wrapper for NoFP8 MXFP Dot Product circuit
* Only supports: Fixed K=10, MXFP6 K=12, MXFP4 K=16
*/
import pkg_aitb::*;

module nofp8_mxfp_comp_dot_fixed_wrapper #(
	parameter exp_width = 5,
	parameter man_width = 2,
	parameter k = 8,
	
	parameter bit_width = 1 + exp_width + man_width,
	parameter prd_width = 2 * ((1<<exp_width) + man_width),
	parameter out_width = prd_width + $clog2(k)
)(
	input  logic clk,
	input  logic rst,
	input  logic i_valid,
	output logic o_valid,
	input  logic [bit_width-1:0] i_vec_a [k],
	input  logic [bit_width-1:0] i_vec_b [k],
	output logic [out_width-1:0] o_result
);
localparam MXFP6_ELEMENTS     = 12;
localparam FIXED_RESULT_WIDTH = MXFP6_PRODUCT_WIDTH + $clog2(MXFP6_ELEMENTS);

assign o_valid = i_valid;

logic [FIXED_RESULT_WIDTH-1:0] fixed_result;

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

nofp8_input_preparation_mxfp_comp 
u_nofp8_input_preparation_mxfp_a (
	.i_mxfp_mode(mxfp_mode),
	.i_flat(flat_a),

	.o_fp6_sign(mxfp6_sign_a),
	.o_fp6_exp(mxfp6_exp_a),
	.o_fp6_sig(mxfp6_sig_a),

	.o_fp4_sign(mxfp4_sign_a),
	.o_fp4_exp(mxfp4_exp_a),
	.o_fp4_sig(mxfp4_sig_a)
);

nofp8_input_preparation_mxfp_comp 
u_nofp8_input_preparation_mxfp_b (
	.i_mxfp_mode(mxfp_mode),
	.i_flat(flat_b),

	.o_fp6_sign(mxfp6_sign_b),
	.o_fp6_exp(mxfp6_exp_b),
	.o_fp6_sig(mxfp6_sig_b),

	.o_fp4_sign(mxfp4_sign_b),
	.o_fp4_exp(mxfp4_exp_b),
	.o_fp4_sig(mxfp4_sig_b)
);

// Only works with MXFP8 K=8, MXFP6 K=12, MXFP4 K=16, INT8 K=10
nofp8_mxfp_comp_dot_fixed #(
	.PACKED_REDUCTION(0)
) u_nofp8_mxfp_comp_dot_fixed (
	.i_mxfp_mode(mxfp_mode),

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

	.o_fixed_result(fixed_result)
);

generate
	if (out_width > FIXED_RESULT_WIDTH) begin
		assign o_result = {{(out_width - FIXED_RESULT_WIDTH){fixed_result[FIXED_RESULT_WIDTH-1]}}, fixed_result};
	end else begin
		assign o_result = fixed_result;
	end
endgenerate

endmodule
