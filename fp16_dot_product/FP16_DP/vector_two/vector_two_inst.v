	vector_two u0 (
		.fp32_chainin    (_connected_to_fp32_chainin_),    //   input,  width = 32,    fp32_chainin.fp32_chainin
		.fp16_mult_top_a (_connected_to_fp16_mult_top_a_), //   input,  width = 16, fp16_mult_top_a.fp16_mult_top_a
		.fp16_mult_top_b (_connected_to_fp16_mult_top_b_), //   input,  width = 16, fp16_mult_top_b.fp16_mult_top_b
		.fp16_mult_bot_a (_connected_to_fp16_mult_bot_a_), //   input,  width = 16, fp16_mult_bot_a.fp16_mult_bot_a
		.fp16_mult_bot_b (_connected_to_fp16_mult_bot_b_), //   input,  width = 16, fp16_mult_bot_b.fp16_mult_bot_b
		.fp32_adder_a    (_connected_to_fp32_adder_a_),    //   input,  width = 32,    fp32_adder_a.fp32_adder_a
		.clr0            (_connected_to_clr0_),            //   input,   width = 1,            clr0.reset
		.clr1            (_connected_to_clr1_),            //   input,   width = 1,            clr1.reset
		.clk             (_connected_to_clk_),             //   input,   width = 1,             clk.clk
		.ena             (_connected_to_ena_),             //   input,   width = 3,             ena.ena
		.fp32_result     (_connected_to_fp32_result_),     //  output,  width = 32,     fp32_result.fp32_result
		.fp32_chainout   (_connected_to_fp32_chainout_)    //  output,  width = 32,   fp32_chainout.fp32_chainout
	);

