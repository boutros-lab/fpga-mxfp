module fp_aitb #(
	parameter string CHAIN_MODE = "tensor_chain_output"
) (
	input logic clk,
	input logic rst,
	input logic acc_en,
	input logic zero_en,
	input logic load_en,
	input logic signed [7:0] data_in [1:10],
	input logic [7:0] shared_exponent,
	input logic [31:0] cascade_data_in_col_1,
	input logic [31:0] cascade_data_in_col_2,

	output logic [31:0] cascade_data_out_col_1,
	output logic [31:0] cascade_data_out_col_2,
	output logic [31:0] fp32_col_1,
	output logic [31:0] fp32_col_2,
	output logic [3:0] fp32_col_1_flag,
	output logic [3:0] fp32_col_2_flag
//	output logic       valid_out
//	output logic [31:0] fp32_dot_out,
);
			logic [31:0] cascade_data_out_col_1_w ;
			logic [31:0] cascade_data_out_col_2_w ;
			logic [31:0] fp32_col_1_w ;
			logic [31:0] fp32_col_2_w ;
			logic [3:0] fp32_col_1_flag_w ;
			logic [3:0] fp32_col_2_flag_w ;
			assign cascade_data_out_col_1 = cascade_data_out_col_1_w [31:0] ;
			assign cascade_data_out_col_2 = cascade_data_out_col_2_w [31:0] ;
			assign fp32_col_1 = fp32_col_1_w [31:0] ;
			assign fp32_col_2 = fp32_col_2_w [31:0] ;
			assign fp32_col_1_flag = fp32_col_1_flag_w [3:0] ;
			assign fp32_col_2_flag = fp32_col_2_flag_w [3:0] ;

    

			tennm_dsp_prime		tennm_dsp_prime_component (
						 .clk (clk),
						 .ena (1'b1),
						 .acc_en (acc_en),
						 .zero_en (zero_en),
						 .load_bb_one (load_en),
						 .load_bb_two (1'b0),
						 .load_buf_sel (1'b0),
						 .shared_exponent (shared_exponent),
						 .clr ({rst,rst}),
 
						 .data_in({16'b0,data_in[10],data_in[9],data_in[8],data_in[7],data_in[6],data_in[5],data_in[4],data_in[3],data_in[2],data_in[1]}),

						 .cascade_data_in ({cascade_data_in_col_2,cascade_data_in_col_1}),
						 .cascade_data_out ({cascade_data_out_col_2_w,cascade_data_out_col_1_w}),
						 .result_l({fp32_col_2_w[4:0],fp32_col_1_w[31:0]}),
						 .result_h({fp32_col_2_flag_w[3:0],fp32_col_1_flag_w[3:0],fp32_col_2_w[31:5]}));

			defparam
		    	tennm_dsp_prime_component.dsp_mode = "tensor_fp",
                        
		    	tennm_dsp_prime_component.dsp_side_feed_ctrl = "data_feed_in",
                        
		    	tennm_dsp_prime_component.dsp_chain_tensor = CHAIN_MODE,
                        
		    	tennm_dsp_prime_component.dsp_fp32_sub_en = "float_sub_disabled";
                        
endmodule 
