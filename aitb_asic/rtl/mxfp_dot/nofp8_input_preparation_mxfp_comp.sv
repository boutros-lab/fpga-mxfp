/*
* Input preparation muxes, takes flat input to DSP and separates it into
* individual elements based on MXFP_MODE
* Sepearates into: Sign Exponent and Significand
*
* Only FP6 and FP4
*/

import pkg_aitb::*;

module nofp8_input_preparation_mxfp_comp #(
	parameter FLAT_WIDTH  = 80,
	parameter FIXED_WIDTH = 8,
	parameter FP6_WIDTH   = 6,
	parameter FP4_WIDTH   = 4,

	parameter FIXED_ELEMENTS = 10,
	parameter FP6_ELEMENTS   = 12,
	parameter FP4_ELEMENTS   = 4,

	parameter TOTAL_ELEMENTS = FP6_ELEMENTS + FP4_ELEMENTS
)(
	input  mxfp_mode_e            i_mxfp_mode,
	input  logic [FLAT_WIDTH-1:0] i_flat,

	output logic                     o_fp6_sign [FP6_ELEMENTS],
	output logic [MXFP6_MAX_EXP-1:0] o_fp6_exp  [FP6_ELEMENTS],
	output logic [MXFP6_MAX_MAN:0]   o_fp6_sig  [FP6_ELEMENTS],

	output logic                     o_fp4_sign [FP4_ELEMENTS],
	output logic [MXFP4_MAX_EXP-1:0] o_fp4_exp  [FP4_ELEMENTS],
	output logic [MXFP4_MAX_MAN:0]   o_fp4_sig  [FP4_ELEMENTS]
);

logic fixed_mode, mxfp6_mode, mxfp4_mode, mxfp6_32_mode, mxfp6_23_mode;

logic fp6_norm [FP6_ELEMENTS];

assign mxfp6_32_mode = i_mxfp_mode == MXFP6_32;
assign mxfp6_23_mode = i_mxfp_mode == MXFP6_23;

assign fixed_mode = i_mxfp_mode == FIXED;
assign mxfp6_mode = mxfp6_32_mode || mxfp6_23_mode;
assign mxfp4_mode = i_mxfp_mode == MXFP4;

always_comb begin
	// SIGNS

	for (int i = 0; i < FP6_ELEMENTS; i++) begin
		// Not all fp6 elements need to support fixed point
		if (i < FIXED_ELEMENTS) begin
			if (fixed_mode) begin
				o_fp6_sign[i] = i_flat[(i + 1) * FIXED_WIDTH - 1];
			end else if (mxfp6_mode) begin
				o_fp6_sign[i] = i_flat[(i + 1) * FP6_WIDTH - 1];
			end else begin
				o_fp6_sign[i] = i_flat[(i + 1) * FP4_WIDTH - 1];
			end
		end else begin
			if (mxfp6_mode) begin
				o_fp6_sign[i] = i_flat[(i + 1) * FP6_WIDTH - 1];
			end else begin
				o_fp6_sign[i] = i_flat[(i + 1) * FP4_WIDTH - 1];
			end
		end
	end

	for (int i = 0; i < FP4_ELEMENTS; i++) begin
		o_fp4_sign[i] = i_flat[(i + FP6_ELEMENTS + 1) * FP4_WIDTH - 1];
	end

	// EXPONENTS
	
	for (int i = 0; i < FP6_ELEMENTS; i++) begin
		// Not all fp6 elements need to support fixed point
		if (i < FIXED_ELEMENTS) begin
			if (fixed_mode) begin
				o_fp6_exp[i] = i_flat[i * FIXED_WIDTH + FIXED_MAN_ENC +: FIXED_EXP_ENC];
			end else if (mxfp6_32_mode) begin
				o_fp6_exp[i] = i_flat[i * FP6_WIDTH + 2 +: 3];
			end else if (mxfp6_23_mode) begin
				o_fp6_exp[i] = i_flat[i * FP6_WIDTH + 3 +: 2];
			end else begin
				o_fp6_exp[i] = i_flat[i * FP4_WIDTH + MXFP4_MAX_MAN +: MXFP4_MAX_EXP];
			end
		end else begin
			if (mxfp6_32_mode) begin
				o_fp6_exp[i] = i_flat[i * FP6_WIDTH + 2 +: 3];
			end else if (mxfp6_23_mode) begin
				o_fp6_exp[i] = i_flat[i * FP6_WIDTH + 3 +: 2];
			end else begin
				o_fp6_exp[i] = i_flat[i * FP4_WIDTH + MXFP4_MAX_MAN +: MXFP4_MAX_EXP];
			end
		end
	end

	for (int i = 0; i < FP4_ELEMENTS; i++) begin
		o_fp4_exp[i] = i_flat[(i + FP6_ELEMENTS) * FP4_WIDTH + MXFP4_MAX_MAN +: MXFP4_MAX_EXP];
	end

	// SIGNIFICANDS

	for (int i = 0; i < FP6_ELEMENTS; i++) begin
		fp6_norm[i] = |o_fp6_exp[i];

		// Not all fp6 elements need to support fixed point
		if (i < FIXED_ELEMENTS) begin
			if (fixed_mode) begin
				o_fp6_sig[i] = i_flat[i * FIXED_WIDTH +: FIXED_MAN_ENC];
			end else if (mxfp6_32_mode) begin
				o_fp6_sig[i] = {fp6_norm[i], i_flat[i * FP6_WIDTH +: 2]};
			end else if (mxfp6_23_mode) begin
				o_fp6_sig[i] = {fp6_norm[i], i_flat[i * FP6_WIDTH +: 3]};
			end else begin
				o_fp6_sig[i] = {fp6_norm[i], i_flat[i * FP4_WIDTH +: MXFP4_MAX_MAN]};
			end
		end else begin
			if (mxfp6_32_mode) begin
				o_fp6_sig[i] = {fp6_norm[i], i_flat[i * FP6_WIDTH +: 2]};
			end else if (mxfp6_23_mode) begin
				o_fp6_sig[i] = {fp6_norm[i], i_flat[i * FP6_WIDTH +: 3]};
			end else begin
				o_fp6_sig[i] = {fp6_norm[i], i_flat[i * FP4_WIDTH +: MXFP4_MAX_MAN]};
			end
		end
	end

	for (int i = 0; i < FP4_ELEMENTS; i++) begin
		o_fp4_sig[i] = {|o_fp4_exp[i], i_flat[(i + FP6_ELEMENTS) * FP4_WIDTH +: MXFP4_MAX_MAN]};
	end
end

endmodule
