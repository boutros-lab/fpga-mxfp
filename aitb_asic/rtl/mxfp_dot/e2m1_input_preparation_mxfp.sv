/*
* Input preparation muxes, takes flat input to DSP and separates it into
* individual elements
*
* Only FP4
*/

import pkg_aitb::*;

module e2m1_input_preparation_mxfp #(
	parameter FLAT_WIDTH  = 80,
	parameter FIXED_WIDTH = 8,
	parameter FP4_WIDTH   = 4,

	parameter FIXED_ELEMENTS = 10,
	parameter FP4_ELEMENTS   = 16
)(
	input  logic [FLAT_WIDTH-1:0] i_flat,

	output logic signed [FIXED_WIDTH-1:0] o_fixed [FIXED_ELEMENTS],
	output logic        [FP4_WIDTH-1:0]   o_fp4   [FP4_ELEMENTS]
);

always_comb begin
	for (int i = 0; i < FIXED_ELEMENTS; i++) begin
		o_fixed[i] = $signed(i_flat[i*FIXED_WIDTH+:FIXED_WIDTH]);
	end

	for (int i = 0; i < FP4_ELEMENTS; i++) begin
		o_fp4[i] = i_flat[i*FP4_WIDTH+:FP4_WIDTH];
	end
end

endmodule
