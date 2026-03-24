import pkg_aitb::*;

// aitb_asic/rtl/mxfp_aitb/naive_mxfp_aitb_top.sv

module mxfp_dot_proposed #(
    parameter mxfp_mode_e MODE = MXFP4,
    parameter bit IS_SIM = 1,
    parameter M = 3,
	parameter E = 2,
	parameter E_SHARED = 8,
	parameter FP_BIAS = 1, // MX-FP BIAS
	parameter SH_BIAS = 127, // Shared EXP bias
	parameter PIPE = 1,
	parameter DOT_LEN = 32
) (
    input logic clk,
    input logic rst,
    input logic load_en,
    input logic valid_en,
    input logic [M+E:0] mx_data_in [0:DOT_LEN-1],
	input logic [E_SHARED-1:0] shared_exponent,
	output logic [31:0] fp32_dot_out_col1,
	output logic [31:0] fp32_dot_out_col2,
	output logic valid_out,
	output logic [3:0] fp32_flags_col1,
	output logic [3:0] fp32_flags_col2
);
    
endmodule