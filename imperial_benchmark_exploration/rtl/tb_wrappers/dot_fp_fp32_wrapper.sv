/*
* dot_fp_fp32 TB Wrapper
*/

module dot_fp_fp32_wrapper #(
	parameter exp_width = 5,
	parameter man_width = 2,
	parameter k = 8,

	parameter bit_width = 1 + exp_width + man_width
)(
	input  logic clk,
	input  logic rst,
	input  logic i_valid,
	output logic o_valid,
        input  logic signed [bit_width-1:0] i_vec_a [k],
        input  logic signed [bit_width-1:0] i_vec_b [k],
	input  logic [7:0] i_shared_exp_a,
	input  logic [7:0] i_shared_exp_b,
        output logic [31:0] o_result
);

// 1 input
// 1 after mult
// $clog2(k) - 1 for vec_sum
// 1 after that
// variable fix2float: E2M1 5 E2M3 6 E3M2 6 E4M3 11 E5M2 14
// 1 after fix2float
localparam fix2fp_stages = (exp_width == 5 && man_width == 2) ? 14 
							      : (exp_width == 4 && man_width == 3) ? 11 
							      : (exp_width == 3 && man_width == 2) ?  6 
							      : (exp_width == 2 && man_width == 3) ?  6 
							      : (exp_width == 2 && man_width == 1) ?  5 
							      : 0;

localparam latency = 3 + $clog2(k) + fix2fp_stages;

logic [latency-1:0] valid_sr;

always_ff @(posedge clk) begin
	if (rst) begin
		valid_sr <= 'b0;
	end else begin
		valid_sr <= {valid_sr[latency-2:0], i_valid};
	end
end

assign o_valid = valid_sr[latency-1];

dot_fp_fp32 #(
	.exp_width(exp_width),
	.man_width(man_width),
	.k(k)
) u_dot_fp_fp32 (
	.clk(clk),
	.rst(rst),
	.i_vec_a(i_vec_a),
	.i_vec_b(i_vec_b),
	.i_shared_exp_a(i_shared_exp_a),
	.i_shared_exp_b(i_shared_exp_b),
	.o_fp32_q(o_result)
);

endmodule
