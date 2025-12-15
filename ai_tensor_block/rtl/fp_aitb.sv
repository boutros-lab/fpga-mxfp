module fp_aitb (
input logic clk,
input logic rst,
input logic [1:0] acc_mode,
input logic load_en,
input logic [7:0] data_in [1:10],
input logic [7:0] shared_exponent,
input logic [31:0] fp32_cascade_in,

output logic [31:0] fp32_dot_out,
output logic [31:0] fp32_cascade_out,
//output logic valid_out,
output logic [3:0]  fp32_flags
);

//			logic [31:0] cascade_data_out_col_1_w ;
			logic [31:0] cascade_data_out_col_2_w ;
//			logic [31:0] fp32_col_1_w ;
			logic [31:0] fp32_col_2_w ;
//			logic [3:0] fp32_col_1_flag_w ;
			logic [3:0] fp32_col_2_flag_w ;
//			logic [31:0] cascade_data_out_col_1 = cascade_data_out_col_1_w [31:0] ;
//			logic [31:0] cascade_data_out_col_2 = cascade_data_out_col_2_w [31:0] ;
//			logic [31:0] fp32_col_1 = fp32_col_1_w [31:0] ;
//			logic [31:0] fp32_col_2 = fp32_col_2_w [31:0] ;
//			logic [3:0] fp32_col_1_flag = fp32_col_1_flag_w [3:0] ;
//			logic [3:0] fp32_col_2_flag = fp32_col_2_flag_w [3:0] ;

    
//        	logic [7:0] side_in_1 = 8'b0; 
//			logic [7:0] side_in_2 = 8'b0;

			tennm_dsp_prime		tennm_dsp_prime_component (
						 .clk (clk),
						 .ena (1'b1),
						 .acc_en (acc_mode[0]),
						 .zero_en (acc_mode[1]),
						 .load_bb_one (load_en),
						 .load_bb_two (1'b0),
						 .load_buf_sel (1'b0),
						 .shared_exponent (shared_exponent),
						 .clr ({rst,rst}),
 
						 .data_in({16'b0,data_in[10],data_in[9],data_in[8],data_in[7],data_in[6],data_in[5],data_in[4],data_in[3],data_in[2],data_in[1]}),

						 .cascade_data_in ({32'b0,fp32_cascade_in}),
						 .cascade_data_out ({cascade_data_out_col_2_w,fp32_cascade_out}),
						 .result_l({fp32_col_2_w[4:0],fp32_dot_out[31:0]}),
						 .result_h({fp32_col_2_flag_w[3:0],fp32_flags[3:0],fp32_col_2_w[31:5]}));
			defparam
		    	tennm_dsp_prime_component.dsp_mode = "tensor_fp",
                        
		    	tennm_dsp_prime_component.dsp_side_feed_ctrl = "data_feed_in",
                        
		    	tennm_dsp_prime_component.dsp_chain_tensor = "tensor_chain_output",
                        
		    	tennm_dsp_prime_component.dsp_fp32_sub_en = "float_sub_disabled";
                        
endmodule 
