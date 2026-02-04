module aitb_top #(
	parameter string CHAIN_MODE = "tensor_chain_output"
) (
	input logic clk,
	input logic rst,
	input logic [1:0] acc_mode,
	input logic load_en,
	input logic [7:0] data_in [1:10],
	input logic [7:0] shared_exponent,
	input logic [31:0] fp32_cascade_in,

	output logic [31:0] fp32_dot_out,
	output logic [31:0] fp32_cascade_out,
	output logic [3:0]  fp32_flags
);

logic [7:0] input_buf [1:10];

generate
	for (genvar i = 1; i < 11; i++) begin
		pipeline #(.W(8), .STAGES(1)) LOAD_PIPE (
			.clk(clk),
			.rst(rst),
			.pipe_in(data_in[i]),
			.pipe_out(input_buf[i])
		);
	end

endgenerate

endmodule 
