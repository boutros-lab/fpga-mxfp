/*
* MXFP AITB TB, compares with generated data, only loads in a single vector,
* streams in TEST_LENGTH vectors
*/

`timescale 1ns / 1ps

import pkg_aitb::*;

module mxfp_aitb_tb();

localparam CLK_PERIOD  = 2;   // Clock period in ns
localparam TEST_LENGTH = `TESTS;

// DUT signals
logic clk;
logic rst;
logic i_load_en;
logic i_valid;
logic [79:0] i_data_flat;
logic [7:0]  i_sh_exp;
logic [31:0] o_result0;
logic [31:0] o_result1;
logic o_valid;

mxfp_mode_e i_mxfp_mode;

// Clock generation
initial begin
	clk = 1'b0;

	forever #(CLK_PERIOD/2) clk = ~clk;
end

// Functions
function real geterror(input real dut_fp32, input real ref_fp32);
	real error;
	
	error = ((ref_fp32 - dut_fp32) / ref_fp32) * 100;
	
	if (error < 0.0) begin
		error = error * -1.0;
	end
	
	return error;
endfunction

let max(a, b) = (a > b) ? a : b;

// Get generated data
//    Parameters
localparam exp_width = `EXP_WIDTH;
localparam man_width = `MAN_WIDTH;
localparam exp_bias  = 2 ** (exp_width - 1) - 1;
localparam k         = `K;
localparam bit_width = 1 + exp_width + man_width;

logic [bit_width-1:0] vector_a[TEST_LENGTH][k];
logic [bit_width-1:0] vector_b[TEST_LENGTH][k]; // Common for all vectors

logic [7:0] shared_exp_a[TEST_LENGTH];
logic [7:0] shared_exp_b[TEST_LENGTH];

logic [31:0] fp32_result[TEST_LENGTH];

// Fixed point for debug
localparam prd_width = 2 * ((1<<exp_width) + man_width);
localparam out_width = prd_width + $clog2(k);

logic [out_width-1:0] fixed_result[TEST_LENGTH];

integer i, j;

initial begin
	// NOTE:
	// Data should be generated with --common_vec
	// e.g. make data E=2 M=1 K=16 DATA_OPTS="--common_vec" 
	
	$readmemh("data/vector_a.hex", vector_a);
	$readmemh("data/vector_b.hex", vector_b);
	
	$readmemh("data/shared_exp_a.hex", shared_exp_a);
	$readmemh("data/shared_exp_b.hex", shared_exp_b);
	
	$readmemh("data/fixed_result.hex", fixed_result);
	
	$readmemh("data/fp32_result.hex", fp32_result);

	// If fixed point input, get two's complement
	if (exp_width == 0) begin
		$display("CONVERTING INPUT TO TWO's COMPLEMENT");

		for (i = 0; i < TEST_LENGTH; i++) begin
			for (j = 0; j < k; j++) begin
				vector_a[i][j] = vector_a[i][j][bit_width-1] ? -$signed({1'b0, vector_a[i][j][6:0]})
									     : $signed({1'b0, vector_a[i][j][6:0]});

				vector_b[i][j] = vector_b[i][j][bit_width-1] ? -$signed({1'b0, vector_b[i][j][6:0]})
									     : $signed({1'b0, vector_b[i][j][6:0]});
			end
		end
	end
	
	$display("=====================================");
	$display("  Tests: %0d", TEST_LENGTH);
	$display("  Sample Input Vector:");
	
	$write("    ");
	
	for (i = 0; i < k; i = i + 1) begin
		$write("%0x ", vector_a[0][i]);
	end
	
	$display();
	
	$display("  Sample FP32 Result:");
	$display("    %0x", fp32_result[0]);
	
	$display("=====================================");

	$display("Starting Tests");
	$display("Width Exp:     %d", exp_width);
        $display("Width Man:     %d", man_width);
        $display("K:             %d", k);
        $display("=====================================");
end

// DUT instantiation
`DUT dut (
	.clk(clk),
	.rst(rst),
	.i_load_en(i_load_en),
	.i_valid(i_valid),
	.i_mxfp_mode(i_mxfp_mode),
	.i_data(i_data_flat),
	.i_sh_exp(i_sh_exp),
	.o_result0(o_result0),
	.o_result1(o_result1),
	.o_valid(o_valid)
);

