import pkg_aitb::*;

module fix2fp32 (
	input logic signed [DOT_OUT_WIDTH-1:0] fix_in,
	//input logic [DATA_WIDTH-1:0] shared_exp,
	input  logic [DATA_WIDTH-1:0]  data_in_sh_exp,
	input  logic [DATA_WIDTH-1:0]  w_reg_sh_exp,
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
logic signed [10:0]               exp_adj;

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

	//exp_adj = (shared_exp + DOT_OUT_WIDTH - lead_zero_count - 1);
	//exp_adj = ($signed({2'b00, shared_exp}) + 10'sd23 - $signed({5'b00000, lead_zero_count}) - 10'sd1);
//	exp_adj = (shared_exp + 10'sd23 - $signed({5'b00000, lead_zero_count}) - 10'sd1);
	////exp_adj = $signed(shared_exp) - $signed(lead_zero_count);
	exp_adj = $signed({3'd0, data_in_sh_exp}) + $signed({3'd0, w_reg_sh_exp}) + 11'sd23 - 11'sd1 - $signed({6'd0, lead_zero_count}) - 11'sd127;
	mant = {normalized_mant[21:0], 1'b0};

	priority case(1'b1)
		(mag == '0): fp32_out = {sign, 31'd0};
		(exp_adj >= 10'sd255): fp32_out = {sign, 8'hFF, 23'd0};
		(exp_adj <= 10'sd0): fp32_out = {sign, 31'd0};
		default: fp32_out = {sign, exp_adj[7:0], mant};
	endcase
end

normalizer #(.IN_WIDTH(23), .OUT_WIDTH(23)) norm (
	.shift_in({3'd0, mag}),
	.shift_out(normalized_mant),
	.lead_zero_count(lead_zero_count)
);

endmodule
