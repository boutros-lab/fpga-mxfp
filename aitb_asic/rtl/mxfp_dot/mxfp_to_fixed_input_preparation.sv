/*
* Input preparation muxes, takes flat input to DSP and separates it into
* individual elements based on MXFP_MODE
* Sepearates into: Sign Exponent and Significand
*
* Inputs expected in MXFP format
*
* Outputs the fixed point representations of input MXFP numbers
* Supports E3M2 K 8, E2M3 K 11, E2M1 K 16, E0M7 K10
*/

import pkg_aitb::*;

module mxfp_to_fixed_input_preparation #(
	parameter FLAT_WIDTH  = 80,

	parameter E3M2_DOT_LENGTH  =  8,
	parameter FIXED_DOT_LENGTH = 10,
	parameter E2M3_DOT_LENGTH  = 11,
	parameter E2M1_DOT_LENGTH  = 16,

	parameter E3M2_OPS  = E3M2_DOT_LENGTH,
	parameter FIXED_OPS = FIXED_DOT_LENGTH - E3M2_OPS,
	parameter E2M3_OPS  = E2M3_DOT_LENGTH - FIXED_DOT_LENGTH,
	parameter E2M1_OPS  = E2M1_DOT_LENGTH - E2M3_DOT_LENGTH,

	parameter E2M3_OPS_C = E2M3_DOT_LENGTH - E3M2_DOT_LENGTH,

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
localparam FP6_WIDTH = 6;
localparam FP4_WIDTH = 4;

logic fixed_mode, mxfp6_mode, mxfp4_mode, mxfp6_32_mode, mxfp6_23_mode;

// Components
logic e3m2_norm [E3M2_OPS];
logic e2m3_norm [E2M3_OPS_C];
logic e2m1_norm [E2M1_OPS];

logic       e3m2_sign [E3M2_OPS];
logic [2:0] e3m2_exp  [E3M2_OPS];
logic [3:0] e3m2_sig  [E3M2_OPS]; // Needs to hold E2M3 as well

logic signed [FIXED_WIDTH-1:0] fixed [FIXED_DOT_LENGTH];

logic       e2m3_sign [E2M3_OPS_C];
logic [1:0] e2m3_exp  [E2M3_OPS_C];
logic [3:0] e2m3_sig  [E2M3_OPS_C];

logic       e2m1_sign [E2M1_OPS];
logic [1:0] e2m1_exp  [E2M1_OPS];
logic [1:0] e2m1_sig  [E2M1_OPS];

// Conversions
logic signed [E3M2_WIDTH-1:0] e3m2_fixed [E3M2_OPS];
logic signed [E2M3_WIDTH-1:0] e2m3_fixed [E2M3_OPS_C];
logic signed [E2M1_WIDTH-1:0] e2m1_fixed [E2M1_OPS];

assign mxfp6_32_mode = i_mxfp_mode == MXFP6_32;
assign mxfp6_23_mode = i_mxfp_mode == MXFP6_23;

assign fixed_mode = i_mxfp_mode == FIXED;
assign mxfp6_mode = mxfp6_32_mode || mxfp6_23_mode;
assign mxfp4_mode = i_mxfp_mode == MXFP4;

// Breakout components
always_comb begin
	// FIXED
	
	for (int i = 0; i < FIXED_DOT_LENGTH; i++) begin
		fixed[i] = i_flat[i*FIXED_WIDTH+:FIXED_WIDTH];
	end

	// SIGNS

	for (int i = 0; i < E3M2_OPS; i++) begin
		if (mxfp6_mode) begin
			e3m2_sign[i] = i_flat[(i + 1) * FP6_WIDTH - 1];
		end else begin
			e3m2_sign[i] = i_flat[(i + 1) * FP4_WIDTH - 1];
		end
	end

	for (int i = 0; i < E2M3_OPS_C; i++) begin
		if (mxfp6_mode) begin
			e2m3_sign[i] = i_flat[(i + E3M2_OPS + 1) * FP6_WIDTH - 1];
		end else begin
			e2m3_sign[i] = i_flat[(i + E3M2_OPS + 1) * FP4_WIDTH - 1];
		end
	end

	for (int i = 0; i < E2M1_OPS; i++) begin
		e2m1_sign[i] = i_flat[(i + E3M2_OPS + E2M3_OPS_C + 1) * FP4_WIDTH - 1];
	end

	// EXPONENTS
	
	for (int i = 0; i < E3M2_OPS; i++) begin
		if (mxfp6_32_mode) begin
			e3m2_exp[i] = i_flat[i * FP6_WIDTH + 2 +: 3];
		end else if (mxfp6_23_mode) begin
			e3m2_exp[i] = i_flat[i * FP6_WIDTH + 3 +: 2];
		end else begin
			e3m2_exp[i] = i_flat[i * FP4_WIDTH + MXFP4_MAX_MAN +: MXFP4_MAX_EXP];
		end
	end

	for (int i = 0; i < E2M3_OPS_C; i++) begin
		if (mxfp6_32_mode) begin
			e2m3_exp[i] = i_flat[(i + E3M2_OPS) * FP6_WIDTH + 2 +: 3];
		end else if (mxfp6_23_mode) begin
			e2m3_exp[i] = i_flat[(i + E3M2_OPS) * FP6_WIDTH + 3 +: 2];
		end else begin
			e2m3_exp[i] = i_flat[(i + E3M2_OPS) * FP4_WIDTH + MXFP4_MAX_MAN +: MXFP4_MAX_EXP];
		end
	end

	for (int i = 0; i < E2M1_OPS; i++) begin
		e2m1_exp[i] = i_flat[(i + E3M2_OPS + E2M3_OPS_C) * FP4_WIDTH + MXFP4_MAX_MAN +: MXFP4_MAX_EXP];
	end

	// SIGNIFICANDS

	for (int i = 0; i < E3M2_OPS; i++) begin
		e3m2_norm[i] = |e3m2_exp[i];

		if (mxfp6_32_mode) begin
			e3m2_sig[i] = {e3m2_norm[i], i_flat[i * FP6_WIDTH +: 2]};
		end else if (mxfp6_23_mode) begin
			e3m2_sig[i] = {e3m2_norm[i], i_flat[i * FP6_WIDTH +: 3]};
		end else begin
			e3m2_sig[i] = {e3m2_norm[i], i_flat[i * FP4_WIDTH +: MXFP4_MAX_MAN]};
		end
	end

	for (int i = 0; i < E2M3_OPS_C; i++) begin
		e2m3_norm[i] = |e2m3_exp[i];

		if (mxfp6_23_mode) begin
			e2m3_sig[i] = {e2m3_norm[i], i_flat[(i + E3M2_OPS) * FP6_WIDTH +: 3]};
		end else begin
			e2m3_sig[i] = {e2m3_norm[i], i_flat[(i + E3M2_OPS) * FP4_WIDTH +: MXFP4_MAX_MAN]};
		end
	end

	for (int i = 0; i < E2M1_OPS; i++) begin
		e2m1_norm[i] = |e2m1_exp[i];

		e2m1_sig[i] = {e2m1_norm[i], i_flat[(i + E3M2_OPS + E2M3_OPS_C) * FP4_WIDTH +: MXFP4_MAX_MAN]};
	end
