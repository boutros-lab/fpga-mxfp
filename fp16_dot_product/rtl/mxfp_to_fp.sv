// Module to convert MXFP number to a larger FP format
// Assumes FP components are larger than MXFP components

module mxfp_to_fp #(
	parameter exp_bits_i = 2,
	parameter man_bits_i = 1,
	parameter exp_bits_o = 5,
	parameter man_bits_o = 10
) (
	input  logic clk,
	input  logic rst,
	input  logic [exp_bits_i + man_bits_i:0] i_mxfp,
	output logic [exp_bits_o + man_bits_o:0] o_fp
);
localparam bias_i = 2**(exp_bits_i - 1) - 1;
localparam bias_o = 2**(exp_bits_o - 1) - 1;

localparam bias_c = bias_o - bias_i;

// If exponent bits are equal, don't need special subnormal handling
localparam equal_exp = exp_bits_i == exp_bits_o;

// Input MXFP components
logic sign_i;
logic [exp_bits_i-1:0] exp_i;
logic [man_bits_i-1:0] man_i;

// Output FP components
logic sign_o;
logic [exp_bits_o-1:0] exp_o;
logic [man_bits_o-1:0] man_o;

// Subnormal handling
logic [$clog2(man_bits_i):0] leading_zero_count;
logic [man_bits_i-1:0]       man_shifted;

// Breakout MXFP components
assign {sign_i, exp_i, man_i} = i_mxfp;

generate
	if (equal_exp == 0) begin
		// Special subnormal handling required
		always_comb begin
			// Count leading zeros, always shift by at least 1
			leading_zero_count = 'b1;
		
			for (int i = man_bits_i - 1; i > 0; i--) begin
				if (man_i[i] == 1) begin
					break;
				end else begin
					leading_zero_count = leading_zero_count + 'b1;
				end
			end
		
			// Shift the mantissa so that the leading 1 is discarded
			// This is absorbed by the implied 1 of the output FP number
			man_shifted = man_i << leading_zero_count;

			if (exp_i == 0) begin
				// Subnormal number
				sign_o = sign_i;
				exp_o  = (man_i == 0) ? 'b0 : (exp_i + bias_c - leading_zero_count + 1);
				man_o  = {man_shifted, {(man_bits_o - man_bits_i){1'b0}}};
			end else begin
				// Normal nuber
				sign_o = sign_i;
				exp_o  = exp_i + bias_c;
				man_o  = {man_i, {(man_bits_o - man_bits_i){1'b0}}};
			end
		end
	end else begin
		// No special subnormal handling when source and target
		// formats have equal exponent bits
		assign sign_o = sign_i;
		assign exp_o  = exp_i;
		assign man_o  = {man_i, {(man_bits_o - man_bits_i){1'b0}}};
	end
endgenerate

// Form FP output from components
assign o_fp = {sign_o, exp_o, man_o};

endmodule
