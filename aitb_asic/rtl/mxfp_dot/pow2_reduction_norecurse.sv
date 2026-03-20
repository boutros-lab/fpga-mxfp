/*
* Non-recursive reduction tree for power of 2 inputs
* Adapted from MX-for-FPGA
*/

module pow2_reduction_norecurse #(
	parameter INPUTS      = 8,
	parameter INPUT_WIDTH = 8,

	parameter OUTPUT_WIDTH = INPUT_WIDTH + $clog2(INPUTS)
)(
	input logic signed [INPUT_WIDTH-1:0] i_op [INPUTS],
	output logic signed [OUTPUT_WIDTH-1:0] o_sum
);

localparam LEVELS = $clog2(INPUTS);

genvar i, j;

generate
	// Generate reduction tree
	for (i = 0; i < LEVELS; i++) begin : reduction
		logic signed [INPUT_WIDTH+i-1:0] op0   [INPUTS >> (1 + i)];
		logic signed [INPUT_WIDTH+i-1:0] op1   [INPUTS >> (1 + i)];
		logic signed [INPUT_WIDTH+i:0]   sums  [INPUTS >> (1 + i)];

		// Declare adders
		for(j = 0; j < (INPUTS >> (1 + i)); j++) begin
			assign sums[j] = op0[j] + op1[j];
		end

		// Connections to previous layers
		if(i != 0) begin
			for(j = 0; j < (INPUTS >> (1 + i)); j++) begin
				assign op0[j] = reduction[i - 1].sums[j << 1];
				assign op1[j] = reduction[i - 1].sums[(j << 1) + 1];
			end
		end else begin
			for(j = 0; j < (INPUTS >> (1 + i)); j++) begin
				assign op0[j] = i_op[j << 1];
				assign op1[j] = i_op[(j << 1) + 1];
			end
		end
	end
endgenerate

assign o_sum = reduction[LEVELS-1].sums[0];

endmodule
