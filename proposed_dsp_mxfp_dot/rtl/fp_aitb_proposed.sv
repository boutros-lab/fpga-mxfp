import pkg_aitb::*;

module fp_aitb_proposed #(
    parameter mxfp_mode_e MODE = MXFP4,
	parameter string CHAIN_MODE = "tensor_chain_output",
    parameter bit IS_SIM = 1
) (
    input logic clk,
    input logic rst,
    input logic acc_en_i,
	input logic zero_en_i,
	input logic load_en_i,
    input logic [79:0] data_i,
    input logic [7:0] shared_exponent_i,
	input logic [31:0] fp32_cascade_in_col1_i,
	input logic [31:0] fp32_cascade_in_col2_i,
    output logic [31:0] fp32_dot_out_col1_o,
	output logic [31:0] fp32_dot_out_col2_o,
	output logic [31:0] fp32_cascade_out_col1_o,
	output logic [31:0] fp32_cascade_out_col2_o,
	output logic [3:0]  fp32_flags_col1_o,
	output logic [3:0]  fp32_flags_col2_o
);

    generate
        if (IS_SIM) begin
            naive_mxfp_aitb_top aitb(
                .clk(clk),
                .rst(rst),
                .acc_en(acc_en_i),
                .zero_en(zero_en_i),
                .load_bb_one(load_en_i),
                .load_bb_two('0),
                .load_buf_sel('0),
                .i_mxfp_mode(MODE),
                .data_in(data_i),
                .shared_exponent(shared_exponent_i),
                .fp32_cascade_in_col1(fp32_cascade_in_col1_i),
                .fp32_cascade_in_col2(fp32_cascade_in_col2_i),
                .fp32_dot_out_col1(fp32_dot_out_col1_o),
                .fp32_dot_out_col2(fp32_dot_out_col2_o),
                .fp32_cascade_out_col1(fp32_cascade_out_col1_o),
                .fp32_cascade_out_col2(fp32_cascade_out_col2_o),
                .fp32_flags_col1(fp32_flags_col1_o),
                .fp32_flags_col2(fp32_flags_col2_o)
            );
        end else begin	
			logic [31:0] cascade_data_out_col_1_w ;
			logic [31:0] cascade_data_out_col_2_w ;
			logic [31:0] fp32_col_1_w ;
			logic [31:0] fp32_col_2_w ;
			logic [3:0] fp32_col_1_flag_w ;
			logic [3:0] fp32_col_2_flag_w ;
			assign fp32_cascade_out_col1_o = cascade_data_out_col_1_w [31:0] ;
			assign fp32_cascade_out_col2_o = cascade_data_out_col_2_w [31:0] ;
			assign fp32_dot_out_col1_o = fp32_col_1_w [31:0] ;
			assign fp32_dot_out_col2_o = fp32_col_2_w [31:0] ;
			assign fp32_flags_col1_o = fp32_col_1_flag_w [3:0] ;
			assign fp32_flags_col2_o = fp32_col_2_flag_w [3:0] ;

			tennm_dsp_prime		tennm_dsp_prime_component (
						 .clk (clk),
						 .ena (1'b1),
						 .acc_en (acc_en_i),
						 .zero_en (zero_en_i),
						 .load_bb_one (load_en_i),
						 .load_bb_two (1'b0),
						 .load_buf_sel (1'b0),
						 .shared_exponent (shared_exponent_i),
						 .clr ({rst,rst}),

						 .data_in({16'b0,data_i}/*data_in[10],data_in[9],data_in[8],data_in[7],data_in[6],data_in[5],data_in[4],data_in[3],data_in[2],data_in[1]}*/),

						 .cascade_data_in ({fp32_cascade_in_col2_i,fp32_cascade_in_col1_i}),
						 .cascade_data_out ({cascade_data_out_col_2_w,cascade_data_out_col_1_w}),
						 .result_l({fp32_col_2_w[4:0],fp32_col_1_w[31:0]}),
						 .result_h({fp32_col_2_flag_w[3:0],fp32_col_1_flag_w[3:0],fp32_col_2_w[31:5]}));

			defparam
		    	tennm_dsp_prime_component.dsp_mode = "tensor_fp",

		    	tennm_dsp_prime_component.dsp_side_feed_ctrl = "data_feed_in",

		    	tennm_dsp_prime_component.dsp_chain_tensor = CHAIN_MODE,

		    	tennm_dsp_prime_component.dsp_fp32_sub_en = "float_sub_disabled";
		end
    endgenerate

    
endmodule
