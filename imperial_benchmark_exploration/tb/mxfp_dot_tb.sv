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
    localparam output_stages = `OUTPUT_STAGES;

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

        $readmemh("../data/fixed_result.hex", fixed_result);

        $display("=====================================");
        $display("  Tests: %0d", `TESTS);
	$display("  Sample Input Vector:");
	
	$write("    ");

	for (int i = 0; i < k; i = i + 1) begin
        	$write("%0x ", vector_a[0][i]);
	end

	$display();

	$display("  Sample Fixed Point Result:");
	$display("    %0x", fixed_result[0]);

        $display("=====================================");
    end

    // DUT
    logic signed [bit_width-1:0] i_op0 [k];
    logic signed [bit_width-1:0] i_op1 [k];
    logic signed [out_width-1:0] p0_dp_out;

    dot_fp_staged #(
        .exp_width(exp_width),
        .man_width(man_width),
        .k(k),
	.input_stages(input_stages),
	.output_stages(output_stages)
    ) u_dot (
	.clk(clk),
	.rst(~rst),
        .i_vec_a(i_op0),
        .i_vec_b(i_op1),
        .o_dp_q(p0_dp_out)
    );

    initial begin
	#10

	$display("Starting Tests");
	$display("Width Exp:     %d", exp_width);
        $display("Width Man:     %d", man_width);
        $display("K:             %d", k);
        $display("Input Stages:  %d", input_stages);
        $display("Output Stages: %d", output_stages);
        $display("=====================================");

	for (int i = 0; i < `TESTS; i = i + 1) begin
	    i_op0 = vector_a[i];
	    i_op1 = vector_b[i];

	    for (int j = 0; j < (input_stages + output_stages + 1); j++) begin
                #10;
	    end

	    if (p0_dp_out != fixed_result[i]) begin
		$display("!!!!!TEST FAILED!!!!!");
		$display("TEST: %0x", i);
		$display("DUT: %0x", p0_dp_out);
		$display("REF: %0x", fixed_result[i]);
		$finish();
	    end
	end

        $finish();
    end
endmodule
