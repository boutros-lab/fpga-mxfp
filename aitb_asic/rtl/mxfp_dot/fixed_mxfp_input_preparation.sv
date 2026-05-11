/*
* Input preparation muxes, takes flat input to DSP and separates it into
* individual elements
*
* Supports MXFP4 and MXFP6 fixed point representaions
*/

import pkg_aitb::*;

module fixed_mxfp_input_preparation #(
	parameter FLAT_WIDTH  = 80,

	parameter E3M2_DOT_LENGTH  =  8,
	parameter FIXED_DOT_LENGTH = 10,
	parameter E2M3_DOT_LENGTH  = 11,
	parameter E2M1_DOT_LENGTH  = 16,

	parameter E3M2_OPS  = E3M2_DOT_LENGTH,
	parameter FIXED_OPS = FIXED_DOT_LENGTH - E3M2_OPS,
	parameter E2M3_OPS  = E2M3_DOT_LENGTH - FIXED_DOT_LENGTH,
	parameter E2M1_OPS  = E2M1_DOT_LENGTH - E2M3_DOT_LENGTH,

	parameter E3M2_WIDTH  = 10, // 1 + (M + 1) + (2^E - 2)
	parameter FIXED_WIDTH =  8,
	parameter E2M3_WIDTH  =  7,
	parameter E2M1_WIDTH  =  5
)(
	input  mxfp_mode_e            i_mxfp_mode,
	input  logic [FLAT_WIDTH-1:0] i_flat,

	output logic signed [E3M2_WIDTH-1:0]  o_e3m2  [E3M2_OPS],
	output logic signed [FIXED_WIDTH-1:0] o_fixed [FIXED_OPS],
	output logic signed [E2M3_WIDTH-1:0]  o_e2m3  [E2M3_OPS],
	output logic signed [E2M1_WIDTH-1:0]  o_e2m1  [E2M1_OPS]
);
logic fixed_mode, mxfp4_mode, mxfp6_32_mode, mxfp6_23_mode;

assign mxfp6_32_mode = i_mxfp_mode == MXFP6_32;
assign mxfp6_23_mode = i_mxfp_mode == MXFP6_23;

assign fixed_mode = i_mxfp_mode == FIXED;
assign mxfp4_mode = i_mxfp_mode == MXFP4;

always_comb begin
	for (int i = 0; i < E3M2_OPS; i++) begin
		if (mxfp6_32_mode) begin
			o_e3m2[i] = $signed(i_flat[i*E3M2_WIDTH+:E3M2_WIDTH]);
		end else if (fixed_mode) begin
			o_e3m2[i] = $signed(i_flat[i*FIXED_WIDTH+:FIXED_WIDTH]);
		end else if (mxfp6_23_mode) begin
			o_e3m2[i] = $signed(i_flat[i*E2M3_WIDTH+:E2M3_WIDTH]);
		end else begin // E2M1
			o_e3m2[i] = $signed(i_flat[i*E2M1_WIDTH+:E2M1_WIDTH]);
		end
	end

	for (int i = 0; i < FIXED_OPS; i++) begin
		if (fixed_mode) begin
			o_fixed[i] = $signed(i_flat[(i+E3M2_OPS)*FIXED_WIDTH+:FIXED_WIDTH]);
		end else if (mxfp6_23_mode) begin
			o_fixed[i] = $signed(i_flat[(i+E3M2_OPS)*E2M3_WIDTH+:E2M3_WIDTH]);
		end else if (mxfp4_mode) begin
			o_fixed[i] = $signed(i_flat[(i+E3M2_OPS)*E2M1_WIDTH+:E2M1_WIDTH]);
		end else begin
			o_fixed[i] = 'b0;
		end
	end

	for (int i = 0; i < E2M3_OPS; i++) begin
		if (mxfp6_23_mode) begin
			o_e2m3[i] = $signed(i_flat[(i+E3M2_OPS+FIXED_OPS)*E2M3_WIDTH+:E2M3_WIDTH]);
		end else if (mxfp4_mode) begin
			o_e2m3[i] = $signed(i_flat[(i+E3M2_OPS+FIXED_OPS)*E2M1_WIDTH+:E2M1_WIDTH]);
		end else begin
			o_e2m3[i] = 'b0;
		end
	end

	for (int i = 0; i < E2M1_OPS; i++) begin
		if (mxfp4_mode) begin
			o_e2m1[i] = $signed(i_flat[(i+E3M2_OPS+FIXED_OPS+E2M3_OPS)*E2M1_WIDTH+:E2M1_WIDTH]);
		end else begin
			o_e2m1[i] = 'b0;
		end
	end
end

endmodule
