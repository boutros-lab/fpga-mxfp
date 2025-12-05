module tensor_all_ports_tb();
timeunit 1ns;
timeprecision 1ps;

parameter CLK_PERIOD = 10ns;

logic clk;
logic load_bb_one;
logic load_bb_two;
logic load_buf_sel;
logic acc_en;
logic zero_en;

logic [7:0] data_in [1:10];
logic [7:0] shared_exp;

logic [31:0] fp32_col_1;
logic [31:0] fp32_col_2;
logic [3:0] fp32_col_1_flag;
logic [3:0] fp32_col_2_flag;

logic clr;
logic ena;
logic [31:0] cascade_data_in_col_1;
logic [31:0] cascade_data_out_col_1;
logic [31:0] cascade_data_in_col_2;
logic [31:0] cascade_data_out_col_2;

initial begin
	clk = 0;
	forever #(CLK_PERIOD / 2) clk = ~clk;
end

initial begin
	clr = 1;
	ena = 0;
	cascade_data_in_col_1 = '0;
	cascade_data_in_col_2 = '0;
	load_bb_one = 0;
	load_bb_two = 0;
	zero_en = 1;
	acc_en = 1;
	load_buf_sel = 0;
/*	
	data_in[1] = 8'h01; 
	data_in[2] = 8'h01;
	data_in[3] = 8'h01;
	data_in[4] = 8'h01;
	data_in[5] = 8'h01;
	data_in[6] = 8'h01;
	data_in[7] = 8'h01;
	data_in[8] = 8'h01;
	data_in[9] = 8'h01;
	data_in[10] = 8'h01;
	shared_exp = 8'h01;
*/	
	#(0.5*CLK_PERIOD);
	// Cycle 1
	clr = 0;
	load_bb_one = 0;
	load_bb_two = 0;
	zero_en = 1;
	acc_en = 1;
	load_buf_sel = 0;
	#(1*CLK_PERIOD);
	ena = 1;
	load_bb_one = 1;
	load_bb_two = 0;
	zero_en = 1;
	acc_en = 1;
	load_buf_sel = 0;
	#(1*CLK_PERIOD);
	// Cycle 2
	data_in[1] = 8'h01; 
	data_in[2] = 8'h01;
	data_in[3] = 8'h01;
	data_in[4] = 8'h01;
	data_in[5] = 8'h01;
	data_in[6] = 8'h01;
	data_in[7] = 8'h01;
	data_in[8] = 8'h01;
	data_in[9] = 8'h01;
	data_in[10] = 8'h01;
	shared_exp = 8'h01;
	#(1*CLK_PERIOD);
	// Cycle 3
	load_bb_one = 0;
	load_bb_two = 1;
	data_in[1]  = 8'h02; 
	data_in[2]  = 8'h02;
	data_in[3]  = 8'h02;
	data_in[4]  = 8'h02;
	data_in[5]  = 8'h02;
	data_in[6]  = 8'h02;
	data_in[7]  = 8'h02;
	data_in[8]  = 8'h02;
	data_in[9]  = 8'h02;
	data_in[10] = 8'h02;
	shared_exp  = 8'h01;
	//#(1*CLK_PERIOD);
	//zero_en = 1;
	//acc_en = 0;
	//load_buf_sel = 0;
	#(1*CLK_PERIOD);
	//Cycle 4
	data_in[1] = 8'h01; 
	data_in[2] = 8'h01;
	data_in[3] = 8'h01;
	data_in[4] = 8'h01;
	data_in[5] = 8'h01;
	data_in[6] = 8'h01;
	data_in[7] = 8'h01;
	data_in[8] = 8'h01;
	data_in[9] = 8'h01;
	data_in[10] = 8'h01;
	shared_exp = 8'h01;
	#(1*CLK_PERIOD);
	//Cycle 5
	load_bb_two = 0;
	data_in[1]  = 8'h04; 
	data_in[2]  = 8'h04;
	data_in[3]  = 8'h04;
	data_in[4]  = 8'h04;
	data_in[5]  = 8'h04;
	data_in[6]  = 8'h04;
	data_in[7]  = 8'h04;
	data_in[8]  = 8'h04;
	data_in[9]  = 8'h04;
	data_in[10] = 8'h04;
	shared_exp  = 8'h01;
	#(1*CLK_PERIOD);
	load_bb_one = 0;
	load_bb_two = 0;
	zero_en = 1;
	acc_en = 1;
	load_buf_sel = 0;

	data_in[1]  = 8'h01; 
	data_in[2]  = 8'h02;
	data_in[3]  = 8'h03;
	data_in[4]  = 8'h04;
	data_in[5]  = 8'h05;
	data_in[6]  = 8'h06;
	data_in[7]  = 8'h07;
	data_in[8]  = 8'h08;
	data_in[9]  = 8'h09;
	data_in[10] = 8'h0a;
	shared_exp  = 8'h01;

	#(10*CLK_PERIOD);
	load_buf_sel = 1;
	#(10*CLK_PERIOD);

	$stop();
