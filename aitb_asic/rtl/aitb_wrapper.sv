module aitb_wrapper (
	input logic clk,
	input logic rst,
	input logic i_load_en,
	input logic i_valid,
	input logic signed [7:0] i_data [0:9],
	input logic [7:0] i_sh_exp,
	output logic [31:0] o_result0,
	output logic [31:0] o_result1,
	output logic o_valid
);

localparam LATENCY = 4;

logic [LATENCY-1:0] valid;

always_ff @ (posedge clk) begin
	if (rst) begin
		valid <= 'd0;
	end else begin
		valid <= {valid[LATENCY-2:0], i_valid};
	end
end

assign o_valid = valid[LATENCY-1];

aitb_top aitb (
	.clk(clk),
	.rst(rst),
	.acc_en(1'b0),
	.zero_en(1'b1),
	.load_bb_one(i_load_en),
	.load_bb_two('0),
	.load_buf_sel('0),
	.data_in(i_data),
	.shared_exponent(i_sh_exp),
	.fp32_cascade_in_col1('0),
	.fp32_cascade_in_col2('0),
	.fp32_dot_out_col1(o_result0),
	.fp32_dot_out_col2(o_result1),
	.fp32_cascade_out_col1(),
	.fp32_cascade_out_col2(),
	.fp32_flags_col1(),
	.fp32_flags_col2()
);

endmodule
