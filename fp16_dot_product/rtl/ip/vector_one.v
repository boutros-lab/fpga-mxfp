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


// (C) 2001-2022 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module  vector_one  (

           clk,

           clr0,

           clr1,

           ena,

           fp16_mult_bot_a,

           fp16_mult_bot_b,

           fp16_mult_top_a,

           fp16_mult_top_b,

           fp32_adder_a,

           fp32_chainin,

           fp32_chainout,

           fp32_result);

            input  clk;
            input  clr0;
            input  clr1;
            input [2:0] ena;
            input [15:0] fp16_mult_bot_a;
            input [15:0] fp16_mult_bot_b;
            input [15:0] fp16_mult_top_a;
            input [15:0] fp16_mult_top_b;
            input [31:0] fp32_adder_a;
            input [31:0] fp32_chainin;
            output [31:0] fp32_chainout;
            output [31:0] fp32_result;
            wire [31:0] sub_wire0;
            wire [31:0] sub_wire1;
            wire [31:0] fp32_chainout = sub_wire0[31:0];    
            wire [31:0] fp32_result = sub_wire1[31:0];    

            tennm_fp_mac        tennm_fp_mac_component (
                                        .clk (clk),
                                        .clr ({clr1,clr0}),
                                        .ena (ena),
                                        .fp16_mult_bot_a (fp16_mult_bot_a),
                                        .fp16_mult_bot_b (fp16_mult_bot_b),
                                        .fp16_mult_top_a (fp16_mult_top_a),
                                        .fp16_mult_top_b (fp16_mult_top_b),
                                        .fp32_adder_a (fp32_adder_a),
                                        .fp32_chainin (fp32_chainin),
                                        .fp32_chainout (sub_wire0),
                                        .fp32_result (sub_wire1));

            defparam
                    tennm_fp_mac_component.operation_mode = "fp16_vector1",
                    tennm_fp_mac_component.fp16_mode = "extended",
                    tennm_fp_mac_component.fp16_input_width = 16,
                    tennm_fp_mac_component.use_chainin = "true",
                    tennm_fp_mac_component.fp32_adder_subtract = "false",
                    tennm_fp_mac_component.fp16_adder_subtract = "false",
                    tennm_fp_mac_component.clear_type = "sclr",
                    tennm_fp_mac_component.accumulate_clken = "no_reg",
                    tennm_fp_mac_component.accum_adder_clken = "no_reg",
                    tennm_fp_mac_component.adder_input_clken = "0",
                    tennm_fp_mac_component.adder_pl_clken = "0",
                    tennm_fp_mac_component.fp16_mult_input_clken = "0",
                    tennm_fp_mac_component.fp32_adder_a_clken = "0",
                    tennm_fp_mac_component.fp32_adder_b_clken = "no_reg",
                    tennm_fp_mac_component.fp32_mult_a_clken = "no_reg",
                    tennm_fp_mac_component.fp32_mult_b_clken = "no_reg",
                    tennm_fp_mac_component.fp32_adder_a_chainin_pl_clken = "0",
                    tennm_fp_mac_component.fp32_adder_a_chainin_2nd_pl_clken = "0",
                    tennm_fp_mac_component.output_clken = "0",
                    tennm_fp_mac_component.accum_pipeline_clken = "no_reg",
                    tennm_fp_mac_component.mult_pipeline_clken = "0",
                    tennm_fp_mac_component.accum_2nd_pipeline_clken = "no_reg",
                    tennm_fp_mac_component.mult_2nd_pipeline_clken = "0";
endmodule




module  vector_one_no_chainin  (

           clk,

           clr0,

           clr1,

           ena,

           fp16_mult_bot_a,

           fp16_mult_bot_b,

           fp16_mult_top_a,

           fp16_mult_top_b,

           fp32_adder_a,

           fp32_chainout,

           fp32_result);

            input  clk;
            input  clr0;
            input  clr1;
            input [2:0] ena;
            input [15:0] fp16_mult_bot_a;
            input [15:0] fp16_mult_bot_b;
            input [15:0] fp16_mult_top_a;
            input [15:0] fp16_mult_top_b;
            input [31:0] fp32_adder_a;
            output [31:0] fp32_chainout;
            output [31:0] fp32_result;
            wire [31:0] sub_wire0;
            wire [31:0] sub_wire1;
            wire [31:0] fp32_chainout = sub_wire0[31:0];    
            wire [31:0] fp32_result = sub_wire1[31:0];    

            tennm_fp_mac        tennm_fp_mac_component (
                                        .clk (clk),
                                        .clr ({clr1,clr0}),
                                        .ena (ena),
                                        .fp16_mult_bot_a (fp16_mult_bot_a),
                                        .fp16_mult_bot_b (fp16_mult_bot_b),
                                        .fp16_mult_top_a (fp16_mult_top_a),
                                        .fp16_mult_top_b (fp16_mult_top_b),
                                        .fp32_adder_a (fp32_adder_a),
                                        .fp32_chainout (sub_wire0),
                                        .fp32_result (sub_wire1));

            defparam
                    tennm_fp_mac_component.operation_mode = "fp16_vector1",
                    tennm_fp_mac_component.fp16_mode = "extended",
                    tennm_fp_mac_component.fp16_input_width = 16,
                    tennm_fp_mac_component.use_chainin = "false",
                    tennm_fp_mac_component.fp32_adder_subtract = "false",
                    tennm_fp_mac_component.fp16_adder_subtract = "false",
                    tennm_fp_mac_component.clear_type = "sclr",
                    tennm_fp_mac_component.accumulate_clken = "no_reg",
                    tennm_fp_mac_component.accum_adder_clken = "no_reg",
                    tennm_fp_mac_component.adder_input_clken = "0",
                    tennm_fp_mac_component.adder_pl_clken = "0",
                    tennm_fp_mac_component.fp16_mult_input_clken = "0",
                    tennm_fp_mac_component.fp32_adder_a_clken = "0",
                    tennm_fp_mac_component.fp32_adder_b_clken = "no_reg",
                    tennm_fp_mac_component.fp32_mult_a_clken = "no_reg",
                    tennm_fp_mac_component.fp32_mult_b_clken = "no_reg",
                    tennm_fp_mac_component.fp32_adder_a_chainin_pl_clken = "0",
                    tennm_fp_mac_component.fp32_adder_a_chainin_2nd_pl_clken = "0",
                    tennm_fp_mac_component.output_clken = "0",
                    tennm_fp_mac_component.accum_pipeline_clken = "no_reg",
                    tennm_fp_mac_component.mult_pipeline_clken = "0",
                    tennm_fp_mac_component.accum_2nd_pipeline_clken = "no_reg",
                    tennm_fp_mac_component.mult_2nd_pipeline_clken = "0";
endmodule
