import pkg_aitb::*;

module dot #(
	INPUT_WIDTH  = DATA_WIDTH,
	DOT_LENGTH   = DOT_LENGTH,
	OUTPUT_WIDTH = (2 * INPUT_WIDTH) + $clog2(DOT_LENGTH)
)(
	input  logic signed [INPUT_WIDTH-1:0]    data_in [0:DOT_LENGTH-1],
	input  logic signed [INPUT_WIDTH-1:0]    w_reg   [0:DOT_LENGTH-1],
	output logic signed [OUTPUT_WIDTH-1:0] dot_out
);

always_comb begin
	dot_out = '0;

	for (int i = 0; i < DOT_LENGTH; i++) begin
		dot_out += data_in[i] * w_reg[i];
	end	

end

endmodule
