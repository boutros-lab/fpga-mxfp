module tb_wrapper #(
    parameter exp_width = 5,
    parameter man_width = 2,
    parameter k         = 32,
    parameter bit_width = 1 + exp_width + man_width,
    parameter fi_width  = man_width + 2,
    parameter prd_width = 2 * ((1<<exp_width) + man_width),
    parameter out_width = prd_width + $clog2(k)
)(
    input  logic clk,
    input  logic rst,
    input  logic i_valid,
    output logic o_valid,

    input  logic [bit_width-1:0] i_vec_a[k],
    input  logic [bit_width-1:0] i_vec_b[k],
    output logic [out_width-1:0] o_result
);

logic signed [bit_width-1:0] sgn_vec_a[k];
logic signed [bit_width-1:0] sgn_vec_b[k];

always_comb begin
	for (int i = 0; i < k; i++) begin
		sgn_vec_a[i] = i_vec_a[i];
		sgn_vec_b[i] = i_vec_b[i];
	end
end

dot_fp #(
	.exp_width(exp_width), 
	.man_width(man_width), 
	.k(k)
) u_dot_fp (
	.i_vec_a(sgn_vec_a),
	.i_vec_b(sgn_vec_b),
	.o_dp(o_result)
);

assign o_valid = i_valid;

endmodule
