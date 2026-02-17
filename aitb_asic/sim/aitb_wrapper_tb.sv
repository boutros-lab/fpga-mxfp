`timescale 1ns / 1ps

module aitb_wrapper_tb();

localparam CLK_PERIOD = 2;   // Clock period in ns
localparam NUM_LOADS = 2;    // Number of times AITB is loaded with new pair of vectors
localparam REUSE_FACTOR = 5; // Number of vector operands multiplied by the loaded vectors in the AITB

// DUT signals
logic clk;
logic rst;
logic i_load_en;
logic i_valid;
logic signed [7:0] i_data [0:9];
logic [7:0] i_sh_exp;
logic [31:0] o_result0;
logic [31:0] o_result1;
logic o_valid;

// DUT instantiation
aitb_wrapper dut (
	.clk(clk),
	.rst(rst),
	.i_load_en(i_load_en),
	.i_valid(i_valid),
	.i_data(i_data),
	.i_sh_exp(i_sh_exp),
	.o_result0(o_result0),
	.o_result1(o_result1),
	.o_valid(o_valid)
);

// Clock generation
initial begin
	clk = 1'b0;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

// TB signals
logic signed [7:0] load0_data     [0:NUM_LOADS-1][0:9];
logic signed [7:0] load1_data     [0:NUM_LOADS-1][0:9];
logic        [7:0] load0_sh_exp   [0:NUM_LOADS-1];
logic        [7:0] load1_sh_exp   [0:NUM_LOADS-1];
logic signed [7:0] input_data     [0:NUM_LOADS-1][0:REUSE_FACTOR-1][0:9];
logic        [7:0] input_sh_exp   [0:NUM_LOADS-1][0:REUSE_FACTOR-1];
shortreal          golden_result0 [0:NUM_LOADS*REUSE_FACTOR-1];
shortreal          golden_result1 [0:NUM_LOADS*REUSE_FACTOR-1];

// Input stimuli generation
integer element_id, load_id, reuse_id, res_id;
initial begin
	// Generate loaded vectors
	for (load_id = 0; load_id < NUM_LOADS; load_id = load_id + 1) begin
		for (element_id = 0; element_id < 10; element_id = element_id + 1) begin
			load0_data[load_id][element_id] = $random;
			load1_data[load_id][element_id] = $random;
		end
		load0_sh_exp[load_id] = 8'd127; //$random;
		load1_sh_exp[load_id] = 8'd127; //$random;
	end
	// Generate streamed in vectors
	for (reuse_id = 0; reuse_id < REUSE_FACTOR; reuse_id = reuse_id + 1) begin
		for (load_id = 0; load_id < NUM_LOADS; load_id = load_id + 1) begin
			for (element_id = 0; element_id < 10; element_id = element_id + 1) begin
				input_data[load_id][reuse_id][element_id] = $random;
			end
			input_sh_exp[load_id][reuse_id] = 8'd127; //$random;
		end
	end
	// Calculate golden results
	for (load_id = 0; load_id < NUM_LOADS; load_id = load_id + 1) begin
		for (reuse_id = 0; reuse_id < REUSE_FACTOR; reuse_id = reuse_id + 1) begin
			golden_result0[reuse_id + (REUSE_FACTOR*load_id)] = 0.0;
			golden_result1[reuse_id + (REUSE_FACTOR*load_id)] = 0.0;
			for (element_id = 0; element_id < 10; element_id = element_id + 1) begin
				golden_result0[reuse_id + (REUSE_FACTOR*load_id)] = golden_result0[reuse_id + (REUSE_FACTOR*load_id)] + 
					shortreal'(load0_data[load_id][element_id]) * shortreal'(input_data[load_id][reuse_id][element_id]);
				golden_result1[reuse_id + (REUSE_FACTOR*load_id)] = golden_result1[reuse_id + (REUSE_FACTOR*load_id)] + 
					shortreal'(load1_data[load_id][element_id]) * shortreal'(input_data[load_id][reuse_id][element_id]);
			end
			/*
			golden_result0[reuse_id + (REUSE_FACTOR*load_id)] = golden_result0[reuse_id + (REUSE_FACTOR*load_id)] * 
				(2.0 ** (int'(load0_sh_exp[load_id])-127 + int'(input_sh_exp[load_id][reuse_id])-127));
			golden_result1[reuse_id + (REUSE_FACTOR*load_id)] = golden_result1[reuse_id + (REUSE_FACTOR*load_id)] * 
				(2.0 ** (int'(load1_sh_exp[load_id])-127 + int'(input_sh_exp[load_id][reuse_id])-127));
			*/
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
	i_sh_exp = '0;
	#(5*CLK_PERIOD);
	rst = 1'b0;
	i_load_en = 1'b1;
	#(CLK_PERIOD);
	for (j = 0; j < NUM_LOADS; j = j + 1) begin
		for (i = 0; i < 10; i = i + 1) begin
			i_data[i] = load1_data[j][i]; 
		end
		i_sh_exp = load1_sh_exp[j];
		#(CLK_PERIOD);
		i_load_en = 1'b0;
		for (i = 0; i < 10; i = i + 1) begin
			i_data[i] = load0_data[j][i]; 
		end
		i_sh_exp = load0_sh_exp[j];
		#(CLK_PERIOD);
		for (k = 0; k < REUSE_FACTOR; k = k + 1) begin
			i_valid = 1'b1;
			for (i = 0; i < 10; i = i + 1) begin
				i_data[i] = input_data[j][k][i]; 
			end
			i_sh_exp = input_sh_exp[j][k];
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
			if ((o_result0 != $shortrealtobits(golden_result0[out_id])) || (o_result1 != $shortrealtobits(golden_result1[out_id]))) begin
				mistakes = mistakes + 1;
				$display("Results are NOT matching: result0=%f, golden0=%f, result1=%f, golden1=%f", 
					$bitstoshortreal(o_result0), golden_result0[out_id], $bitstoshortreal(o_result1), golden_result1[out_id]);
			end else begin
				$display("Results are matching: result0=%f, golden0=%f, result1=%f, golden1=%f", 
					$bitstoshortreal(o_result0), golden_result0[out_id], $bitstoshortreal(o_result1), golden_result1[out_id]);
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
