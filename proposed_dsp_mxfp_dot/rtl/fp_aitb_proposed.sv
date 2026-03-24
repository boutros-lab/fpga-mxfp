import pkg_aitb::*;

module fp_aitb_proposed #(
    parameter mxfp_mode_e MODE = MXFP4,
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
        end
        // else TODO trick Quartus hehe
    endgenerate
    
endmodule