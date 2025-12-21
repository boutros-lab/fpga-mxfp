timeunit 1ns;
timeprecision 1ps;

module mxfp_dot_fp32_tb();
    // Generate clock and reset.
    logic clk;
    logic rst;

    initial begin
        clk = 0;
        forever
            #5 clk = ~clk;
    end

    initial begin
        rst = 0;
        #10
        rst = 1;
    end

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

    initial begin
        $readmemh("../data/vector_a.hex", vector_a);
        $readmemh("../data/vector_b.hex", vector_b);

        $readmemh("../data/shared_exp_a.hex", shared_exp_a);
        $readmemh("../data/shared_exp_b.hex", shared_exp_b);

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
    logic [bit_width-1:0] i_mxfp_vec_a [k];
    logic [bit_width-1:0] i_mxfp_vec_b [k];

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
        .o_result(o_fp32_result)
    );

    int valid_count    = 0;
    int mismatch_count = 0;

    initial begin
	#10

	$display("Starting Tests");
	$display("Width Exp:     %d", exp_width);
        $display("Width Man:     %d", man_width);
        $display("K:             %d", k);
        $display("=====================================");

	for (int i = 0; i < `TESTS; i = i + 1) begin
	    i_valid      = 1'b1;
	    i_mxfp_vec_a = vector_a[i];
	    i_mxfp_vec_b = vector_b[i];

            #10;

	    if (o_valid === 1'b1) begin
	    	if (o_fp32_result !== fp32_result[valid_count]) begin
	    	    $display("!!!!!MISMATCH!!!!!");
	    	    $display("TEST: %0x", valid_count);
	    	    $display("DUT: %0x", o_fp32_result);
	    	    $display("REF: %0x", fp32_result[valid_count]);

	    	    mismatch_count++;
	    	end

		valid_count++;
	    end
	end

	// Check remaining outputs
	while (valid_count < `TESTS) begin
	    #10;

	    if (o_valid === 1'b1) begin
	    	if (o_fp32_result !== fp32_result[valid_count]) begin
	    	    $display("!!!!!MISMATCH!!!!!");
	    	    $display("TEST: %0x", valid_count);
	    	    $display("DUT: %0x", o_fp32_result);
	    	    $display("REF: %0x", fp32_result[valid_count]);

	    	    mismatch_count++;
	    	end

		valid_count++;
	    end
	end

	if (mismatch_count != 0) begin
            $display("=====================================");
	    $display("TEST FAILED");
	    $display("Total Mismatches: %0d/%0d", mismatch_count, `TESTS);
            $display("=====================================");
         end else begin
            $display("=====================================");
	    $display("TEST PASSED");
            $display("=====================================");
         end

        $finish();
    end
endmodule
