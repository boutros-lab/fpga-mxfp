import pkg_aitb::*;

module fix2fp32_tb();

logic signed [DOT_OUT_WIDTH-1:0] fix_in;
logic [DATA_WIDTH-1:0] sh_exp;
logic [31:0] fp32_out;

shortreal golden_fp32_out;

int n_tests = 1000000;
int n_pass = 0;

initial begin
	repeat (n_tests) begin
		fix_in = $random;
		sh_exp = $random;
		#5;
		checkOutput();
	end

	$display("Passed %d/%d tests", n_pass, n_tests);

	if (n_pass == n_tests)
		$display("TESTING PASSED");
	else
		$display("TESTING FAILED");

	$stop;

end

fix2fp32 dut (
	.fix_in(fix_in),
	.shared_exp(sh_exp),
	.fp32_out(fp32_out)
);

task automatic checkOutput;
	golden_fp32_out = /*shortreal'*/(real'(fix_in) * real'(2.0 ** (int'(sh_exp)-127)));
	$display("fix_in = %d", fix_in);
	$display("sh_exp = %3d", sh_exp);
	$display("Expected: fix_in = %f", golden_fp32_out);
	$display("Got     : fp32_out = %f", $bitstoshortreal(fp32_out));
	$display("Expected: fix_in   = %32b", $shortrealtobits(golden_fp32_out));
	$display("Got     : fp32_out = %32b", fp32_out);

	if (fp32_out == $shortrealtobits(golden_fp32_out)) begin
		$display("PASS");
		n_pass++;
	end else
		$display("FAIL");
endtask

endmodule
