`timescale 1ns / 1ps

module mxfp_aitb_wrapper_tb();

localparam CLK_PERIOD = 2;   // Clock period in ns
localparam NUM_LOADS = 10;    // Number of times AITB is loaded with new pair of vectors
localparam REUSE_FACTOR = 10; // Number of vector operands multiplied by the loaded vectors in the AITB

// DUT signals
logic clk;
logic rst;
logic i_load_en;
logic i_valid;
logic signed [7:0] i_data [0:9];
logic [79:0] i_data_flat;
logic [7:0]  i_sh_exp;
logic [31:0] o_result0;
logic [31:0] o_result1;
logic [31:0] o_ref_result0;
logic [31:0] o_ref_result1;
logic o_valid;
logic o_valid_golden;

// Flatten input
always_comb begin
	for (int i = 0; i < 10; i++) begin
		i_data_flat[i*8+:8] = i_data[i];
	end
end

// DUT instantiation
naive_mxfp_aitb_wrapper dut (
	.clk(clk),
	.rst(rst),
	.i_load_en(i_load_en),
	.i_valid(i_valid),
	.i_data(i_data_flat),
	.i_sh_exp(i_sh_exp),
	.o_result0(o_result0),
	.o_result1(o_result1),
	.o_valid(o_valid)
);

altera_fp_aitb reference (
	.clk(clk),
	.rst(rst),
	.load_en(i_load_en),
	.acc_en(1'b0),
	.zero_en(1'b1),
	.valid_in(i_valid),
	.data_in(i_data),
	.shared_exponent(i_sh_exp),
	.fp32_col_1(o_ref_result0),
	.fp32_col_2(o_ref_result1),
	.valid_out(o_valid_golden)
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
		load0_sh_exp[load_id] = $urandom/*_range(100, 80)*/;
		load1_sh_exp[load_id] = $urandom/*_range(100, 80)*/;
	end
	// Generate streamed in vectors
	for (reuse_id = 0; reuse_id < REUSE_FACTOR; reuse_id = reuse_id + 1) begin
		for (load_id = 0; load_id < NUM_LOADS; load_id = load_id + 1) begin
			for (element_id = 0; element_id < 10; element_id = element_id + 1) begin
				input_data[load_id][reuse_id][element_id] = $random;
			end
			input_sh_exp[load_id][reuse_id] = $urandom/*_range(20, 10)*/;
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
			
			golden_result0[reuse_id + (REUSE_FACTOR*load_id)] = (golden_result0[reuse_id + (REUSE_FACTOR*load_id)]) * 
				shortreal'(2.0 ** (int'(load0_sh_exp[load_id])-127 + int'(input_sh_exp[load_id][reuse_id])-127));
			golden_result1[reuse_id + (REUSE_FACTOR*load_id)] = (golden_result1[reuse_id + (REUSE_FACTOR*load_id)]) * 
				shortreal'(2.0 ** (int'(load1_sh_exp[load_id])-127 + int'(input_sh_exp[load_id][reuse_id])-127));
			
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
logic [31:0] golden_result0_bits;
logic [31:0] golden_result1_bits;

initial begin
	out_id = 0;
	mistakes = 0;
	while (out_id < NUM_LOADS * REUSE_FACTOR) begin
		
		if (o_valid && o_valid_golden) begin
			golden_result0_bits = $shortrealtobits(golden_result0[out_id]);
			golden_result1_bits = $shortrealtobits(golden_result1[out_id]);

			$display("result0   = %1b||%8b||%23b = %f", o_result0[31], o_result0[30:23], o_result0[22:0], $bitstoshortreal(o_result0));
			$display("ref_res0  = %1b||%8b||%23b = %f", o_ref_result0[31], o_ref_result0[30:23], o_ref_result0[22:0], $bitstoshortreal(o_ref_result0));
			$display("o_golden0 = %1b||%8b||%23b = %f", golden_result0_bits[31], golden_result0_bits[30:23], golden_result0_bits[22:0], golden_result0[out_id]);
			$display("-----------------------------------------------------");
			$display("result1   = %1b||%8b||%23b = %f", o_result1[31], o_result1[30:23], o_result1[22:0], $bitstoshortreal(o_result1));
			$display("ref_res1  = %1b||%8b||%23b = %f", o_ref_result1[31], o_ref_result1[30:23], o_ref_result1[22:0], $bitstoshortreal(o_ref_result1));
			$display("o_golden1 = %1b||%8b||%23b = %f", golden_result1_bits[31], golden_result1_bits[30:23], golden_result1_bits[22:0], golden_result1[out_id]);

			/*$display("FLAT: %x", dut.aitb.data_in);
			$display("Fixed C1: %x", dut.aitb.fixed_c1[0]);
			$display("Fixed C2: %x", dut.aitb.fixed_c2[0]);
			$display("Fixed DI: %x", dut.aitb.fixed_data_in[0]);
			$display("Fixed C1 P: %x", dut.aitb.fixed_c1_pipe[0]);
			$display("Fixed C2 P: %x", dut.aitb.fixed_c2_pipe[0]);
			$display("Fixed DI P: %x", dut.aitb.fixed_data_in_pipe[0]);
			$display("Dot Out C1: %x", dut.aitb.dot_out_col1);
			$display("Dot Out C2: %x", dut.aitb.dot_out_col2);
			$display("Fx2Fp C1: %x", dut.aitb.fix2float_out_col1);
			$display("Fx2Fp C2: %x", dut.aitb.fix2float_out_col2);
			$display("Exponent Correction: %x", dut.aitb.exponent_correction);
			$display("Fixed: %x", dut.aitb.adder_out_col1);*/

			if ((o_result0 !== o_ref_result0) || (o_result1 !== o_ref_result1)) begin
				if((o_result0 !== golden_result0_bits) || (o_result1 !== golden_result1_bits)) begin
					mistakes = mistakes + 1;
					$display("FULL MISMATCH!!");
				end else begin
					$display("Numerical Match");	
				end
			end else begin
				$display("Full Match!!");
			end

			$display("=====================================================");
			out_id = out_id + 1;
		end
		#(CLK_PERIOD);
	end
	if (mistakes > 0) $display("Simulation FAILED!");
	else $display("Simulation PASSED!");
	$stop;
end
endmodule
