/*
* TB Wrapper for Fixed input MXFP Dot Product circuit
* Supports: E2M1 K16, E2M3 K11, K3M2 K8, E0M7 K10
*/
import pkg_aitb::*;

module fixed_input_mxfp_dot_wrapper #(
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
localparam mxfp_fixed_width = man_width + (1 << exp_width);

localparam FIXED_RESULT_WIDTH = 20 + $clog2(8);

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

function automatic logic signed [mxfp_fixed_width-1:0] fix2float (
	input logic [bit_width-1:0] float
);
	logic        [mxfp_fixed_width-2:0] u_fixed;
	logic signed [mxfp_fixed_width-1:0] fixed;

	localparam exp_width_n0 = exp_width + (exp_width == 0); // Avoid error

	u_fixed = float == 'b0 ? 'b0 : (exp_width != 0 ? {|float[man_width+:exp_width_n0], float[0+:man_width]} << (float[man_width+:exp_width_n0] - |float[man_width+:exp_width_n0])
						       : float[0+:man_width]);
	
	fixed = float[man_width+exp_width] ? -u_fixed
					   : u_fixed;
	
	return fixed;
endfunction

genvar i;

generate
	for (i = 0; i < k; i++) begin
		assign flat_a[i*mxfp_fixed_width+:mxfp_fixed_width] = fix2float(i_vec_a[i]);
		assign flat_b[i*mxfp_fixed_width+:mxfp_fixed_width] = fix2float(i_vec_b[i]);
	end
endgenerate

// Break into elements
logic signed [9:0] e3m2_a  [8];
logic signed [9:0] e3m2_b  [8];
logic signed [7:0] fixed_a [2];
logic signed [7:0] fixed_b [2];
logic signed [6:0] e2m3_a  [1];
logic signed [6:0] e2m3_b  [1];
logic signed [4:0] e2m1_a  [5];
logic signed [4:0] e2m1_b  [5];

fixed_mxfp_input_preparation
u_fixed_mxfp_input_preparation_a (
	.i_mxfp_mode(mxfp_mode),
	.i_flat(flat_a),

	.o_e3m2(e3m2_a),
	.o_fixed(fixed_a),
	.o_e2m3(e2m3_a),
	.o_e2m1(e2m1_a)
);

fixed_mxfp_input_preparation
u_fixed_mxfp_input_preparation_b (
	.i_mxfp_mode(mxfp_mode),
	.i_flat(flat_b),

	.o_e3m2(e3m2_b),
	.o_fixed(fixed_b),
	.o_e2m3(e2m3_b),
	.o_e2m1(e2m1_b)
);

// Only works with E3M2 K=8, E2M3 K=11, MXFP4 K=16, INT8 K=10
fixed_input_mxfp_dot 
u_fixed_input_mxfp_dot (
	.i_mxfp_mode(mxfp_mode),

	.i_e3m2_a(e3m2_a),
	.i_e3m2_b(e3m2_b),

	.i_fixed_a(fixed_a),
	.i_fixed_b(fixed_b),

	.i_e2m3_a(e2m3_a),
	.i_e2m3_b(e2m3_b),

	.i_e2m1_a(e2m1_a),
	.i_e2m1_b(e2m1_b),

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
