import pkg_aitb::*;

module dot (
	input  logic signed [DATA_WIDTH-1:0]  data_in        [0:DOT_LENGTH-1],
	input  logic signed [DATA_WIDTH-1:0]  w_reg          [0:DOT_LENGTH-1],
	input  logic [DATA_WIDTH-1:0]  data_in_sh_exp,
	input  logic [DATA_WIDTH-1:0]  w_reg_sh_exp,
	output logic signed [DOT_OUT_WIDTH-1:0] dot_out,
	output logic [7:0]             sh_exp_out
);

logic [8:0] sh_exp_sum;

always_comb begin
	dot_out = '0;

	//foreach(data_in[i]) begin
	//	dot_out += data_in[i] * w_reg[i];
	//end	

	for (int i = 0; i < DOT_LENGTH; i++) begin
		dot_out += data_in[i] * w_reg[i];
	end	

	sh_exp_sum = data_in_sh_exp + w_reg_sh_exp;
	sh_exp_out = sh_exp_sum[7:0];
end

endmodule
