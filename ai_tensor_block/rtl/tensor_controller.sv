module tensor_controller (
	input logic clk,
	input logic rst_n,
	input logic [7:0] data_in [0:9],
	input logic shared_exp,
	input logic loadBuf_1,
	input logic loadBuf_2

	output logic acc_en,
	output logic zero_en,
	output logic load_bb_one,
	output logic load_bb_two,	
);

typedef enum logic [2:0] {
	LB1  = 3'b001,
	LB2  = 3'b010,
	DOT  = 3'b100
} AITensorControlState_t state, state_next;

// State Register
always_ff @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		state <= LB1;
	end else begin
		state <= state_next;
	end
end

// Next State Logic
always_comb begin
	case(state)
		LB1: begin
			if(cycle_count == 1'b1) begin
				load_bb_one = 1'b0;
				load_bb_one = 1'b1;
			end else begin
				load_bb_one = loadBuf_1;
			end
		end
		
		LB2: begin
		end

		DOT: begin
		end
end

// Output logic

endmodule
