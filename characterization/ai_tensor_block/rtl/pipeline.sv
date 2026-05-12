module pipeline #(
    parameter int W = 16,
    parameter int STAGES = 1
) (
	input  logic              clk,
	input  logic              rst,
	input  logic [W-1:0]      pipe_in,
	output logic [W-1:0]      pipe_out
);

    // Array of registers for the pipeline stages
	logic [W-1:0] stage_reg [0:STAGES-1]; 

    genvar i;
    generate
		if (STAGES == 0) begin
			assign pipe_out = pipe_in;
		end else if (STAGES == 1) begin
            // Single stage pipeline
            always_ff @(posedge clk or posedge rst) begin
                if (rst == 1'b1)
                    stage_reg[0] <= '0;
                else
                    stage_reg[0] <= pipe_in;
            end
			// Output from last pipeline register
			assign pipe_out = stage_reg[STAGES-1];
        end else begin
            // Multi-stage pipeline
            for (i = 0; i < STAGES; i = i + 1) begin : pipeline_stages
                always_ff @(posedge clk /*or posedge rst*/) begin
                    if (rst)
                        stage_reg[i] <= '0;
                    else if (i == 0)
                        stage_reg[i] <= pipe_in;
                    else
                        stage_reg[i] <= stage_reg[i-1];
                end
            end
				// Output from last pipeline register
				assign pipe_out = stage_reg[STAGES-1];
        end
    endgenerate


endmodule


