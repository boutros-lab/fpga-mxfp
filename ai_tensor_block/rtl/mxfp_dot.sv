module mxfp_dot #(
	parameter M = 2,
	parameter E = 1,
	parameter E_SHARED = 8,
	parameter FP_BIAS = 1, // MX-FP BIAS
	parameter SH_BIAS = 127, // Shared EXP bias
	parameter DOT_LEN = 10
) (

	input logic clk,
	input logic rst,
	input logic load_en,
	input logic [M+E:0] mx_data_in [0:DOT_LEN-1],
	input logic [E_SHARED-1:0] shared_exponent,
	output logic [31:0] fp32_dot_out,
	output logic [3:0] fp32_flags

);

logic [M-1:0] mx_Ms [0:DOT_LEN-1];
logic [E-1:0] mx_Es [0:DOT_LEN-1];
logic  mx_Ss [0:DOT_LEN-1];

logic /*signed*/ [7:0] corrected_Ms [0:DOT_LEN-1];
logic signed [7:0] corrected_E;

logic [31:0] dot_out [0:0];
//logic signed [7:0] corrected_Ms_ff [0:DOT_LEN];
//logic [7:0] corrected_E_ff [0:3];

logic [7:0] int8mant [0:DOT_LEN-1];
//logic [7:0] shared_exponent;

integer i;

always_comb begin
	for (i = 0; i < DOT_LEN; i++)
		int8mant[i] = '0;
	// Split MX-FP components
	for (i = 0; i < DOT_LEN; i++) begin
		mx_Ms[i] = mx_data_in[i][M-1:0];
		mx_Es[i] = mx_data_in[i][M+E-1:M];
		mx_Ss[i] = mx_data_in[i][M+E];
	end
	// float2fix conversion
	for (i = 0; i < DOT_LEN; i++) begin
		// Normal and subnormal
		if (mx_Es[i] == '0) begin
			//int8mant[i] = (mx_Ss[i] == 1'b1) ? -(mx_Ms[i] << (mx_Es[i])) : mx_Ms[i] << (mx_Es[i]);
			int8mant[i] = (mx_Ss[i] == 1'b1) ? ~(mx_Ms[i] << (mx_Es[i]))+1'b1 : mx_Ms[i] << (mx_Es[i]);
		end else begin
			//int8mant[i] = (mx_Ss[i] == 1'b1) ? -(((1 << M) + mx_Ms[i]) << (mx_Es[i] - FP_BIAS)) : ((1 << M) + mx_Ms[i]) << (mx_Es[i] - FP_BIAS);
			int8mant[i] = (mx_Ss[i] == 1'b1) ? ~(((1 << M) + mx_Ms[i]) << (mx_Es[i] - FP_BIAS))+1'b1 : ((1 << M) + mx_Ms[i]) << (mx_Es[i] - FP_BIAS);
		end
	end
	corrected_E = 8'd127 - 8'd1 + shared_exponent;
end


/*
always_comb begin
	// Split MX-FP components
	for (i = 0; i < DOT_LEN; i++) begin
		mx_Ms[i] = mx_data_in[i][M-1:0];
		mx_Es[i] = mx_data_in[i][M+E-1:0];
		mx_Ss[i] = mx_data_in[i][M+E];
	end
	// Mantissa to INT8
	for (i = 0; i < DOT_LEN; i++) begin
		corrected_Ms[i] = (mx_Ss[i] == 1'b1) ? -mx_Ms[i] : mx_Ms[i];
	end
	// Exponent adjustment
	corrected_E = '0;
	for (i = 0; i < DOT_LEN; i++) begin
		corrected_E += mx_Es[i] - FP_BIAS - SH_BIAS;
	end
	corrected_E += shared_exponent;
end
*/
/*
generate
	if (load_en == 1'b1) begin
		assign corrected_Ms_ff = corrected_Ms;
		assign corrected_E_ff = corrected_E;
	end else begin
		for (genvar j; j < 10; j++) begin
		pipeline #(.W(8), .STAGES()) M_PIPE (
				.clk(clk),
				.rst(rst),
				.pipe_in(),
				.pipe_out()
			);
		pipeline #(.W(8), .STAGES()) E_PIPE (
				.clk(clk),
				.rst(rst),
				.pipe_in(),
				.pipe_out()
			);
	end
endgenerate
*/
fp_aitb dot_engine0 (
.clk(clk),
.rst(rst),
.acc_mode(2'b10),
.load_en(load_en),
.data_in(int8mant),
.shared_exponent(corrected_E),
.fp32_cascade_in('0),
.fp32_dot_out(dot_out[0]),
.fp32_cascade_out(fp32_dot_out),
.fp32_flags(fp32_flags)
);
/*
fp_aitb dot_engine1 (
.clk(clk),
.rst(rst),
.acc_mode(2'b00),
.load_en(load_en),
.data_in(),
.shared_exponent(),
.fp32_cascade_in(),
.fp32_dot_out(),
.fp32_cascade_out(),
.fp32_flags()
);

fp_aitb dot_engine2 (
.clk(clk),
.rst(rst),
.acc_mode(2'b00),
.load_en(load_en),
.data_in(),
.shared_exponent(),
.fp32_cascade_in(),
.fp32_dot_out(),
.fp32_cascade_out(),
.fp32_flags()
);

fp_aitb dot_engine3 (
.clk(clk),
.rst(rst),
.acc_mode(2'b00),
.load_en(load_en),
.data_in(),
.shared_exponent(),
.fp32_cascade_in(),
.fp32_dot_out(),
.fp32_cascade_out(),
.fp32_flags()
);
*/
endmodule
