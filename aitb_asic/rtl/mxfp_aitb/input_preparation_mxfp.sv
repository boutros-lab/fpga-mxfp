/*
* Input preparation muxes, takes flat input to DSP and separates it into
* individual elements based on MXFP_MODE
* Sepearates into: Fixed, FP8, FP6, FP4
*/

import pkg_aitb::*;

module input_preparation_mxfp #(
	parameter FLAT_WIDTH  = 80,
	parameter FIXED_WIDTH = 8,
	parameter FP8_WIDTH   = 8,
	parameter FP6_WIDTH   = 6,
	parameter FP4_WIDTH   = 4,

	parameter FIXED_ELEMENTS = 10,
	parameter FP8_ELEMENTS   = 8,
	parameter FP6_ELEMENTS   = 4,
	parameter FP4_ELEMENTS   = 4
)(
	input  mxfp_mode_e            i_mxfp_mode,
	input  logic [FLAT_WIDTH-1:0] i_flat,

	output logic signed [FIXED_WIDTH-1:0] o_fixed [FIXED_ELEMENTS],
	output logic        [FP8_WIDTH-1:0]   o_fp8   [FP8_ELEMENTS],
	output logic        [FP6_WIDTH-1:0]   o_fp6   [FP6_ELEMENTS],
	output logic        [FP4_WIDTH-1:0]   o_fp4   [FP4_ELEMENTS]
);

logic mxfp8_mode, mxfp6_mode;

assign mxfp8_mode = (i_mxfp_mode == MXFP8_52) || (i_mxfp_mode == MXFP8_43);
assign mxfp6_mode = (i_mxfp_mode == MXFP6_32) || (i_mxfp_mode == MXFP6_23);

always_comb begin
	for (int i = 0; i < FIXED_ELEMENTS; i++) begin
		o_fixed[i] = $signed(i_flat[i*FIXED_WIDTH+:FIXED_WIDTH]);
	end

	for (int i = 0; i < FP8_ELEMENTS; i++) begin
		if (mxfp8_mode) begin
			o_fp8[i] = i_flat[i*FP8_WIDTH+:FP8_WIDTH];
		end else if (mxfp6_mode) begin
			o_fp8[i] = i_flat[i*FP6_WIDTH+:FP6_WIDTH];
		end else begin
			o_fp8[i] = i_flat[i*FP4_WIDTH+:FP4_WIDTH];
		end
	end

	for (int i = 0; i < FP6_ELEMENTS; i++) begin
		if (mxfp6_mode) begin
			o_fp6[i] = i_flat[(i + FP8_ELEMENTS)*FP6_WIDTH+:FP6_WIDTH];
		end else begin
			o_fp6[i] = i_flat[(i + FP8_ELEMENTS)*FP4_WIDTH+:FP4_WIDTH];
		end
	end

	for (int i = 0; i < FP4_ELEMENTS; i++) begin
		o_fp4[i] = i_flat[(i + FP8_ELEMENTS + FP6_ELEMENTS)*FP4_WIDTH+:FP4_WIDTH];
	end
end

endmodule
