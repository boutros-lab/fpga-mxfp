`define M 3
`define E 2
`timescale 1ns / 1ps
module mxfp_dot_tb();

localparam CLK_PERIOD = 2;   // Clock period in ns
localparam NUM_LOADS = 1;    // Number of times AITB is loaded with new pair of vectors
localparam REUSE_FACTOR = 10; // Number of vector operands multiplied by the loaded vectors in the AITB

localparam BIAS = 1;

localparam M = `M;
localparam E = `E;

// DUT signals
logic clk;
logic rst;
logic i_load_en;
logic i_valid;
logic [M+E:0] i_data [0:31];
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
mxfp_dot #(
	.M(M),
	.E(E),
	.E_SHARED(8),
	.FP_BIAS(1), // MX-FP BIAS
	.SH_BIAS(127), // Shared EXP bias
	.DOT_LEN(32),
	.PIPE(0)
) dut (
	.clk(clk),
	.rst(rst),
	.load_en(i_load_en),
	.valid_in(i_valid),
	.mx_data_in(i_data),
	.shared_exponent(i_sh_exp),
	.fp32_dot_out_col1(o_result0),
	.fp32_dot_out_col2(o_result1),
	.valid_out(o_valid)
	//.fp32_flags(result_flags)
);

// Clock generation
initial begin
	clk = 1'b0;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

// TB signals
logic     [M+E:0] load0_data     [0:NUM_LOADS-1][0:31];
logic     [M+E:0] load1_data     [0:NUM_LOADS-1][0:31];
logic     [7:0]   load0_sh_exp   [0:NUM_LOADS-1];
logic     [7:0]   load1_sh_exp   [0:NUM_LOADS-1];
logic     [M+E:0] input_data     [0:NUM_LOADS-1][0:REUSE_FACTOR-1][0:31];
logic     [7:0]   input_sh_exp   [0:NUM_LOADS-1][0:REUSE_FACTOR-1];
shortreal         golden_result0 [0:NUM_LOADS*REUSE_FACTOR-1];
shortreal         golden_result1 [0:NUM_LOADS*REUSE_FACTOR-1];

// Input stimuli generation
integer element_id, load_id, reuse_id, res_id;
initial begin
	// Generate loaded vectors
	for (load_id = 0; load_id < NUM_LOADS; load_id = load_id + 1) begin
		for (element_id = 0; element_id < 32; element_id = element_id + 1) begin
			load0_data[load_id][element_id] = $random;
			load1_data[load_id][element_id] = $random;
		end
		load0_sh_exp[load_id] = $urandom/*_range(100, 80)*/;
		load1_sh_exp[load_id] = $urandom/*_range(100, 80)*/;
	end
	// Generate streamed in vectors
	for (reuse_id = 0; reuse_id < REUSE_FACTOR; reuse_id = reuse_id + 1) begin
		for (load_id = 0; load_id < NUM_LOADS; load_id = load_id + 1) begin
			for (element_id = 0; element_id < 32; element_id = element_id + 1) begin
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
			for (element_id = 0; element_id < 32; element_id = element_id + 1) begin
				golden_result0[reuse_id + (REUSE_FACTOR*load_id)] = golden_result0[reuse_id + (REUSE_FACTOR*load_id)] + 
					to_fp32(int'(load0_data[load_id][element_id])) * to_fp32(int'(input_data[load_id][reuse_id][element_id]));
				golden_result1[reuse_id + (REUSE_FACTOR*load_id)] = golden_result1[reuse_id + (REUSE_FACTOR*load_id)] + 
					to_fp32(int'(load1_data[load_id][element_id])) * to_fp32(int'(input_data[load_id][reuse_id][element_id]));
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
	for (i = 0; i < 32; i = i + 1) begin
		i_data[i] = '0;
	end
	i_sh_exp = '0;
	#(5*CLK_PERIOD);
	rst = 1'b0;
	i_load_en = 1'b1;
	#(CLK_PERIOD);
	for (j = 0; j < NUM_LOADS; j = j + 1) begin
		for (i = 0; i < 32; i = i + 1) begin
			i_data[i] = load1_data[j][i]; 
		end
		i_sh_exp = load1_sh_exp[j];
		#(CLK_PERIOD);
		i_load_en = 1'b0;
		for (i = 0; i < 32; i = i + 1) begin
			i_data[i] = load0_data[j][i]; 
		end
		i_sh_exp = load0_sh_exp[j];
		#(CLK_PERIOD);
		for (k = 0; k < REUSE_FACTOR; k = k + 1) begin
			i_valid = 1'b1;
			for (i = 0; i < 32; i = i + 1) begin
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
///*
initial begin
	out_id = 0;
	mistakes = 0;
	while (out_id < NUM_LOADS * REUSE_FACTOR) begin
		
		if (o_valid) begin
			golden_result0_bits = $shortrealtobits(golden_result0[out_id]);
			golden_result1_bits = $shortrealtobits(golden_result1[out_id]);

			$display("result0   = %1b||%8b||%23b = %f", o_result0[31], o_result0[30:23], o_result0[22:0], $bitstoshortreal(o_result0));
//			$display("ref_res0  = %1b||%8b||%23b = %f", o_ref_result0[31], o_ref_result0[30:23], o_ref_result0[22:0], $bitstoshortreal(o_ref_result0));
			$display("o_golden0 = %1b||%8b||%23b = %f", golden_result0_bits[31], golden_result0_bits[30:23], golden_result0_bits[22:0], golden_result0[out_id]);
			$display("-----------------------------------------------------");
			$display("result1   = %1b||%8b||%23b = %f", o_result1[31], o_result1[30:23], o_result1[22:0], $bitstoshortreal(o_result1));
//			$display("ref_res1  = %1b||%8b||%23b = %f", o_ref_result1[31], o_ref_result1[30:23], o_ref_result1[22:0], $bitstoshortreal(o_ref_result1));
			$display("o_golden1 = %1b||%8b||%23b = %f", golden_result1_bits[31], golden_result1_bits[30:23], golden_result1_bits[22:0], golden_result1[out_id]);
			if ((o_result0 != golden_result0_bits) || (o_result1 != o_ref_result1)) begin
				mistakes = mistakes + 1;
				$display("FULL MISMATCH!!");
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
//*/
/*
initial begin
	out_id = 0;
	mistakes = 0;
	while (out_id < NUM_LOADS * REUSE_FACTOR) begin
		if (o_valid) begin
			if ((o_result0 != $shortrealtobits(golden_result0[out_id])) || (o_result1 != $shortrealtobits(golden_result1[out_id]))) begin
				mistakes = mistakes + 1;
				$display("Results are NOT matching: result0=%b, golden0=%b, result1=%b, golden1=%b", 
					o_result0, $shortrealtobits(golden_result0[out_id]), o_result1, $shortrealtobits(golden_result1[out_id]));
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

*/
function automatic shortreal to_fp32 (int fp_bits);

	localparam int M = `M;
	localparam int E = `E;

	int BIAS = (1 << (E-1)) - 1;
	//logic [M+E:0] fp_bits = bits[M+E:0];

	shortreal sign = fp_bits[M+E] ? -1.0 : 1.0;
	int M_bits = fp_bits[M-1:0];
	int E_bits = fp_bits[M+E-1:M];



	if (M_bits == 0 && E_bits == 0) begin // ZERO
		to_fp32 = sign * 0.0;
	end
	else if (E_bits == 0) begin //CURSED SUBNORMALS
		to_fp32 = sign * (2.0 ** (1 - BIAS)) * (M_bits / shortreal'(1 << M));
	end
	else begin // NORMALs
		to_fp32 = sign * (2.0 ** (E_bits - BIAS)) * (1.0 + M_bits / shortreal'(1 << M));
	end

endfunction
endmodule
