`timescale 1ns / 1ps

module fp_aitb_tb ();

localparam CLK_PERIOD = 2;   // Clock period in ns
localparam NUM_LOADS = 1;    // Number of times AITB is loaded with new pair of vectors
localparam REUSE_FACTOR = 5; // Number of vector operands multiplied by the loaded vectors in the AITB

// DUT signals
logic clk;
logic rst;
logic i_load_en;
logic i_valid;
logic [7:0] i_data [0:9];
logic [7:0] shared_exponent;
logic [31:0] o_result0;
logic [31:0] o_result1;
logic [31:0] o_result_cascade;
logic o_valid;
logic [3:0] o_out_flags;

typedef enum logic [1:0] {CASCADE_ACCUM = 2'b00, SELF_ACCUM, NO_ACCUM} acc_mode_t;
//accmode_t accmode;
// DUT instantiation
fp_aitb dut (
	.clk(clk),
	.rst(rst),
	.acc_mode(NO_ACCUM),
	.load_en(i_load_en),
	.data_in(i_data),
	.shared_exponent(shared_exponent),
	.fp32_cascade_in('0),
	.fp32_dot_out(o_result0),
	.fp32_cascade_out(o_result_cascade),
//	.valid_out(),
	.fp32_flags(o_out_flags)
);
// Clock generation
initial begin
	clk = 1'b0;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

// TB signals
logic signed [7:0] load0_data [0:NUM_LOADS-1][0:9];
logic signed [7:0] load1_data [0:NUM_LOADS-1][0:9];
logic signed [7:0] input_data [0:NUM_LOADS-1][0:REUSE_FACTOR-1][0:9];
logic signed [31:0] golden_result0 [0:NUM_LOADS*REUSE_FACTOR-1];
logic signed [31:0] golden_result1 [0:NUM_LOADS*REUSE_FACTOR-1];

// Input stimuli generation
integer element_id, load_id, reuse_id, res_id;
initial begin
	// Generate loaded vectors
	for (load_id = 0; load_id < NUM_LOADS; load_id = load_id + 1) begin
		for (element_id = 0; element_id < 10; element_id = element_id + 1) begin
			load0_data[load_id][element_id] = $random;
			load1_data[load_id][element_id] = $random;
		end
	end
	// Generate streamed in vectors
	for (reuse_id = 0; reuse_id < REUSE_FACTOR; reuse_id = reuse_id + 1) begin
		for (load_id = 0; load_id < NUM_LOADS; load_id = load_id + 1) begin
			for (element_id = 0; element_id < 10; element_id = element_id + 1) begin
				input_data[load_id][reuse_id][element_id] = $random;
			end
		end
	end
	// Calculate golden results
	for (load_id = 0; load_id < NUM_LOADS; load_id = load_id + 1) begin
		for (reuse_id = 0; reuse_id < REUSE_FACTOR; reuse_id = reuse_id + 1) begin
			golden_result0[reuse_id + (REUSE_FACTOR*load_id)] = 'd0;
			golden_result1[reuse_id + (REUSE_FACTOR*load_id)] = 'd0;
			for (element_id = 0; element_id < 10; element_id = element_id + 1) begin
				golden_result0[reuse_id + (REUSE_FACTOR*load_id)] = golden_result0[reuse_id + (REUSE_FACTOR*load_id)] + 
					load0_data[load_id][element_id] * input_data[load_id][reuse_id][element_id];
				golden_result1[reuse_id + (REUSE_FACTOR*load_id)] = golden_result1[reuse_id + (REUSE_FACTOR*load_id)] + 
					load1_data[load_id][element_id] * input_data[load_id][reuse_id][element_id];
			end
		end
	end
end

integer i, j, k;
initial begin
	rst = 1'b1;
	i_load_en = 1'b0;
	i_valid = 1'b0;
	for (i = 0; i < 10; i = i + 1) begin
		i_data[i] = 8'd0; 
	end
	#(5*CLK_PERIOD);
	rst = 1'b0;
	i_load_en = 1'b1;
	#(CLK_PERIOD);
	for (j = 0; j < NUM_LOADS; j = j + 1) begin
		for (i = 0; i < 10; i = i + 1) begin
			i_data[i] = load1_data[j][i]; 
			shared_exponent = $random;
		end
		#(CLK_PERIOD);
		i_load_en = 1'b0;
		for (i = 0; i < 10; i = i + 1) begin
			i_data[i] = load0_data[j][i]; 
			shared_exponent = $random;
		end
		#(CLK_PERIOD);
		for (k = 0; k < REUSE_FACTOR; k = k + 1) begin
			i_valid = 1'b1;
			for (i = 0; i < 10; i = i + 1) begin
				i_data[i] = input_data[j][k][i]; 
				shared_exponent = $random;
			end
			if ((k == REUSE_FACTOR-1) && (j != NUM_LOADS-1)) i_load_en = 1'b1;
			#(CLK_PERIOD);
		end
		i_valid = 1'b0;
	end
end

integer out_id, mistakes;
initial begin
	out_id = 0;
	mistakes = 0;
	while (out_id < NUM_LOADS * REUSE_FACTOR) begin
		if (o_valid) begin
			if ((o_result0 != golden_result0[out_id]) || (o_result1 != golden_result1[out_id])) begin
				mistakes = mistakes + 1;
				$display("Results are NOT matching: result0=%d, golden0=%d, result1=%d, golden1=%d", 
					o_result0, golden_result0[out_id], o_result1, golden_result1[out_id]);
			end else begin
				$display("Results are matching: result0=%d, golden0=%d, result1=%d, golden1=%d", 
					o_result0, golden_result0[out_id], o_result1, golden_result1[out_id]);
			end
			out_id = out_id + 1;
		end
		#(CLK_PERIOD);
	end
	if (mistakes > 0) $display("Simulation FAILED!");
	else $display("Simulation PASSED!");
	$stop;
end

endmodule
