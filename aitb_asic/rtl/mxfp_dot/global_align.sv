/*
* Align inputs to specified width
*/

import pkg_aitb::*;

module global_align #(
	parameter NUM_INPUTS   = MXFP8_ELEMENTS,
	parameter INPUT_WIDTH  = 1 + 2 * (MXFP8_MAX_MAN + 1),
	parameter OUTPUT_WIDTH = 44,
	parameter EXP_SIZE     = MXFP8_MAX_EXP,

	parameter MAX_SHIFT  = OUTPUT_WIDTH - INPUT_WIDTH,
	parameter SHIFT_BITS = $clog2(MAX_SHIFT)
)(
	input logic signed [INPUT_WIDTH-1:0] i_elements  [NUM_INPUTS],
	input logic        [EXP_SIZE-1:0]    i_exponents [NUM_INPUTS],

	input logic [OUTPUT_WIDTH-1:0] o_elements  [NUM_INPUTS],
	input logic [EXP_SIZE-1:0]     o_residual_exponent
);

logic [EXP_SIZE-1:0]   max_exp, min_exp, max_diff;
logic [SHIFT_BITS-1:0] exp_diff  [NUM_INPUTS];
logic [SHIFT_BITS-1:0] shift_amt [NUM_INPUTS];

always_comb begin
	max_exp = i_exponents[0];
	min_exp = i_exponents[0];

	for (int i = 1; i < NUM_INPUTS; i++) begin
		max_exp = max_exp > i_exponents[i] ? max_exp 
						   : i_exponents[i];
		min_exp = min_exp < i_exponents[i] ? min_exp 
						   : i_exponents[i];
	end
// A 5 B 2
// Want to shift A by 3 B by 0, so minus min
// Residual exponent is min
//
// This works when max_diff < MAX_SHIFT
// After that, shift by MAX_SHIFT, residual is max_exp - MAX_SHIFT
//
// 3 numbers, Target 20, input 5, E25, E15, E5
// 15 5 -5         exp - (max_exp - MAX_SHIFT)
//
// Residual exponent capped to MAX_SHIFT
	for (int i = 0; i < NUM_INPUTS; i++) begin
		exp_diff[i] = i_exponents[i] - min_exp;
	end

	for (int i = 0; i < NUM_INPUTS; i++) begin
		shift_amt[i] = exp_diff[i];
	end
end

assign max_diff = max_exp - min_exp;
// If max_diff > MAX_SHIFT, need to cap at MAX_SHIFT, and need to shift
// everything relative to max_shift
// max_Exp needs to be MAX_SHIFT

endmodule
