	ai_tensor_slice_all_ports u0 (
		.clk                    (_connected_to_clk_),                    //   input,   width = 1,                    clk.clk
		.clr0                   (_connected_to_clr0_),                   //   input,   width = 1,                   clr0.clr
		.clr1                   (_connected_to_clr1_),                   //   input,   width = 1,                   clr1.clr
		.ena                    (_connected_to_ena_),                    //   input,   width = 1,                    ena.ena
		.acc_en                 (_connected_to_acc_en_),                 //   input,   width = 1,                 acc_en.acc_en
		.zero_en                (_connected_to_zero_en_),                //   input,   width = 1,                zero_en.zero_en
		.load_bb_one            (_connected_to_load_bb_one_),            //   input,   width = 1,            load_bb_one.load_bb_one
		.load_bb_two            (_connected_to_load_bb_two_),            //   input,   width = 1,            load_bb_two.load_bb_two
		.load_buf_sel           (_connected_to_load_buf_sel_),           //   input,   width = 1,           load_buf_sel.load_buf_sel
		.data_in_1              (_connected_to_data_in_1_),              //   input,   width = 8,              data_in_1.data_in
		.data_in_2              (_connected_to_data_in_2_),              //   input,   width = 8,              data_in_2.data_in
		.data_in_3              (_connected_to_data_in_3_),              //   input,   width = 8,              data_in_3.data_in
		.data_in_4              (_connected_to_data_in_4_),              //   input,   width = 8,              data_in_4.data_in
		.data_in_5              (_connected_to_data_in_5_),              //   input,   width = 8,              data_in_5.data_in
		.data_in_6              (_connected_to_data_in_6_),              //   input,   width = 8,              data_in_6.data_in
		.data_in_7              (_connected_to_data_in_7_),              //   input,   width = 8,              data_in_7.data_in
		.data_in_8              (_connected_to_data_in_8_),              //   input,   width = 8,              data_in_8.data_in
		.data_in_9              (_connected_to_data_in_9_),              //   input,   width = 8,              data_in_9.data_in
		.data_in_10             (_connected_to_data_in_10_),             //   input,   width = 8,             data_in_10.data_in
		.shared_exponent_data   (_connected_to_shared_exponent_data_),   //   input,   width = 8,   shared_exponent_data.shared_exponent
		.cascade_data_in_col_1  (_connected_to_cascade_data_in_col_1_),  //   input,  width = 32,  cascade_data_in_col_1.cascade_data_in
		.cascade_data_out_col_1 (_connected_to_cascade_data_out_col_1_), //  output,  width = 32, cascade_data_out_col_1.cascade_data_out
		.cascade_data_in_col_2  (_connected_to_cascade_data_in_col_2_),  //   input,  width = 32,  cascade_data_in_col_2.cascade_data_in
		.cascade_data_out_col_2 (_connected_to_cascade_data_out_col_2_), //  output,  width = 32, cascade_data_out_col_2.cascade_data_out
		.fp32_col_1             (_connected_to_fp32_col_1_),             //  output,  width = 32,             fp32_col_1.result
		.fp32_col_2             (_connected_to_fp32_col_2_),             //  output,  width = 32,             fp32_col_2.result
		.fp32_col_1_flag        (_connected_to_fp32_col_1_flag_),        //  output,   width = 4,        fp32_col_1_flag.result
		.fp32_col_2_flag        (_connected_to_fp32_col_2_flag_)         //  output,   width = 4,        fp32_col_2_flag.result
	);

