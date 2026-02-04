import pkg_aitb::*;

module dot /*# (
	parameter DATA_WIDTH ;
	parameter DOT_LENGTH ;
) */(
	input  logic [DATA_WIDTH-1:0] data_in     [0:DOT_LENGTH-1],
	input  logic [DATA_WIDTH-1:0] data_in_reg [0:DOT_LENGTH-1],
	output logic [31:0]           dot_out
);

//logic [2*DATA_WIDTH-1:0] products [0:DOT_LENGTH-1];

always_comb begin
	dot_out = '0;

	//foreach(data_in[i]) begin
	////	products[i] = data_in[i] * data_in_reg[i];
	////	dot_out += products[i];
	//	dot_out += data_in[i] * data_in_reg[i];
	//end	

	for (int i = 0; i < DOT_LENGTH; i++) begin
		dot_out += data_in[i] * data_in_reg[i];
	end	

end

endmodule
