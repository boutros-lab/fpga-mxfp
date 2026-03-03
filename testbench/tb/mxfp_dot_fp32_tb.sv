// FP32 TB
timeunit 1ns;
timeprecision 1ps;

module mxfp_dot_fp32_tb();
    // Generate clock and reset.
    logic clk;
    logic rst;

    int cycle_count = 0;

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

    logic [bit_width-1:0] vector_a[`TESTS][k];
    logic [bit_width-1:0] vector_b[`TESTS][k];

    logic [7:0] shared_exp_a[`TESTS];
    logic [7:0] shared_exp_b[`TESTS];

    logic [31:0] fp32_result[`TESTS];

    // Fixed point for debug
    localparam prd_width = 2 * ((1<<exp_width) + man_width);
    localparam out_width = prd_width + $clog2(k);

    logic [out_width-1:0] fixed_result[`TESTS];

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
    logic i_valid;
    logic o_valid;

    logic [bit_width-1:0] i_mxfp_vec_a [k];
    logic [bit_width-1:0] i_mxfp_vec_b [k];

    logic [7:0] i_shared_exp_a;
    logic [7:0] i_shared_exp_b;

    logic [31:0] o_fp32_result;

    `DUT #(
        .exp_width(exp_width),
        .man_width(man_width),
        .k(k)
    ) u_dot (
	.clk(clk),
	.rst(rst),
	.i_valid(i_valid),
	.o_valid(o_valid),
        .i_vec_a(i_mxfp_vec_a),
        .i_vec_b(i_mxfp_vec_b),
	.i_shared_exp_a(i_shared_exp_a),
	.i_shared_exp_b(i_shared_exp_b),
        .o_result(o_fp32_result)
    );

    int valid_count    = 0;
    int mismatch_count = 0;
    int inexact_count  = 0;

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
        $display("=====================================");

	for (int i = 0; i < `TESTS; i = i + 1) begin
	    i_valid        = 1'b1;
	    i_mxfp_vec_a   = vector_a[i];
	    i_mxfp_vec_b   = vector_b[i];
            i_shared_exp_a = shared_exp_a[i];
            i_shared_exp_b = shared_exp_b[i];

            #10;
	    
	    if (o_valid === 1'b1) begin
	    	if (o_fp32_result !== fp32_result[valid_count]) begin
		    dut_fp32 = $bitstoshortreal(o_fp32_result);
		    ref_fp32 = $bitstoshortreal(fp32_result[valid_count]);

		    error     = geterror(dut_fp32, ref_fp32);
		    max_error = max(error, max_error);

		    if (error > tolerance) begin
	    	    	$display("!!!!!MISMATCH!!!!!");
	    	    	$display("TEST: %0x", valid_count);
	    	    	$display("DUT: %0x", o_fp32_result);
	    	    	$display("REF: %0x", fp32_result[valid_count]);
	    	    	$display("DUT FP32: %0f", dut_fp32);
	    	    	$display("REF FP32: %0f", ref_fp32);
	    	    	$display("ERROR:    %0f", error);

	    	    	mismatch_count++;
		    end else begin 
	    	    	//$display("TEST: %0x", valid_count);
	    	        //$display("Relative error below provided tolerance, ignoring mismatch\n Tolerance: %0f", tolerance);

			inexact_count++;
		    end
	    	end

		valid_count++;
	    end
	end
	
	i_valid = 1'b0;

	// Check remaining outputs
	while (valid_count < `TESTS) begin
	    #10;

	    if (o_valid === 1'b1) begin
	    	if (o_fp32_result !== fp32_result[valid_count]) begin
		    dut_fp32 = $bitstoshortreal(o_fp32_result);
		    ref_fp32 = $bitstoshortreal(fp32_result[valid_count]);

		    error     = geterror(dut_fp32, ref_fp32);
		    max_error = max(error, max_error);

		    if (error > tolerance) begin
	    	    	$display("!!!!!MISMATCH!!!!!");
	    	    	$display("TEST: %0x", valid_count);
	    	        $display("DUT: %0x", o_fp32_result);
	    	        $display("REF: %0x", fp32_result[valid_count]);
	    	        $display("DUT FP32: %0f", dut_fp32);
	    	        $display("REF FP32: %0f", ref_fp32);
	    	        $display("ERROR:    %0f", error);

	    	    	mismatch_count++;
		    end else begin 
	    	    	//$display("TEST: %0x", valid_count);
	    	        //$display("Relative error below provided tolerance, ignoring mismatch\n Tolerance: %0f", tolerance);

			inexact_count++;
		    end
	    	end

		valid_count++;
	    end
	end

	if (mismatch_count != 0) begin
            $display("=====================================");
	    $display("TEST FAILED");
	    $display("Total Mismatches: %0d/%0d", mismatch_count, `TESTS);
	    $display("Total Inexact:    %0d/%0d", inexact_count, `TESTS);
	    $display("Max Error:        %0f", max_error);
            $display("=====================================");
         end else begin
            $display("=====================================");
	    $display("TEST PASSED");
	    $display("Total Inexact:    %0d/%0d", inexact_count, `TESTS);
	    $display("Max Error:        %0f %%", max_error);
            $display("=====================================");
         end

        $finish();
    end
endmodule
