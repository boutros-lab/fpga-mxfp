module mxfp_dot_tb();
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

// Parameters and functions.
localparam exp_width = `EXP_WIDTH;
localparam man_width = `MAN_WIDTH;
localparam exp_bias  = 2 ** (exp_width - 1) - 1;
localparam k	 = `K;
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
logic	   [31:0] fp32_result[`TESTS];

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
logic i_valid, o_valid;
logic signed [bit_width-1:0] i_op0 [k];
logic signed [bit_width-1:0] i_op1 [k];
logic	 [7:0]		 i_shared_exp_a;
logic	 [7:0]		 i_shared_exp_b;
logic	 [31:0]		 o_fp32;

dot_fp_fp32_wrapper #(
	.exp_width(exp_width),
	.man_width(man_width),
	.k(k),
	
	.input_stages(input_stages),
	.dot_fp_stages(dot_fp_stages),
	.pipeline_add(pipeline_add),
	.fp32_stages(fp32_stages),
	.pipeline_fix2fp(`PIPELINE_FLOPOCO),
	.output_stages(output_stages)
) u_dot (
	.clk(clk),
	.rst(~rst),
	.i_valid(i_valid),
	.o_valid(o_valid),
	.i_vec_a(i_op0),
	.i_vec_b(i_op1),
	.i_shared_exp_a(i_shared_exp_a),
	.i_shared_exp_b(i_shared_exp_b),
	.o_result(o_fp32)
);

int mismatch_count = 0;
int valid_count    = 0;

initial begin
	#10
	
	$display("Starting Tests");
	$display("Width Exp:	 %d", exp_width);
	$display("Width Man:	 %d", man_width);
	$display("K:		 %d", k);
	$display("Mult Width:	 %d", prd_width);
	$display("Output Width:  %d", out_width);
	$display("Input Stages:  %d", input_stages);
	$display("Dot FP Stages: %d", dot_fp_stages);
	$display("Pipeline Add:  %d", pipeline_add);
	$display("Tree Stages:	 %d", tree_add_reg_stages);
	$display("Pipeline Add:  %d", pipeline_add);
	$display("FP32 Stages:	 %d", fp32_stages);
	$display("Fix2FP Stages: %d", fix2fp_stages);
	$display("Output Stages: %d", output_stages);
	$display("=====================================");
	
	for (int i = 0; i < `TESTS; i = i + 1) begin
		i_op0 = vector_a[i];
		i_op1 = vector_b[i];
		
		i_shared_exp_a = shared_exp_a[i];
		i_shared_exp_b = shared_exp_b[i];
		
		i_valid = 1'b1;
		
		#10
		
		if (o_valid == 1'b1) begin
			if (o_fp32[31:0] !== fp32_result[valid_count]) begin
				$display("!!!!!MISMATCH!!!!!");
				$display("TEST: %0x", valid_count);
				$display("DUT: %0x", o_fp32[31:0]);
				$display("REF: %0x", fp32_result[valid_count]);
				$display("REF Shared Exp A: %0x", shared_exp_a[valid_count]);
				$display("REF Shared Exp B: %0x", shared_exp_b[valid_count]);
				
				$display("Orig FP32:    %0x", u_dot.u_dot_fp_fp32.o_fp32);
				$display("Orig Exp:     %0x", u_dot.u_dot_fp_fp32.o_fp32[30:23]);
				$display("Scaled Exp:   %0x", u_dot.u_dot_fp_fp32.scaled_exponent);
				$display("Shared Sum:   %0x", u_dot.u_dot_fp_fp32.shared_exp_sum_q);
				
				mismatch_count = mismatch_count + 1;
			end else begin
				$display("=====MATCH=====");
				$display("TEST: %0x", valid_count);
				$display("DUT: %0x", o_fp32[31:0]);
				$display("REF: %0x", fp32_result[valid_count]);
			end
			
			valid_count++;
		end
	end
	
	i_valid = 1'b0;
	
	while (valid_count < `TESTS) begin
		#10
		
		if (o_valid == 1'b1) begin
			if (o_fp32[31:0] !== fp32_result[valid_count]) begin
				$display("!!!!!MISMATCH!!!!!");
				$display("TEST: %0x", valid_count);
				$display("DUT: %0x", o_fp32[31:0]);
				$display("REF: %0x", fp32_result[valid_count]);
				$display("REF Shared Exp A: %0x", shared_exp_a[valid_count]);
				$display("REF Shared Exp B: %0x", shared_exp_b[valid_count]);
				
				$display("Orig FP32:    %0x", u_dot.u_dot_fp_fp32.o_fp32);
				$display("Orig Exp:     %0x", u_dot.u_dot_fp_fp32.o_fp32[30:23]);
				$display("Scaled Exp:   %0x", u_dot.u_dot_fp_fp32.scaled_exponent);
				$display("Shared Sum:   %0x", u_dot.u_dot_fp_fp32.shared_exp_sum_q);
				
				mismatch_count = mismatch_count + 1;
			end else begin
				$display("=====MATCH=====");
				$display("TEST: %0x", valid_count);
				$display("DUT: %0x", o_fp32[31:0]);
				$display("REF: %0x", fp32_result[valid_count]);
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
		$display("Total Mismatches: %0d/%0d", mismatch_count, `TESTS);
		$display("=====================================");
	end
	
	$finish();
end
endmodule
