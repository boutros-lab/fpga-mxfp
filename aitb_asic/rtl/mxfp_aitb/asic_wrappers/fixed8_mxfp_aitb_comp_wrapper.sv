/*
* ASIC wrapper for packed MXFP AITB
* Uses packed reduction
*/

import pkg_aitb::*;

module fixed8_mxfp_aitb_comp_wrapper (
	input logic clk,
	input logic rst,
	input logic acc_en,
	input logic zero_en,
	input logic load_bb_one,
	input logic load_bb_two,
	input logic load_buf_sel,

	input mxfp_mode_e i_mxfp_mode,

	input logic [FLAT_DATA_WIDTH-1:0] data_in,
	input logic [7:0] shared_exponent,
	input logic [31:0] fp32_cascade_in_col1,
	input logic [31:0] fp32_cascade_in_col2,

	output logic [31:0] fp32_dot_out_col1,
	output logic [31:0] fp32_dot_out_col2,
	output logic [31:0] fp32_cascade_out_col1,
	output logic [31:0] fp32_cascade_out_col2,
	output logic [3:0]  fp32_flags_col1,
	output logic [3:0]  fp32_flags_col2

);

naive_mxfp_aitb_comp_top #(
	.FIXED_INPUTS(8),
	.PACKED_REDUCTION(0)
) u_fixed8_mxfp_aitb_comp_top (
	.clk(clk),
	.rst(rst),
	.acc_en(acc_en),
	.zero_en(zero_en),
	.load_bb_one(load_bb_one),
	.load_bb_two(load_bb_two),
	.load_buf_sel(load_buf_sel),
	.i_mxfp_mode(i_mxfp_mode),
	.data_in(data_in),
	.shared_exponent(shared_exponent),
	.fp32_cascade_in_col1(fp32_cascade_in_col1),
	.fp32_cascade_in_col2(fp32_cascade_in_col2),
	.fp32_dot_out_col1(fp32_dot_out_col1),
	.fp32_dot_out_col2(fp32_dot_out_col1),
	.fp32_cascade_out_col1(fp32_cascade_out_col2),
	.fp32_cascade_out_col2(fp32_cascade_out_col2),
	.fp32_flags_col1(fp32_flags_col1),
	.fp32_flags_col2(fp32_flags_col2)
);

endmodule 
