module normalizer_tb();
timeunit 1ns;
timeprecision 1ps;

localparam IN_WIDTH = 20;
localparam OUT_WIDTH = 23;
localparam INTERNAL_WIDTH = 32;

logic [IN_WIDTH-1:0] shift_in;
logic [OUT_WIDTH-1:0] shift_out;
logic [$clog2(INTERNAL_WIDTH)-1:0] shift_amount;

int n_tests = 10000;
int n_pass = 0;

initial begin

	repeat(n_tests) begin
		shift_in = $random;
		#5;
		checkOutput();
	end

	$display("Passed %7d/%7d tests", n_pass, n_tests);

	if (n_pass == n_tests)
		$display("TESTING PASSED");
	else
		$display("TESTING FAILED");

	$stop;
	
end

normalizer #(.IN_WIDTH(OUT_WIDTH), .INTERNAL_WIDTH(INTERNAL_WIDTH), .OUT_WIDTH(OUT_WIDTH)) dut (
	.shift_in({4'd0, shift_in}),
	.shift_out(shift_out),
	.lead_zero_pos(shift_amount)

);

task automatic checkOutput();
	int golden_zero_pos;
	int shift_in_pad = shift_in;
	for (int i = OUT_WIDTH-1; i >= 1; i--) begin
		if ((shift_in_pad[i] == 0) && (shift_in_pad[i-1] == 1)) begin
			golden_zero_pos = OUT_WIDTH-i;
			break;
		end
	end
	$display("sh_in  = %23b", shift_in);
	$display("sh_out = %23b", shift_out);
	$display("out    = %d", shift_amount);
	$display("golden = %d", golden_zero_pos);

	if (golden_zero_pos == shift_amount) begin
		$display("PASS");
		n_pass++;
	end else
		$display("FAIL");
	
endtask
endmodule

