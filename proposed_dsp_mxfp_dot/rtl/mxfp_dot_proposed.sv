import pkg_aitb::*;

// aitb_asic/rtl/mxfp_aitb/naive_mxfp_aitb_top.sv

module mxfp_dot_proposed #(
    parameter mxfp_mode_e MODE = MXFP4,
    parameter bit IS_SIM = 1,
	parameter E = 2,
    parameter M = 1,
	parameter E_SHARED = 8,
	parameter FP_BIAS = 1, // MX-FP BIAS
	parameter SH_BIAS = 127, // Shared EXP bias
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
    generate
		if (MODE == MXFP4) begin
			mxfp_dot_prop_mxfp4 #(
				.MODE(MODE),
				.IS_SIM(IS_SIM),
				.E(E),
				.M(M),
				.E_SHARED(E_SHARED),
				.FP_BIAS(FP_BIAS),
				.SH_BIAS(SH_BIAS),
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
	endgenerate
endmodule