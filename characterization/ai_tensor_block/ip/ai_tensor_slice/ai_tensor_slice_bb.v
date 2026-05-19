module ai_tensor_slice (
		input  wire        clk,                  //                  clk.clk,             Input data bus to the DOT product
		input  wire        acc_en,               //               acc_en.acc_en,          Assert this signal to enable the accumulator features. De-assert this signal to disable the accumulator feature.
		input  wire        zero_en,              //              zero_en.zero_en,         Assert this signal to disable the input to the CPA adder. When this signal is de-asserted, the CPA adder gets input data from either the accumulator or the input from a cascaded DSP prime block
		input  wire        load_bb_one,          //          load_bb_one.load_bb_one,     One bit port used to select which set of registers to be preloaded
		input  wire        load_bb_two,          //          load_bb_two.load_bb_two,     One bit port used to select which set of registers to be preloaded
		input  wire        load_buf_sel,         //         load_buf_sel.load_buf_sel,    Used to switch the set of ping pong registers for computation
		input  wire [7:0]  data_in_1,            //            data_in_1.data_in,         Input data bus to the DOT product
		input  wire [7:0]  data_in_2,            //            data_in_2.data_in,         Input data bus to the DOT product
		input  wire [7:0]  data_in_3,            //            data_in_3.data_in,         Input data bus to the DOT product
		input  wire [7:0]  data_in_4,            //            data_in_4.data_in,         Input data bus to the DOT product
		input  wire [7:0]  data_in_5,            //            data_in_5.data_in,         Input data bus to the DOT product
		input  wire [7:0]  data_in_6,            //            data_in_6.data_in,         Input data bus to the DOT product
		input  wire [7:0]  data_in_7,            //            data_in_7.data_in,         Input data bus to the DOT product
		input  wire [7:0]  data_in_8,            //            data_in_8.data_in,         Input data bus to the DOT product
		input  wire [7:0]  data_in_9,            //            data_in_9.data_in,         Input data bus to the DOT product
		input  wire [7:0]  data_in_10,           //           data_in_10.data_in,         Input data bus to the DOT product
		input  wire [7:0]  shared_exponent_data, // shared_exponent_data.shared_exponent, 8-bit port shared_exponent_data to ping-pong buffers by either (1) data input feed or (2) side input feed methods
		output wire [31:0] fp32_col_1,           //           fp32_col_1.result,          Output data bus in 32-bit floating-point format
		output wire [31:0] fp32_col_2,           //           fp32_col_2.result,          Output data bus in 32-bit floating-point format
		output wire [3:0]  fp32_col_1_flag,      //      fp32_col_1_flag.result,          Output flag
		output wire [3:0]  fp32_col_2_flag       //      fp32_col_2_flag.result,          Output flag
	);
endmodule

