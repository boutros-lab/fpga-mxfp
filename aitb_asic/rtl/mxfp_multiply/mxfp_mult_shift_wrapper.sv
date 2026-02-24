/*
* Wrapper for mxfp_multiply_shift
*/

module mxfp_mult_shift_wrapper #(
	parameter exp_width = 5,
	parameter man_width = 2,
	parameter k = 1,

    	parameter bit_width = 1 + exp_width + man_width,
	parameter out_width = 2 * ((1 << exp_width) + man_width) + $clog2(k)
)(
	input  logic clk,
	input  logic rst,
	input  logic i_valid,
	output logic o_valid,
        input  logic [bit_width-1:0] i_vec_a [k],
        input  logic [bit_width-1:0] i_vec_b [k],
        output logic [out_width-1:0] o_result
);
localparam MAX_EXP_BITS    = 5;
localparam MAX_MAN_BITS    = 3;
localparam MXFP_WIDTH      = 8;
localparam MXFP_MULT_WIDTH = 2 * ((1 << MAX_EXP_BITS) + MAX_MAN_BITS);

logic signed [MXFP_MULT_WIDTH-1:0] mxfp_mult_result;
logic inf, nan;

// Always use set size, set exp_bits and man_bit based on TB params
mxfp_mult_shift #(
	.MAX_EXP_BITS(MAX_EXP_BITS),
	.MAX_MAN_BITS(MAX_MAN_BITS),
	.MXFP_WIDTH(MXFP_WIDTH)
//	OUTPUT_WIDTH = 2 * ((1 << MAX_EXP_BITS) + MAX_MAN_BITS),
) u_mxfp_mult_shift (
	.exp_bits(exp_width),
	.man_bits(man_width),
	.mxfp_a(i_vec_a[0]),
	.mxfp_b(i_vec_b[0]),
	.mxfp_mult_fixed(mxfp_mult_result),
	.inf(inf),
	.nan(nan)
);

assign o_result = mxfp_mult_result[out_width-1:0];
assign o_valid  = i_valid;

endmodule
