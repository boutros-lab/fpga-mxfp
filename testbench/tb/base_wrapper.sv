/*
* Base TB Wrapper
*/

module <name> #(
	parameter exp_width = 5,
	parameter man_width = 2,
	parameter k = 8,

	parameter bit_width = 1 + exp_width + man_width
)(
	input  logic clk,
	input  logic rst,
	input  logic i_valid,
	output logic o_valid,
        input  logic [bit_width-1:0] i_vec_a [k],
        input  logic [bit_width-1:0] i_vec_b [k],
	input  logic [7:0] i_shared_exp_a,
	input  logic [7:0] i_shared_exp_b,
        output logic [31:0] o_result
);

endmodule
