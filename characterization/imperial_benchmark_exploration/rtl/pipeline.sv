// Paramaterized pipeline

module pipeline #(
	parameter width = 32,
	parameter depth = 1
)(
	input clk,
	input rst,
	input [width-1:0] data,
	output [width-1:0] data_q
);

generate
	if (depth > 0) begin
		logic [width-1:0] pipeline_stage [depth-1:0];

		assign data_q = pipeline_stage[depth-1];

		integer i;

		always_ff @(posedge clk) begin
			/*if (rst) begin
				for (i = 0; i < depth; i++) begin
					pipeline_stage[i] <= 'b0;
				end
			end else begin*/
				pipeline_stage[0] <= data;

				for (i = 1; i < depth; i++) begin
					pipeline_stage[i] <= pipeline_stage[i-1];
				end
			//end
		end
	end else begin
		// Handle 0 depth case
		assign data_q = data;
	end
endgenerate

endmodule
