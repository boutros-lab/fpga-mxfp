// //////////////////////////////////////////////////////////////////////////////////////
// Module: mxfp_dot_proposed
//
// Description:
// Top level dot product wrapper. It instantiates different wrappers depending on the MXFP format chosen.
//
// Parameters:
//  Default parameter values are the correct values.
// - MODE_INT: integer parameter to choose a MXFP format for DSP configuration.
//   See `systolic_array/syn/setup_24_2_mxfp_dot_prop.tcl` for correspondance between MXFP format and MODE_INT value.
// - IS_SIM: passed to fp_aitb_proposed by the mxfp_dot_prop format specific modules.
// - IS_DOT4: must be set to 1 for E5M2 dot products. Set to 0 otherwise.
// - E: exponent width of selected MXFP format.
// - M: mantissa width of selected MXFP format.
// - E_SHARED: shared exponent widht of MXFP format.
// - DOT_LEN: length of dot product being implemented.
// //////////////////////////////////////////////////////////////////////////////////////

import pkg_aitb::*;

module mxfp_dot_proposed #(
//    parameter mxfp_mode_e MODE = MXFP4,
    parameter MODE_INT = 0,
    parameter bit IS_SIM = 1,
	parameter bit IS_DOT4 = 1,
	parameter E = 2,
    parameter M = 1,
	parameter E_SHARED = 8,
	parameter DOT_LEN = 32
) (
    input logic clk,
    input logic rst,
    input logic load_en_i,
    input logic valid_en_i,
    input logic [M+E:0] mx_data_in_i [0:DOT_LEN-1],
	input logic [E_SHARED-1:0] shared_exponent_i,
	output logic [31:0] fp32_dot_out_col1_o,
	output logic [31:0] fp32_dot_out_col2_o,
	output logic valid_out_o,
	output logic [3:0] fp32_flags_col1_o,
	output logic [3:0] fp32_flags_col2_o
);
	// Conversion from int to enum type.
	localparam mxfp_mode_e MODE = mxfp_mode_e'(MODE_INT);
    generate
		if (MODE == MXFP4) begin
			mxfp_dot_prop_mxfp4 #(
				.MODE(MODE),
				.IS_SIM(IS_SIM),
				.E(E),
				.M(M),
				.E_SHARED(E_SHARED),
				.DOT_LEN(DOT_LEN)
			) dot_inst(
				.clk(clk),
				.rst(rst),
				.load_en_i(load_en_i),
				.valid_en_i(valid_en_i),
				.mx_data_in_i(mx_data_in_i),
				.shared_exponent_i(shared_exponent_i),
				.fp32_dot_out_col1_o(fp32_dot_out_col1_o),
				.fp32_dot_out_col2_o(fp32_dot_out_col2_o),
				.valid_out_o(valid_out_o),
				.fp32_flags_col1_o(fp32_flags_col1_o),
				.fp32_flags_col2_o(fp32_flags_col2_o)
			);
		end
		else if ((MODE == MXFP6_23) || (MODE == MXFP6_32)) begin
			mxfp_dot_prop_mxfp6 #(
				.MODE(MODE),
				.IS_SIM(IS_SIM),
				.E(E),
				.M(M),
				.E_SHARED(E_SHARED),
				.DOT_LEN(DOT_LEN)
			) dot_inst (
				.clk(clk),
				.rst(rst),
				.load_en_i(load_en_i),
				.valid_en_i(valid_en_i),
				.mx_data_in_i(mx_data_in_i),
				.shared_exponent_i(shared_exponent_i),
				.fp32_dot_out_col1_o(fp32_dot_out_col1_o),
				.fp32_dot_out_col2_o(fp32_dot_out_col2_o),
				.valid_out_o(valid_out_o),
				.fp32_flags_col1_o(fp32_flags_col1_o),
				.fp32_flags_col2_o(fp32_flags_col2_o)
			);
		end
		// Proposed DSP block with E5M2 support implements an E5M2 dot-4 per DSP.
		// IS_DOT4 must be set to 1 for "E5M2 mode".
		else if ((MODE == MXFP8_43) || (MODE == MXFP8_52)) begin
			if (!IS_DOT4) begin
				// DOT8
				mxfp_dot_prop_mxfp8 #(
					.MODE(MODE),
					.IS_SIM(IS_SIM),
					.E(E),
					.M(M),
					.E_SHARED(E_SHARED),
					.DOT_LEN(DOT_LEN)
				) dot_inst(
					.clk(clk),
					.rst(rst),
					.load_en_i(load_en_i),
					.valid_en_i(valid_en_i),
					.mx_data_in_i(mx_data_in_i),
					.shared_exponent_i(shared_exponent_i),
					.fp32_dot_out_col1_o(fp32_dot_out_col1_o),
					.fp32_dot_out_col2_o(fp32_dot_out_col2_o),
					.valid_out_o(valid_out_o),
					.fp32_flags_col1_o(fp32_flags_col1_o),
					.fp32_flags_col2_o(fp32_flags_col2_o)
				);
			end
			// IS_DOT4
			else begin
				mxfp_dot_prop_mxfp8_dot4aitb #(
					.MODE(MODE),
					.IS_SIM(IS_SIM),
					.E(E),
					.M(M),
					.E_SHARED(E_SHARED),
					.DOT_LEN(DOT_LEN)
				) dot_inst(
					.clk(clk),
					.rst(rst),
					.load_en_i(load_en_i),
					.valid_en_i(valid_en_i),
					.mx_data_in_i(mx_data_in_i),
					.shared_exponent_i(shared_exponent_i),
					.fp32_dot_out_col1_o(fp32_dot_out_col1_o),
					.fp32_dot_out_col2_o(fp32_dot_out_col2_o),
					.valid_out_o(valid_out_o),
					.fp32_flags_col1_o(fp32_flags_col1_o),
					.fp32_flags_col2_o(fp32_flags_col2_o)
				);
			end
		end
	endgenerate
endmodule
