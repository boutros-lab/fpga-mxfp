/*
* Simple recursive reduction tree for power of 2 inputs
*/

module pow2_reduction #(
	parameter INPUTS      = 8,
	parameter INPUT_WIDTH = 8,

	parameter OUTPUT_WIDTH = INPUT_WIDTH + $clog2(INPUTS)
)(
	input logic signed [INPUT_WIDTH-1:0] i_op [INPUTS],
	output logic signed [OUTPUT_WIDTH-1:0] o_sum
);

localparam LEVELS = $clog2(INPUTS);

genvar i = 0;

generate
	if (INPUTS > 2) begin
		logic signed [INPUT_WIDTH:0] sums [INPUTS >> 1];
	
		for (i = 0; i < (INPUTS >> 1); i++) begin
			assign sums[i] = $signed(i_op[i << 1]) + $signed(i_op[(i << 1) + 1]);
		end
	
		pow2_reduction #(
			.INPUTS(INPUTS>>1),
			.INPUT_WIDTH(INPUT_WIDTH+1),
			.OUTPUT_WIDTH(OUTPUT_WIDTH)
		) u_pow2_reduction (
			.i_op(sums),
			.o_sum(o_sum)
		);
	end else begin
		assign o_sum = $signed(i_op[0]) + $signed(i_op[1]);
	end
endgenerate

endmodule
