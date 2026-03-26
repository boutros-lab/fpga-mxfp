/*
* Set all required configuration signals using mxfp_mode
*/

import pkg_aitb::*;

module config_gen #(
	parameter E5M2_4_MODE       = 0,
	parameter FIXED_WIDTH_LOCAL = FIXED_RESULT_WIDTH - E5M2_4_MODE
)(
	input  mxfp_mode_e i_mxfp_mode,

	output logic [2:0] o_sign_shift,
	output logic [2:0] o_exp_bits,
	output logic [1:0] o_man_bits,
	output logic [4:0] o_exp_mask,
	output logic [2:0] o_man_mask,
	
	output logic signed [7:0] o_exponent_correction
);

// Exponent Corrections for Naive
localparam signed [7:0] EXP_CORRECTION_FIXED = FIXED_WIDTH_LOCAL - POINT_POSITION_FIXED - FP32_BIAS - 1;
localparam signed [7:0] EXP_CORRECTION_E5M2  = FIXED_WIDTH_LOCAL - POINT_POSITION_E5M2 - FP32_BIAS - 1;
localparam signed [7:0] EXP_CORRECTION_E4M3  = FIXED_WIDTH_LOCAL - POINT_POSITION_E4M3 - FP32_BIAS - 1;
localparam signed [7:0] EXP_CORRECTION_E3M2  = FIXED_WIDTH_LOCAL - POINT_POSITION_E3M2 - FP32_BIAS - 1;
localparam signed [7:0] EXP_CORRECTION_E2M3  = FIXED_WIDTH_LOCAL - POINT_POSITION_E2M3 - FP32_BIAS - 1;
localparam signed [7:0] EXP_CORRECTION_E2M1  = FIXED_WIDTH_LOCAL - POINT_POSITION_E2M1 - FP32_BIAS - 1;

always_comb begin
	case (i_mxfp_mode)
		MXFP8_52: begin
			o_sign_shift = 'h7;
			o_exp_bits   = 'h5;
			o_man_bits   = 'h2;
			o_exp_mask   = 'b11111;
			o_man_mask   = 'b11;

			o_exponent_correction = EXP_CORRECTION_E5M2;
		end
		MXFP8_43: begin
			o_sign_shift = 'h7;
			o_exp_bits   = 'h4;
			o_man_bits   = 'h3;
			o_exp_mask   = 'b1111;
			o_man_mask   = 'b111;

			o_exponent_correction = EXP_CORRECTION_E4M3;
		end
		MXFP6_32: begin
			o_sign_shift = 'h5;
			o_exp_bits   = 'h3;
			o_man_bits   = 'h2;
			o_exp_mask   = 'b111;
			o_man_mask   = 'b11;

			o_exponent_correction = EXP_CORRECTION_E3M2;
		end
		MXFP6_23: begin
			o_sign_shift = 'h5;
			o_exp_bits   = 'h2;
			o_man_bits   = 'h3;
			o_exp_mask   = 'b11;
			o_man_mask   = 'b111;

			o_exponent_correction = EXP_CORRECTION_E2M3;
		end
		MXFP4: begin
			o_sign_shift = 'h3;
			o_exp_bits   = 'h2;
			o_man_bits   = 'h1;
			o_exp_mask   = 'b11;
			o_man_mask   = 'b1;

			o_exponent_correction = EXP_CORRECTION_E2M1;
		end
		default: begin // FIXED
			o_sign_shift = 'b0;
			o_exp_bits   = 'b0;
			o_man_bits   = 'b0;
			o_exp_mask   = 'b0;
			o_man_mask   = 'b0;

			o_exponent_correction = EXP_CORRECTION_FIXED;
		end
	endcase
end

endmodule
