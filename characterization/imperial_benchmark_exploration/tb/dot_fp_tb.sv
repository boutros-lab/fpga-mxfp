module dot_fp_tb();

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

    function shortreal fptosr(input logic [bit_width-1:0] i_fp_num);

        logic [31:0] sr_bits;

        sr_bits[31]    = i_fp_num[bit_width-1];
        sr_bits[30:23] = {{(8-exp_width){1'b0}}, i_fp_num[bit_width-2:man_width]};
        sr_bits[22:0]  = {i_fp_num[man_width-1:0], {(23-man_width){1'b0}}};

        return $bitstoshortreal(sr_bits) * (2.0**127);

    endfunction

    function real fptoreal(input logic [bit_width-1:0] i_fp_num);
	// E11M52
        logic [63:0] real_bits;

        real_bits[63]    = i_fp_num[bit_width-1];
        real_bits[62:52] = {{(11-exp_width){1'b0}}, i_fp_num[bit_width-2:man_width]};
        real_bits[62:52] = real_bits[62:52] + 1023;// - exp_bias;
        real_bits[51:0]  = {i_fp_num[man_width-1:0], {(52-man_width){1'b0}}};

        return $bitstoreal(real_bits);

    endfunction

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


    // Reference
    real ref_dp_out;
    real ref_dp_out2;


    initial begin
        #10

        $display("Starting -----");
        $display("Width Exp:     %d", exp_width);
        $display("Width Man:     %d", man_width);
        $display("K:             %d", k);
        $display("Input Stages:  %d", input_stages);
        $display("Output Stages: %d", output_stages);

        for(int i=0; i<(1<<16); i++) begin

            for(int j=0; j<k; j++) begin
                i_op0[j] = $random;
                i_op1[j] = $random;
            end

            ref_dp_out = 0;
            ref_dp_out2 = 0;
            for(int j=0; j<k; j++) begin
                ref_dp_out += fptosr(i_op0[j]) * fptosr(i_op1[j]) / (fptosr(1) * fptosr(1));
                ref_dp_out2 += fptoreal(i_op0[j]) * fptoreal(i_op1[j]) / (fptoreal(1) * fptoreal(1));
            end

	    for (int j=0; j < (input_stages + output_stages + 1); j++) begin
                #10;
	    end

            	/*for(int j=0; j<k; j++) begin
                    $display("Ref in:  %f", fptosr(i_op0[j]));
	            $display("Ref in:  %f", fptosr(i_op1[j]));
                    $display("Ref in  b:  %b", (i_op0[j]));
                    $display("Ref in  b:  %b", (i_op1[j]));
                    $display("Ref in 64:  %f", fptoreal(i_op0[j]));
                    $display("Ref in 64:  %f", fptoreal(i_op1[j]));
                    $display("Ref out: %f", ref_dp_out);
                    $display("Ref out 64: %f", ref_dp_out2);
            	end*/
            if(p0_dp_out != ref_dp_out) begin
            	for(int j=0; j<k; j++) begin
                    $display("Ref in:  %f", fptosr(i_op0[j]));
	            $display("Ref in:  %f", fptosr(i_op1[j]));
                    $display("Ref in  b:  %h", (i_op0[j]));
                    $display("Ref in  b:  %h", (i_op1[j]));
                    $display("Ref in 64:  %f", fptoreal(i_op0[j]));
                    $display("Ref in 64:  %f", fptoreal(i_op1[j]));
            	end

                $display("Failed on: %d", i);
                $display("DUT out: %d", p0_dp_out);
                $display("Ref out: %f", ref_dp_out);
                $display("Ref out 64: %f", ref_dp_out2);
                $display("FAILED");
                $finish();
            end
        end

        $display("PASSED");
        $finish();
    end

endmodule
