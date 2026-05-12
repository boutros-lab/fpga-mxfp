module fxp_aitb (
	input  clk,
	input  rst,
	input  i_load_en,
	input  i_valid,
	input  [7:0] i_data [0:9],
	output [31:0] o_result0,
	output [31:0] o_result1,
	output o_valid
);

localparam LATENCY = 4;

logic [95:0] w_data_in;
logic [LATENCY-1:0] valid;

always_ff @ (posedge clk) begin
	if (rst) begin
		valid <= 'd0;
	end else begin
		valid <= {valid[LATENCY-2:0], i_valid};
	end
end

genvar i;
generate
for (i = 0; i < 10; i = i + 1) begin: concat_i_data
	assign w_data_in[i*8+:8] = i_data[i];
end
assign w_data_in[95:80] = 16'd0;
assign o_valid = valid[LATENCY-1];
endgenerate

tennm_dsp_prime tennm_dsp_prime_component (
	.clk 				(clk),
	.ena 				(1'b1),
	.load_bb_one 	(i_load_en),
	.load_bb_two 	(1'b0),
	.load_buf_sel 	(1'b0),
	.clr 				({rst,rst}),
	.data_in			(w_data_in),
	.result_l		({o_result1[4:0],o_result0}),
	.result_h		(o_result1[31:5])
);    
	
defparam
	tennm_dsp_prime_component.dsp_mode = "tensor_fxp",				
	tennm_dsp_prime_component.dsp_side_feed_ctrl = "data_feed_in",
	tennm_dsp_prime_component.dsp_chain_tensor = "zero_tensor_chain_output",
	tennm_dsp_prime_component.dsp_fp32_sub_en = "float_sub_disabled";

endmodule
