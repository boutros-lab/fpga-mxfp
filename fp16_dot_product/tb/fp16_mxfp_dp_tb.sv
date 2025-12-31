timeunit 1ns;
timeprecision 1ps;

module fp16_mxfp_dp_tb();
    // Generate clock and reset.
    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever
            #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #10
        rst_n = 1;
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

    // Parameters
    localparam exp_width = `EXP_WIDTH;
    localparam man_width = `MAN_WIDTH;
    localparam exp_bias  = 2 ** (exp_width - 1) - 1;
    localparam k         = `K;
    localparam bit_width = 1 + exp_width + man_width;
    localparam fi_width  = man_width + 2;
    localparam prd_width = 2 * ((1<<exp_width) + man_width);
    localparam out_width = prd_width + $clog2(k);
    
    localparam input_stages  = `INPUT_STAGES;
    localparam output_stages = `OUTPUT_STAGES;

    logic [bit_width-1:0] vector_a[`TESTS][k];
    logic [bit_width-1:0] vector_b[`TESTS][k];

    logic [7:0] shared_exp_a[`TESTS];
    logic [7:0] shared_exp_b[`TESTS];

    logic [out_width-1:0] fixed_result[`TESTS];
    logic          [31:0] fp32_result[`TESTS];

    initial begin
        $readmemh("../data/vector_a.hex", vector_a);
        $readmemh("../data/vector_b.hex", vector_b);

        $readmemh("../data/shared_exp_a.hex", shared_exp_a);
        $readmemh("../data/shared_exp_b.hex", shared_exp_b);

        $readmemh("../data/fixed_result.hex", fixed_result);
        $readmemh("../data/fp32_result.hex", fp32_result);

        $display("=====================================");
        $display("  Tests: %0d", `TESTS);
	$display("  Sample Input Vector:");
	
	$write("    ");

	for (int i = 0; i < k; i = i + 1) begin
        	$write("%0x ", vector_a[0][i]);
	end

	$display();

	$display("  Sample FP32 Result:");
	$display("    %0x", fp32_result[0]);

        $display("=====================================");
    end

    // DUT
    logic [bit_width-1:0] mxfp_in_a [k];
    logic [bit_width-1:0] mxfp_in_b [k];
    logic [31:0] fp32_in;
    logic [31:0] fp32_out;

    fp16_mxfp_dp #(
        .exp_width(exp_width),
        .man_width(man_width),
        .k(k)
    ) u_dot (
	.clk(clk),
	.rst(rst),
        .mxfp_in_a(mxfp_in_a),
        .mxfp_in_b(mxfp_in_b),
	.shared_exp_in_a(8'hff),
	.shared_exp_in_b(8'hff),
        .fp32_out(fp32_out)
    );

    int mismatch_count = 0;

    real dut_fp32 = 0.0;
    real ref_fp32 = 0.0;
    real error    = 0.0;

    real max_error = 0.0;
    real tolerance = 5.0;

    initial begin
	#10

	$display("Starting Tests");
	$display("Width Exp:     %d", exp_width);
        $display("Width Man:     %d", man_width);
        $display("K:             %d", k);
        $display("Mult Width:    %d", prd_width);
        $display("Output Width:  %d", out_width);
        $display("Input Stages:  %d", input_stages);
        $display("Output Stages: %d", output_stages);
        $display("=====================================");

	for (int i = 0; i < `TESTS; i = i + 1) begin
	    mxfp_in_a = vector_a[i];
	    mxfp_in_b = vector_b[i];

	    for (int j = 0; j < 42; j++) begin
                #10;
	    end

	    /*$display("CYCLE: %0x", i);
	    $display("DUT: %0x", fp32_out);
	    for (int j = 0; j < k; j++) begin
	    	//$display("FP16 A %d: %0x", j, u_dot.fp16_in_a[j]);
	    	//$display("FP16 B %d: %0x", j, u_dot.fp16_in_b[j]);
	    end
	    for (int j = 0; j < k/2; j++) begin
	    	$display("FP32 RESULT %d: %0x", j, u_dot.u_direct_vector_dp.fp32_result[j]);
	    end
	    $display("FP32 DP OUT: %0x", u_dot.fp32_dp_out);
	    $display("FP32 DP OUT: %0f", $bitstoshortreal(u_dot.fp32_dp_out));*/

	    if (fp32_out !== fp32_result[i]) begin
		dut_fp32 = $bitstoshortreal(fp32_out);
		ref_fp32 = $bitstoshortreal(fp32_result[i]);

		error     = geterror(dut_fp32, ref_fp32);
		max_error = max(error, max_error);

		$display("!!!!!MISMATCH!!!!!");
		$display("TEST: %0x", i);
		$display("DUT: %0x", fp32_out);
		$display("REF: %0x", fp32_result[i]);
	    	$display("DUT FP32: %0f", dut_fp32);
	    	$display("REF FP32: %0f", ref_fp32);
	    	$display("ERROR:    %0f", error);

		mismatch_count = mismatch_count + 1;
	    end
	end

	/**for (int i = 0; i < 39; i = i + 1) begin
            #10;

	    $display("CYCLE: %0x", (i + `TESTS));
	    $display("DUT: %0x", fp32_out);
	    for (int j = 0; j < k; j++) begin
	    	//$display("FP16 A %d: %0x", j, u_dot.fp16_in_a[j]);
	    	//$display("FP16 B %d: %0x", j, u_dot.fp16_in_b[j]);
	    end
	    for (int j = 0; j < k/2; j++) begin
	    	$display("FP32 RESULT %d: %0x", j, u_dot.u_direct_vector_dp.fp32_result[j]);
	    end
	    $display("FP32 DP OUT: %0x", u_dot.fp32_dp_out);
	    $display("FP32 DP OUT: %0f", $bitstoshortreal(u_dot.fp32_dp_out));
	end**/

	if (mismatch_count != 0) begin
            $display("=====================================");
	    $display("TEST FAILED");
	    $display("Total Mismatches: %0d/%0d", mismatch_count, `TESTS);
	    $display("Max Error:        %0f %%", max_error);
            $display("=====================================");
         end else begin
            $display("=====================================");
	    $display("TEST PASSED");
	    $display("Max Error:        %0f %%", max_error);
            $display("=====================================");
         end

        $finish();
    end
endmodule