end


ai_tensor_slice_all_ports dut (
		.clk                  (clk),                  //   input,   width = 1,                  clk.clk
		.clr0                   (clr),                   //   input,   width = 1,                   clr0.clr
		.clr1                   (clr),                   //   input,   width = 1,                   clr1.clr
		.ena                    (ena),                    //   input,   width = 1,                    ena.ena
		.acc_en               (acc_en),               //   input,   width = 1,               acc_en.acc_en
		.zero_en              (zero_en),              //   input,   width = 1,              zero_en.zero_en
		.load_bb_one          (load_bb_one),          //   input,   width = 1,          load_bb_one.load_bb_one
		.load_bb_two          (load_bb_two),          //   input,   width = 1,          load_bb_two.load_bb_two
		.load_buf_sel         (load_buf_sel),         //   input,   width = 1,         load_buf_sel.load_buf_sel
		.data_in_1            (data_in[1]),            //   input,   width = 8,            data_in_1.data_in
		.data_in_2            (data_in[2]),            //   input,   width = 8,            data_in_2.data_in
		.data_in_3            (data_in[3]),            //   input,   width = 8,            data_in_3.data_in
		.data_in_4            (data_in[4]),            //   input,   width = 8,            data_in_4.data_in
		.data_in_5            (data_in[5]),            //   input,   width = 8,            data_in_5.data_in
		.data_in_6            (data_in[6]),            //   input,   width = 8,            data_in_6.data_in
		.data_in_7            (data_in[7]),            //   input,   width = 8,            data_in_7.data_in
		.data_in_8            (data_in[8]),            //   input,   width = 8,            data_in_8.data_in
		.data_in_9            (data_in[9]),            //   input,   width = 8,            data_in_9.data_in
		.data_in_10           (data_in[10]),           //   input,   width = 8,           data_in_10.data_in
		.shared_exponent_data (shared_exp), //   input,   width = 8, shared_exponent_data.shared_exponent
		.cascade_data_in_col_1  (cascade_data_in_col_1),  //   input,  width = 32,  cascade_data_in_col_1.cascade_data_in
		.cascade_data_out_col_1 (cascade_data_out_col_1), //  output,  width = 32, cascade_data_out_col_1.cascade_data_out
		.cascade_data_in_col_2  (cascade_data_in_col_2),  //   input,  width = 32,  cascade_data_in_col_2.cascade_data_in
		.cascade_data_out_col_2 (cascade_data_out_col_2), //  output,  width = 32, cascade_data_out_col_2.cascade_data_out
		.fp32_col_1           (fp32_col_1),           //  output,  width = 32,           fp32_col_1.result
		.fp32_col_2           (fp32_col_2),           //  output,  width = 32,           fp32_col_2.result
		.fp32_col_1_flag      (fp32_col_1_flag),      //  output,   width = 4,      fp32_col_1_flag.result
		.fp32_col_2_flag      (fp32_col_2_flag)       //  output,   width = 4,      fp32_col_2_flag.result
	);
endmodule
