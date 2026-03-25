/*
* Wrapper for mxfp_mult_comp_shift
*/

module mxfp_mult_comp_shift_wrapper #(
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
localparam FIXED_MULT      = 1;
localparam MAX_EXP_BITS    = 5;
localparam MAX_MAN_BITS    = 3;
localparam MXFP_WIDTH      = 8;
localparam MXFP_MULT_WIDTH = 2 * ((1 << MAX_EXP_BITS) + MAX_MAN_BITS);

logic fixed_mode;
logic signed [MXFP_MULT_WIDTH-1:0] mxfp_mult_result;

assign fixed_mode = exp_width == 'b0 ? 1'b1 : 1'b0;

// Breakout MXFP numbers
logic sign_a, sign_b;
logic [MAX_EXP_BITS-1:0] exp_a, exp_b;
logic [MAX_MAN_BITS:0]   sig_a, sig_b;

generate
	if (exp_width > 0) begin
		assign sign_a = i_vec_a[0][bit_width-1];
		assign sign_b = i_vec_b[0][bit_width-1];
		
		assign exp_a = i_vec_a[0][man_width+:exp_width];
		assign exp_b = i_vec_b[0][man_width+:exp_width];
		
		assign sig_a = {|exp_a, i_vec_a[0][0+:man_width]};
		assign sig_b = {|exp_b, i_vec_b[0][0+:man_width]};
	end else begin : fixed
		logic signed [bit_width-1:0] fixed_a, fixed_b;

		assign fixed_a = i_vec_a[0][bit_width-1] ? -i_vec_a[0][0+:man_width] 
							 : i_vec_a[0][0+:man_width];
		assign fixed_b = i_vec_b[0][bit_width-1] ? -i_vec_b[0][0+:man_width] 
							 : i_vec_b[0][0+:man_width];
		
		assign sign_a = fixed_a[7];
		assign sign_b = fixed_b[7];

		assign exp_a = fixed_a[6:4];
		assign exp_b = fixed_b[6:4];
		
		assign sig_a = fixed_a[3:0];
		assign sig_b = fixed_b[3:0];
	end
endgenerate

// Always use set size, set exp_bits and man_bit based on TB params
mxfp_mult_comp_shift #(
	.MAX_EXP_BITS(MAX_EXP_BITS),
	.MAX_MAN_BITS(MAX_MAN_BITS),
	.FIXED_MULT(FIXED_MULT)
) u_mxfp_mult_comp_shift (
	.fixed_mode(fixed_mode),
	.sign_a(sign_a),
	.sign_b(sign_b),
	.exp_a(exp_a),
	.exp_b(exp_b),
	.sig_a(sig_a),
	.sig_b(sig_b),
	.mxfp_mult_fixed(mxfp_mult_result)
);

assign o_result = mxfp_mult_result[out_width-1:0];
assign o_valid  = i_valid;

endmodule
