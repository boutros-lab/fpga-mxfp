/*
* Compile time configurable MXFP and Fixed point multiply
*/

module mxfp_multiply_dual #(
	parameter MXFP_WIDTH = 8,
	parameter EXP_WIDTH = 4,
	parameter MAN_WIDTH = 3,
	parameter FIXED_WIDTH = 5,

	parameter PROD_WIDTH = 2 * FIXED_WIDTH,

	parameter PROD_SHIFTED_WIDTH = 1 + 2 * ((MAN_WIDTH + 1) + ((1 << EXP_WIDTH) - 2))
)(
	input logic i_mxfp_mode,

	input logic [MXFP_WIDTH-1:0] i_mxfp_a,
	input logic [MXFP_WIDTH-1:0] i_mxfp_b,

	input logic signed [FIXED_WIDTH-1:0] i_fixed_a,
	input logic signed [FIXED_WIDTH-1:0] i_fixed_b,

	output logic signed [PROD_WIDTH-1:0]         o_prod,
	output logic signed [PROD_SHIFTED_WIDTH-1:0] o_prod_shifted
);
localparam MXFP_PROD_WIDTH = 1 + (2 * (MAN_WIDTH + 1));

logic signed [FIXED_WIDTH-1:0]        op_a, op_b;

logic                 sign_a, sign_b;
logic                 norm_a, norm_b;
logic [EXP_WIDTH-1:0] exp_a, exp_b;
logic [EXP_WIDTH:0]   exp_sum;
logic [MAN_WIDTH:0]   sig_a, sig_b;

logic signed [MAN_WIDTH+1:0] sig_sgn_a, sig_sgn_b;

assign sign_a = i_mxfp_a[MXFP_WIDTH-1];
assign sign_b = i_mxfp_b[MXFP_WIDTH-1];

assign exp_a = i_mxfp_a[MAN_WIDTH+:EXP_WIDTH];
assign exp_b = i_mxfp_b[MAN_WIDTH+:EXP_WIDTH];

assign norm_a = |exp_a;
assign norm_b = |exp_b;

assign exp_sum = exp_a + exp_b - norm_a - norm_b;

assign sig_a = {norm_a, i_mxfp_a[0+:MAN_WIDTH]};
assign sig_b = {norm_b, i_mxfp_b[0+:MAN_WIDTH]};

assign sig_sgn_a = sign_a ? -sig_a : sig_a;
assign sig_sgn_b = sign_b ? -sig_b : sig_b;

assign op_a = i_mxfp_mode ? sig_sgn_a : i_fixed_a;
assign op_b = i_mxfp_mode ? sig_sgn_b : i_fixed_b;

assign o_prod = op_a * op_b;

assign o_prod_shifted = $signed(o_prod[0+:MXFP_PROD_WIDTH]) << $unsigned(exp_sum);

endmodule
