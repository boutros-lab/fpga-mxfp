/*
* Non-recursive reduction tree for power of 2 inputs
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
	for (i = 0; i < LEVELS; i++) begin : tree_add
		// Declare adders.
		logic signed [INPUT_WIDTH+i-1:0] p0_add0 [INPUTS>>(1+i)];
		logic signed [INPUT_WIDTH+i-1:0] p0_add1 [INPUTS>>(1+i)];
		logic signed [INPUT_WIDTH+i:0]   p0_sum  [INPUTS>>(1+i)];

		for(j = 0; j < (INPUTS >> (1 + i)); j++) begin
			assign p0_sum[j] = p0_add0[j] + p0_add1[j];
		end

		// Connections to previous layers.
		if(i != 0) begin
			for(j = 0; j < (INPUTS >> (1 + i)); j++) begin
				assign p0_add0[j] = tree_add[i-1].p0_sum[2*j];
				assign p0_add1[j] = tree_add[i-1].p0_sum[2*j+1];
			end
		end else begin
			for(j = 0; j < (INPUTS >> (1 + i)); j++) begin
				assign p0_add0[j] = i_op[2*j];
				assign p0_add1[j] = i_op[2*j+1];
			end
		end
	end
endgenerate

assign o_sum = tree_add[LEVELS-1].p0_sum[0];

endmodule
