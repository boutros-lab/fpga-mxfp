timeunit 1ns;
timeprecision 1ps;

module fp16_dot_tb();

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
    localparam exp_width = `EXP_WIDTH;
    localparam man_width = `MAN_WIDTH;
    localparam exp_bias  = 2 ** (exp_width - 1) - 1;
    localparam k         = `K;

    // DUT
    logic [15:0] fp16_in [k];
    logic [31:0] fp32_in;
    logic [31:0] fp32_out;

    fp16_dp #(
        .k(k)
    ) u_fp16_dp (
	.clk(clk),
	.rst(rst),
        .fp16_in(fp16_in),
        .fp32_in(fp32_in),
        .fp32_out(fp32_out)
    );

    initial begin
        #10

        $display("Starting -----");
        $display("Width Exp:     %d", exp_width);
        $display("Width Man:     %d", man_width);
        $display("K:             %d", k);

        for(int i = 0; i<(1<<3); i++) begin
		for (int j = 0; j < k; j++) begin
			//fp16_in[j] = 16'b0100000000000000; // 2.0
			fp16_in[j] = $random;
			$display("FP16 Input %d: %x", j, fp16_in[j]);
		end

		//fp32_in = 32'b0;
		fp32_in = $random;
		$display("FP32 chain_in: %x", fp32_in);

		for (int j = 0; j < 6; j++) begin
			#10;
		end

		$display("FP32 Output: %x", fp32_out);
        end

        $display("PASSED");
        $finish();
    end

endmodule
