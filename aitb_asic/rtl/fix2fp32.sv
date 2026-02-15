import pkg_aitb::*;

module fix2fp32 (
	input logic [DOT_OUT_WIDTH-1:0] fix_in,
	input logic [DATA_WIDTH-1:0] shared_exp,
	output logic [31:0] fp32_out
);

//---- logic to implement ----//
/*****

1. mag = Get magnitude of fix
2. sh = Get leading 0 position
3. exp_adj = sh + shared_exp
4. mant[22:0] = mag << (23 - sh )
5. pack fp32

 S    E                 M
|-|--------|-----------------------|
 1    8                 23

*****/
logic [DOT_OUT_WIDTH-1:0] mag;
logic                     sign;
logic [22:0]              mant;
logic [7:0]               exp_adj;

logic [4:0]               lead_zero_count;
logic [22:0]              normalized_mant;

always_comb begin

	if (fix_in[DOT_OUT_WIDTH-1] == 1'b1) begin
		mag = -fix_in;
		sign = 1'b1;
	end else begin	
		mag = fix_in;
		sign = 1'b0;
	end

	exp_adj = (shared_exp + DOT_OUT_WIDTH - lead_zero_count - 1);
	mant = {normalized_mant[21:0], 1'b0};

	fp32_out = {sign, exp_adj, mant};

end

normalizer #(.IN_WIDTH(DOT_OUT_WIDTH), .OUT_WIDTH(23)) norm (
	.shift_in(mag),
	.shift_out(normalized_mant),
	.lead_zero_count(lead_zero_count)
);

endmodule
