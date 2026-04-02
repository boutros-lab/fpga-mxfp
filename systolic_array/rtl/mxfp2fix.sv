module mxfp2fix #(
	parameter M = 2,
	parameter E = 1,
	parameter FIX_OUT_WIDTH = (1 << E) + M
) (

input logic [M+E:0] i_mxfp[0:31],
input logic [7:0]   i_sh_exp,

output logic signed [FIX_OUT_WIDTH-1:0] o_fix [0:31],
output logic [7:0] o_sh_exp

);

localparam FP_BIAS = (1 << (E-1)) - 1;

logic [M-1:0] mx_Ms [0:31];
logic [E-1:0] mx_Es [0:31];
logic         mx_Ss [0:31];
logic signed [FIX_OUT_WIDTH-1:0] fix_mant [0:31];


always_comb begin
	for (int i = 0; i < 32; i++) begin
		// Split MX-FP components
		mx_Ms[i] = i_mxfp[i][M-1:0];
		mx_Es[i] = i_mxfp[i][M+E-1:M];
		mx_Ss[i] = i_mxfp[i][M+E];

		// float2fix conversion
		if (mx_Es[i] == '0) begin
			o_fix[i] = (mx_Ss[i] == 1'b1) ? -(mx_Ms[i] << (mx_Es[i])) : mx_Ms[i] << (mx_Es[i]);
		end else begin
			o_fix[i] = (mx_Ss[i] == 1'b1) ? -(((1 << M) + mx_Ms[i]) << (mx_Es[i] - FP_BIAS)) : ((1 << M) + mx_Ms[i]) << (mx_Es[i] - FP_BIAS);
		end
	end

	o_sh_exp = i_sh_exp - M;
end
endmodule
