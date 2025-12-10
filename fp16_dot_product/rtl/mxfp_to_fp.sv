module mxfp_to_fp #(
	parameter exp_bits_i = 2,
	parameter man_bits_i = 1,
	parameter exp_bits_o = 5,
	parameter man_bits_o = 10
) (
	input  logic clk,
	input  logic rst,
	input  logic [exp_bits_i + man_bits_i:0] i_mxfp,
	output logic [exp_bits_o + man_bits_o:0] o_fp
);
// TODO, this doesn't handle subnormals correctly (unless e_i == e_o)
localparam bias_i = 2**(exp_bits_i - 1) - 1;
localparam bias_o = 2**(exp_bits_o - 1) - 1;

localparam bias_c = bias_o - bias_i;

logic sign_i;
logic [exp_bits_i-1:0] exp_i;
logic [man_bits_i-1:0] man_i;

assign {sign_i, exp_i, man_i} = i_mxfp;

logic sign_o;
logic [exp_bits_o-1:0] exp_o;
logic [man_bits_o-1:0] man_o;

assign sign_o = sign_i;
assign exp_o = exp_i + bias_c;
assign man_o = {man_i, 'b0};

assign o_fp = {sign_o, exp_o, man_o};

endmodule
