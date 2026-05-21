// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module	aitb_no_chain_in_agilex_native_tensor_dsp_100_wg5iiha	(
			clk,
			clr0,
			clr1,
			ena,
			acc_en,
			zero_en,
			load_bb_one,
			load_bb_two,
			load_buf_sel,
			data_in_1,
			data_in_2,
			data_in_3,
			data_in_4,
			data_in_5,
			data_in_6,
			data_in_7,
			data_in_8,
			data_in_9,
			data_in_10,
			shared_exponent_data,
			cascade_data_out_col_1,
			cascade_data_out_col_2,
			fp32_col_1,
			fp32_col_2,
			fp32_col_1_flag,
			fp32_col_2_flag);

			input  clk;
			input  clr0;
			input  clr1;
			input  ena;
			input  acc_en;
			input  zero_en;
			input  load_bb_one;
			input  load_bb_two;
			input  load_buf_sel;
			input [7:0] data_in_1;
			input [7:0] data_in_2;
			input [7:0] data_in_3;
			input [7:0] data_in_4;
			input [7:0] data_in_5;
			input [7:0] data_in_6;
			input [7:0] data_in_7;
			input [7:0] data_in_8;
			input [7:0] data_in_9;
			input [7:0] data_in_10;
			input [7:0] shared_exponent_data;
			output [31:0] cascade_data_out_col_1;
			output [31:0] cascade_data_out_col_2;
			output [31:0] fp32_col_1;
			output [31:0] fp32_col_2;
			output [3:0] fp32_col_1_flag;
			output [3:0] fp32_col_2_flag;

			wire [31:0] cascade_data_out_col_1_w ;
			wire [31:0] cascade_data_out_col_2_w ;
			wire [31:0] fp32_col_1_w ;
			wire [31:0] fp32_col_2_w ;
			wire [3:0] fp32_col_1_flag_w ;
			wire [3:0] fp32_col_2_flag_w ;
			wire [31:0] cascade_data_out_col_1 = cascade_data_out_col_1_w [31:0] ;
			wire [31:0] cascade_data_out_col_2 = cascade_data_out_col_2_w [31:0] ;
			wire [31:0] fp32_col_1 = fp32_col_1_w [31:0] ;
			wire [31:0] fp32_col_2 = fp32_col_2_w [31:0] ;
			wire [3:0] fp32_col_1_flag = fp32_col_1_flag_w [3:0] ;
			wire [3:0] fp32_col_2_flag = fp32_col_2_flag_w [3:0] ;

    
        	wire [7:0] side_in_1 = 8'b0; 
		wire [7:0] side_in_2 = 8'b0;

			tennm_dsp_prime		tennm_dsp_prime_component (
						 .clk (clk),
						 .ena (ena),
						 .acc_en (acc_en),
						 .zero_en (zero_en),
						 .load_bb_one (load_bb_one),
						 .load_bb_two (load_bb_two),
						 .load_buf_sel (load_buf_sel),
						 .shared_exponent (shared_exponent_data),
						 .clr ({clr1,clr0}),
 
						 .data_in({side_in_2,side_in_1,data_in_10,data_in_9,data_in_8,data_in_7,data_in_6,data_in_5,data_in_4,data_in_3,data_in_2,data_in_1}),
						 .cascade_data_out ({cascade_data_out_col_2_w,cascade_data_out_col_1_w}),
						 .result_l({fp32_col_2_w[4:0],fp32_col_1_w[31:0]}),
						 .result_h({fp32_col_2_flag_w[3:0],fp32_col_1_flag_w[3:0],fp32_col_2_w[31:5]}));
			defparam
		    	tennm_dsp_prime_component.dsp_mode = "tensor_fp",
                        
		    	tennm_dsp_prime_component.dsp_side_feed_ctrl = "data_feed_in",
                        
		    	tennm_dsp_prime_component.dsp_chain_tensor = "zero_tensor_chain_output",
                        
		    	tennm_dsp_prime_component.dsp_fp32_sub_en = "float_sub_disabled";
                        


endmodule




