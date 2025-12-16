`define M 3
`define E 2
`timescale 1ns/1ps
module mxfp_dot_tb();

localparam M = `M;
localparam E = `E;
localparam DOT_LEN = 32;
localparam CLK_PERIOD = 2ns;

logic clk;
logic rst;
logic load_en;
logic [M+E:0] data_in1_MX [0:DOT_LEN-1];
logic [M+E:0] data_in2_MX [0:DOT_LEN-1];
logic [M+E:0] dut_data_in [0:DOT_LEN-1];
logic [7:0] shared_exp1;
logic [7:0] shared_exp2;
logic [7:0] dut_shared_exponent;
logic [31:0] result;
logic [3:0] result_flags[0:3];
logic valid_in;
logic valid_out;

shortreal data_in1_FP32 [0:DOT_LEN-1];
shortreal data_in2_FP32 [0:DOT_LEN-1];
shortreal golden_dot;

initial begin
	clk = 1'b0;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
	shared_exp1 = 127;
	shared_exp2 = 127;
	for (int i = 0; i < DOT_LEN; i++) begin
		data_in1_MX[i] = $random;
		data_in2_MX[i] = $random;
		data_in1_FP32[i] = to_fp32(int'(data_in1_MX[i]));
		data_in2_FP32[i] = to_fp32(int'(data_in2_MX[i]));
	end	
	golden_dot = dot(data_in1_FP32, data_in2_FP32, shared_exp1, shared_exp2);
end

initial begin

	rst = 1'b1;
	load_en = 0;
	valid_in = 0;
	#(5*CLK_PERIOD);
	rst = 1'b0;
	load_en = 1'b1;
	#(1*CLK_PERIOD);
	dut_data_in = data_in1_MX;
	dut_shared_exponent = shared_exp1;
	#(1*CLK_PERIOD);
	load_en = 1'b0;
	#(1*CLK_PERIOD);
	dut_data_in = data_in2_MX;
	dut_shared_exponent = shared_exp2;	
	valid_in = 1;
	/*
	#(1*CLK_PERIOD);
	dut_data_in = data_in1_MX;
	dut_shared_exponent = shared_exp1;
	#(1*CLK_PERIOD);
	dut_data_in = data_in2_MX;
	dut_shared_exponent = shared_exp2;	
	*/

	wait(valid_out == 1);
	$display("OUTPUT: %f", $bitstoshortreal(result));
	$display("EXPECT: %f", golden_dot);
	#(2.5*CLK_PERIOD);
	$display("SWITCHING VECTORS..");
	valid_in = 0;
	load_en = 1'b1;
	#(1*CLK_PERIOD);
	dut_data_in = data_in2_MX;
	dut_shared_exponent = shared_exp2;
	#(1*CLK_PERIOD);
	load_en = 1'b0;
	#(1*CLK_PERIOD);
	dut_data_in = data_in1_MX;
	dut_shared_exponent = shared_exp1;	
	valid_in = 1;
	$display("OUTPUT: %f", $bitstoshortreal(result));
	$display("EXPECT: %f", golden_dot);
	wait(valid_out == 1);
	#(2*CLK_PERIOD);

	if ($bitstoshortreal(result) == golden_dot)
		$display("PASSED");
	else
		$display("FAILED");

	$stop();

end

mxfp_dot #(
	.M(M),
	.E(E),
	.E_SHARED(8),
	.FP_BIAS(1), // MX-FP BIAS
	.SH_BIAS(127), // Shared EXP bias
	.DOT_LEN(DOT_LEN)
) dut (

	.clk(clk),
	.rst(rst),
	.load_en(load_en),
	.valid_in(valid_in),
	.mx_data_in(dut_data_in),
	.shared_exponent(dut_shared_exponent),
	.fp32_dot_out(result),
	.valid_out(valid_out),
	.fp32_flags(result_flags)

);

function automatic shortreal dot (shortreal vec1[], shortreal vec2[], byte shared_exp1, byte shared_exp2);
	int corrected_exp = shared_exp1-127+shared_exp2-127;
	dot = 0.0;

	foreach (vec1[i])
		dot += vec1[i] * vec2[i]; 
	//dot = shortreal'(dot * (2.0 ** (corrected_exp))); // 127 is exponent bias from OCP-MX Standard
endfunction

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
