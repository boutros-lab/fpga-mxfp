module sum_of_two (
		input  wire [15:0] fp16_mult_top_a, // fp16_mult_top_a.fp16_mult_top_a, Data input that supplies value to one of the FP16 top multiplier operands.
		input  wire [15:0] fp16_mult_top_b, // fp16_mult_top_b.fp16_mult_top_b, Data input that supplies value to one of the FP16 top multiplier operands.
		input  wire [15:0] fp16_mult_bot_a, // fp16_mult_bot_a.fp16_mult_bot_a, Data input that supplies value to one of the FP16 bottom multiplier operands.
		input  wire [15:0] fp16_mult_bot_b, // fp16_mult_bot_b.fp16_mult_bot_b, Data input that supplies value to one of the FP16 bottom multiplier operands.
		input  wire [31:0] fp32_chainin,    //    fp32_chainin.fp32_chainin,    Active-high clear signal for certain dedicated groups of registers. The clear signal can be either synchronous or asynchronous clearData input chain ports that receive data from the previous FP DSP block.
		input  wire        clr0,            //            clr0.reset,           CLEAR input to all the registers. Can be an asynchronous or synchronous CLEAR signal.
		input  wire        clr1,            //            clr1.reset,           CLEAR input to all the registers. Can be an asynchronous or synchronous CLEAR signal.
		input  wire        clk,             //             clk.clk,             Clock port that supplies clock signals to the enabled registers according to the register parameters setting. All registers in the DSP atom are positive edge-triggered.
		input  wire [2:0]  ena,             //             ena.ena,             Clock enable signal that pairs with the clock signal and allows a clock signal to be gated.  Each register will have the same clock enable settings as the clock parameter.
		output wire [31:0] fp32_result      //     fp32_result.fp32_result,     The final floating point operation result of the FP DSP atom in single-precision FP32 format. The output uses unfused multiply-add rounding using round to nearest even (RNE).
	);
endmodule

