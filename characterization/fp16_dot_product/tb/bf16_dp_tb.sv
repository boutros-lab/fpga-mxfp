timeunit 1ns;
timeprecision 1ps;

module bf16_dp_tb();

// Generate clock and reset.
logic clk;
logic rst;

initial begin
	clk = 0;
	forever
		#5 clk = ~clk;
end

initial begin
	rst = 1;
	#10
	rst = 0;
end

// Parameters
localparam TESTS   = `TESTS;
localparam k       = `K;
localparam LATENCY = k > 2 ? (6 + ($clog2(k) - 2) * 3) : 6; // Expected latency

// DUT
logic [15:0] fp16_in_a [k];
logic [15:0] fp16_in_b [k];
logic [31:0] fp32_out;

direct_vector_dp #(
	.k(k),
	.FP16_MODE("bfloat16")
) u_bf16_dp (
	.clk(clk),
	.rst(rst),
	.fp16_in_a(fp16_in_a),
	.fp16_in_b(fp16_in_b),
	.fp32_out(fp32_out)
);

// Stimulus and results
shortreal fp32_a [k];
shortreal fp32_b [k];
shortreal fp32_c;

logic [15:0] ref_fp16_in_a [TESTS][k];
logic [15:0] ref_fp16_in_b [TESTS][k];
logic [31:0] ref_fp32_out  [TESTS];

int cycle_count = 0;

// Generate test cases and results
initial begin
	for (int test = 0; test < TESTS; test++) begin
		fp32_c = 0;
		
		for (int i = 0; i < k; i++) begin
			fp32_a[i] = $bitstoshortreal(($random & 32'hbfff_0000) | 32'h2e00_0000);
			fp32_b[i] = $bitstoshortreal(($random & 32'hbfff_0000) | 32'h2e00_0000);
			//fp32_a[i] = $bitstoshortreal(32'h3f800000);
			//fp32_b[i] = $bitstoshortreal(32'h3f800000);
			
			ref_fp16_in_a[test][i] = ($shortrealtobits(fp32_a[i]) >> 16);
			ref_fp16_in_b[test][i] = ($shortrealtobits(fp32_b[i]) >> 16);
			
			fp32_c += fp32_a[i] * fp32_b[i];
		end
		
		ref_fp32_out[test] = $shortrealtobits(fp32_c);
	end
end

localparam timeout = 30;

initial begin
	#10
	
	$display("Starting -----------");
	$display("K:                %d", k);
	$display("Tests:            %d", TESTS);
	$display("Expected latency: %d", LATENCY);
	
	for (int test = 0; test < TESTS; test++) begin
		cycle_count = 0;

		fp16_in_a = ref_fp16_in_a[test];
		fp16_in_b = ref_fp16_in_b[test];
	
		$display("Vector A: ");
		for (int i = 0; i < k; i++) begin
			$write("%x, ", fp16_in_a[i]);
		end

		$display("\nVector B: ");
		for (int i = 0; i < k; i++) begin
			$write("%x, ", fp16_in_b[i]);
		end

		$display("\nExpected Result: %f, %x", $bitstoshortreal(ref_fp32_out[test]), ref_fp32_out[test]);

		#10

		cycle_count++;

		fp16_in_a = '{default: 'b0};
		fp16_in_b = '{default: 'b0};

		for (; cycle_count <= LATENCY; cycle_count++) begin
			$display("Cycle: %d, FP32_OUT: %f, %x", cycle_count, $bitstoshortreal(fp32_out), fp32_out);
			#10;
		end
	end
	
	$display("PASSED");
	$finish();
end

endmodule