initial begin
	// Set MXFP Mode
	i_mxfp_mode = (exp_width == 2 && man_width == 1) ? MXFP4
		      : (exp_width == 2 && man_width == 3) ? MXFP6_23
		      : (exp_width == 3 && man_width == 2) ? MXFP6_32
		      : (exp_width == 4 && man_width == 3) ? MXFP8_43
		      : (exp_width == 5 && man_width == 2) ? MXFP8_52 
		      : FIXED;

	// Flush pipeline
	rst = 1'b1;
	i_load_en = 1'b0;
	i_valid = 1'b0;

	i_data_flat = 80'd0;

	i_sh_exp = '0;

	#(5*CLK_PERIOD);

	rst = 1'b0;
	i_load_en = 1'b1;

	#(CLK_PERIOD);

	// Begin Loading
	// Load Col 1
	i_data_flat = 80'b0;

	for (i = 0; i < k; i++) begin
		i_data_flat[i*bit_width+:bit_width] = vector_b[0][i];
	end

	i_sh_exp = shared_exp_b[0];

	#(CLK_PERIOD);

	// Load Col 2 (this isn't changing data, vector_b will be loaded into
	// both columns, leaving it here to be explicit)
	i_data_flat = 80'b0;

	for (i = 0; i < k; i++) begin
		i_data_flat[i*bit_width+:bit_width] = vector_b[0][i];
	end

	i_sh_exp = shared_exp_b[0];

	// Stop loading
	i_load_en = 1'b0;

	#(CLK_PERIOD);

	// Stream in data
	for (i = 0; i < TEST_LENGTH; i++) begin
		i_valid = 1'b1;

		i_data_flat = 80'b0;

		for (j = 0; j < k; j++) begin
			i_data_flat[j*bit_width+:bit_width] = vector_a[i][j];
		end

		i_sh_exp = shared_exp_a[i];

		#(CLK_PERIOD);
	end

	// Complete
	i_valid = 1'b0;
end

integer out_id, mistakes, inexact;

real dut_fp32_0 = 0.0;
real dut_fp32_1 = 0.0;
real ref_fp32   = 0.0;
real error0     = 0.0;
real error1     = 0.0;

real max_error = 0.0;
real tolerance = 5.0;

initial begin
	out_id    = 0;
	mistakes  = 0;
	inexact   = 0;

	while (out_id < TEST_LENGTH) begin
		if (o_valid) begin
			dut_fp32_0 = $bitstoshortreal(o_result0);
			dut_fp32_1 = $bitstoshortreal(o_result1);
			ref_fp32   = $bitstoshortreal(fp32_result[out_id]);

			$display("result0   = %1b||%8b||%23b = %f", o_result0[31], o_result0[30:23], o_result0[22:0], dut_fp32_0);
			$display("result1   = %1b||%8b||%23b = %f", o_result1[31], o_result1[30:23], o_result1[22:0], dut_fp32_1);
			$display("golden    = %1b||%8b||%23b = %f", fp32_result[out_id][31], fp32_result[out_id][30:23], fp32_result[out_id][22:0], ref_fp32);

			if ((o_result0 !== fp32_result[out_id]) || (o_result1 !== fp32_result[out_id])) begin
				error0    = geterror(dut_fp32_0, ref_fp32);
				error1    = geterror(dut_fp32_1, ref_fp32);
				max_error = max(max(error0, error1), max_error);

				if(error0 > tolerance || error1 > tolerance) begin
					mistakes = mistakes + 1;
					$display("FULL MISMATCH!!");
					$display("Error 0: %f", error0);
					$display("Error 1: %f", error1);
				end else begin
					inexact = inexact + 1;
					$display("Inexact");
					$display("Error 0: %f", error0);
					$display("Error 1: %f", error1);
				end
			end else begin
				$display("Full Match!!");
			end

			$display("=====================================================");
			out_id = out_id + 1;
		end

		#(CLK_PERIOD);
	end

	if (mistakes > 0) begin
		$display("Simulation FAILED!");
		$display("%0d/%0d Tests Failed", mistakes, TEST_LENGTH);
		$display("%0d/%0d Inexact", inexact, TEST_LENGTH);
		$display("Max Error 0: %f%%, Tolerance: %f", max_error, tolerance);
	end else begin
		$display("Simulation PASSED!");
		$display("%0d/%0d Inexact", inexact, TEST_LENGTH);
		$display("Max Error 0: %f%%, Tolerance: %f", max_error, tolerance);
	end

	$stop;
end
endmodule
