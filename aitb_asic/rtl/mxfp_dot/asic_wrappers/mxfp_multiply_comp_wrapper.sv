module mxfp_multiply_comp_asic_wrapper #(
	parameter MAX_EXP_BITS = 5,
	parameter MAX_MAN_BITS = 3,
	parameter MXFP_WIDTH   = 8,
	parameter FIXED_WIDTH  = 8,

	parameter FIXED_MULT   = 1,
	parameter MULT_WIDTH   = FIXED_MULT ? 8 : MAX_MAN_BITS + 1,

	parameter MAN_PROD_WIDTH = 2 * (MAX_MAN_BITS + 1),
	parameter PROD_WIDTH     = 2 * MULT_WIDTH
)(
	// Fixed or MXFP input
	input logic fixed_mode,

	// Input MXFP components
	input logic                    sign_a,
	input logic                    sign_b,
	input logic [MAX_EXP_BITS-1:0] exp_a,
	input logic [MAX_EXP_BITS-1:0] exp_b,
	input logic [MAX_MAN_BITS:0]   sig_a,
	input logic [MAX_MAN_BITS:0]   sig_b,

	// Result of multiply
	output logic        [MAX_EXP_BITS:0]   exp_sum,
	output logic signed [MAN_PROD_WIDTH:0] man_prd_signed,
	output logic signed [PROD_WIDTH-1:0]   fixed_prd_signed
);

mxfp_multiply_comp #(
	.MAX_EXP_BITS(MAX_EXP_BITS),
	.MAX_MAN_BITS(MAX_MAN_BITS),
	.MXFP_WIDTH(MXFP_WIDTH),
	.FIXED_MULT(FIXED_MULT),
	.MULT_WIDTH(MULT_WIDTH)
) u_mxfp_multiply_comp (
	.fixed_mode(fixed),
	.sign_a(),
	.sign_b(),
	.exp_a(),
	.exp_b(),
	.sig_a(),
	.sig_b(),
	.exp_sum(exp_sum),
	.man_prd_signed(man_prd_signed),
	.fixed_prd_signed(fixed_prd_signed)
);

endmodule