end

// Conversion
generate
	for (genvar i = 0; i < E3M2_OPS; i++) begin
		fix2float #(
			.EXP_WIDTH(3),
			.SIG_WIDTH(4) // Needs to hold E2M3 as well
		) u_fix2float_e3m2 (
			.i_sign(e3m2_sign[i]),
			.i_exp(e3m2_exp[i]),
			.i_sig(e3m2_sig[i]),
			.i_norm(e3m2_norm[i]),

			.o_fixed(e3m2_fixed[i])
		);
	end

	for (genvar i = 0; i < E2M3_OPS_C; i++) begin
		fix2float #(
			.EXP_WIDTH(2),
			.SIG_WIDTH(4)
		) u_fix2float_e2m3 (
			.i_sign(e2m3_sign[i]),
			.i_exp(e2m3_exp[i]),
			.i_sig(e2m3_sig[i]),
			.i_norm(e2m3_norm[i]),

			.o_fixed(e2m3_fixed[i])
		);
	end

	for (genvar i = 0; i < E2M1_OPS; i++) begin
		fix2float #(
			.EXP_WIDTH(2),
			.SIG_WIDTH(2)
		) u_fix2float_e2m1 (
			.i_sign(e2m1_sign[i]),
			.i_exp(e2m1_exp[i]),
			.i_sig(e2m1_sig[i]),
			.i_norm(e2m1_norm[i]),

			.o_fixed(e2m1_fixed[i])
		);
	end
endgenerate

// Final assignments
always_comb begin
	for (int i = 0; i < E3M2_OPS; i++) begin
		if (fixed_mode) begin
			o_e3m2[i] = fixed[i];
		end else begin
			o_e3m2[i] = e3m2_fixed[i];
		end
	end

	for (int i = 0; i < FIXED_OPS; i++) begin
		if (fixed_mode) begin
			o_fixed[i] = fixed[i+E3M2_OPS];
		end else if (mxfp6_32_mode) begin
			o_fixed[i] = 'b0; // Zero out for E3M2 (8 OPS)
		end else begin
			o_fixed[i] = e2m3_fixed[i];
		end
	end

	for (int i = 0; i < E2M3_OPS; i++) begin
		if (mxfp6_23_mode || mxfp4_mode) begin
			o_e2m3[i] = e2m3_fixed[i+FIXED_OPS];
		end else begin
			o_e2m3[i] = 'b0; // Zero out for E3M2 (8 OPS), and FIXED (10 OPS)
		end
	end


	for (int i = 0; i < E2M1_OPS; i++) begin
		if (mxfp4_mode) begin
			o_e2m1[i] = e2m1_fixed[i];
		end else begin
			o_e2m1[i] = 'b0; // Zero out for E3M2 (8 OPS), FIXED (10 OPS), and E2M3 (11 OPS)
		end
	end
end

endmodule

module fix2float #(
	parameter EXP_WIDTH = 3,
	parameter SIG_WIDTH = 3,
	parameter OUTPUT_WIDTH = SIG_WIDTH + ((1 << EXP_WIDTH) - 2) + 1
) (
	input logic                 i_sign,
	input logic [EXP_WIDTH-1:0] i_exp,
	input logic [SIG_WIDTH-1:0] i_sig,
	input logic                 i_norm,

	output logic signed [OUTPUT_WIDTH-1:0] o_fixed
);

logic signed [SIG_WIDTH:0] sig_sgn;

assign sig_sgn = i_sign ? -i_sig : i_sig;

assign o_fixed = $signed(sig_sgn) << $unsigned(i_exp - i_norm);

endmodule
