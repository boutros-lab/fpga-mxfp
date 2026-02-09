module mxfp_dot_tb();
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

    // Parameters and functions.
    localparam exp_width = `EXP_WIDTH;
    localparam man_width = `MAN_WIDTH;
    localparam exp_bias  = 2 ** (exp_width - 1) - 1;
    localparam k         = `K;
    localparam bit_width = 1 + exp_width + man_width;
    localparam fi_width  = man_width + 2;
    localparam prd_width = 2 * ((1<<exp_width) + man_width);
    localparam out_width = prd_width + $clog2(k);
    
    localparam input_stages  = `INPUT_STAGES;
    localparam dot_fp_stages = `DOT_FP_STAGES;
    localparam pipeline_add  = `PIPELINE_ADD;
    localparam fp32_stages   = `FP32_STAGES;
    localparam output_stages = `OUTPUT_STAGES;

    localparam tree_add_reg_stages = pipeline_add ? $clog2(k) - 1 : 0;

    localparam fix2fp_stages = `PIPELINE_FLOPOCO == 1 ? 
            					      ((exp_width == 5 && man_width == 2) ? 14 :
            		                               (exp_width == 4 && man_width == 3) ? 11 :
            		                               (exp_width == 3 && man_width == 2) ?  6 :
            		                               (exp_width == 2 && man_width == 3) ?  6 :
            		                               (exp_width == 2 && man_width == 1) ?  5 :
        		                               0) : 0;

    logic signed [bit_width-1:0] vector_a[`TESTS][k];
    logic signed [bit_width-1:0] vector_b[`TESTS][k];

    logic [7:0] shared_exp_a[`TESTS];
    logic [7:0] shared_exp_b[`TESTS];

    logic signed [out_width-1:0] fixed_result[`TESTS];
    logic          [31:0] fp32_result[`TESTS];

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
    logic signed [bit_width-1:0] i_op0 [k];
    logic signed [bit_width-1:0] i_op1 [k];
    logic signed [33:0] o_fp32;

    dot_fp_fp32 #(
        .exp_width(exp_width),
        .man_width(man_width),
        .k(k),
	.input_stages(input_stages),
	.dot_fp_stages(dot_fp_stages),
	.pipeline_add(pipeline_add),
	.fp32_stages(fp32_stages),
	.output_stages(output_stages)
    ) u_dot (
	.clk(clk),
	.rst(~rst),
        .i_vec_a(i_op0),
        .i_vec_b(i_op1),
        .o_fp32_q(o_fp32)
    );

    int mismatch_count = 0;

    initial begin
	#10

	$display("Starting Tests");
	$display("Width Exp:     %d", exp_width);
        $display("Width Man:     %d", man_width);
        $display("K:             %d", k);
        $display("Mult Width:    %d", prd_width);
        $display("Output Width:  %d", out_width);
        $display("Input Stages:  %d", input_stages);
        $display("Dot FP Stages: %d", dot_fp_stages);
        $display("Pipeline Add:  %d", pipeline_add);
        $display("Tree Stages:   %d", tree_add_reg_stages);
        $display("Pipeline Add:  %d", pipeline_add);
        $display("FP32 Stages:   %d", fp32_stages);
        $display("Fix2FP Stages: %d", fix2fp_stages);
        $display("Output Stages: %d", output_stages);
        $display("=====================================");

	for (int i = 0; i < `TESTS; i = i + 1) begin
	    i_op0 = vector_a[i];
	    i_op1 = vector_b[i];

	    for (int j = 0; j < (input_stages + dot_fp_stages + tree_add_reg_stages + fix2fp_stages + fp32_stages + output_stages); j++) begin
                #10;
	    end

	    if (o_fp32[31:0] !== fp32_result[i]) begin
		$display("!!!!!MISMATCH!!!!!");
		$display("TEST: %0x", i);
		$display("DUT Flags: %0x", o_fp32[33:32]);
		$display("DUT: %0x", o_fp32[31:0]);
		$display("REF: %0x", fp32_result[i]);

		mismatch_count = mismatch_count + 1;
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
