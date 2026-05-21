module mxfp_dot #(
	parameter M = 3,
	parameter E = 2,
	parameter E_SHARED = 8,
	parameter FP_BIAS = 1, // MX-FP BIAS
	parameter SH_BIAS = 127, // Shared EXP bias
	parameter PIPE = 1,
	parameter DOT_LEN = 32
) (

	input logic clk,
	input logic rst,
	input logic load_en,
	input logic valid_in,
	input logic [M+E:0] mx_data_in [0:DOT_LEN-1],
	input logic [E_SHARED-1:0] shared_exponent,
	output logic [31:0] fp32_dot_out,
//	output logic [31:0] fp32_dot_out_0,
//	output logic [31:0] fp32_dot_out_1,
	output logic valid_out,
	output logic [3:0] fp32_flags [0:3]

);

logic [M-1:0] mx_Ms [0:DOT_LEN-1];
logic [E-1:0] mx_Es [0:DOT_LEN-1];
logic  mx_Ss [0:DOT_LEN-1];

//logic /*signed*/ [7:0] corrected_Ms [0:DOT_LEN-1];

logic [31:0] dot_out [0:3];
logic [31:0] cascade_out [0:3];
logic [7:0] corrected_E;
logic [7:0] corrected_E_ff [0:3];
logic [7:0] corrected_E_eff [0:3];

logic [7:0] int8mant [0:DOT_LEN-1];
logic [7:0] int8mant_ff [0:DOT_LEN-1];
logic [7:0] int8mant_eff [0:DOT_LEN-1];
logic internal_valid_out [0:3];

logic load_en_ff;

logic [M+E:0] mx_data_in_ff [0:DOT_LEN-1];
logic [E_SHARED-1:0] shared_exponent_ff;

generate
for (genvar j = 0; j < DOT_LEN; j++) begin
	pipeline #(.W(M+E+1), .STAGES(PIPE)) DATA_IN_PIPE (
		.clk(clk),
		.rst(rst),
		.pipe_in(mx_data_in[j]),
		.pipe_out(mx_data_in_ff[j])
	);
end

pipeline #(.W(8), .STAGES(PIPE)) SH_EXP_PIPE (
	.clk(clk),
	.rst(rst),
	.pipe_in(shared_exponent),
	.pipe_out(shared_exponent_ff)
);
endgenerate
integer i;

always_comb begin
	for (i = 0; i < DOT_LEN; i++)
		int8mant[i] = '0;
	// Split MX-FP components
	for (i = 0; i < DOT_LEN; i++) begin
		mx_Ms[i] = mx_data_in_ff[i][M-1:0];
		mx_Es[i] = mx_data_in_ff[i][M+E-1:M];
		mx_Ss[i] = mx_data_in_ff[i][M+E];
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
	corrected_E = shared_exponent_ff - M;
end



integer j;
always_comb begin
	if (load_en_ff == 1'b1) begin
		//for (i = 0; i < DOT_LEN; i++)
			int8mant_eff = int8mant;
		for (j = 0; j < 4; j++)
			corrected_E_eff[j] = corrected_E;
		end else begin

		//for (i = 0; i < DOT_LEN; i++)
			int8mant_eff = int8mant_ff;
		for (j = 0; j < 4; j++)
			corrected_E_eff[j] = corrected_E_ff[j];
	end
end
generate
		for (genvar j = 10; j < 20; j++) begin
			pipeline #(.W(8), .STAGES(2)) DOT1_M_PIPE (
				.clk(clk),
				.rst(rst),
				.pipe_in(int8mant[j]),
				.pipe_out(int8mant_ff[j])
			);
		end
		pipeline #(.W(8), .STAGES(2)) DOT1_E_PIPE (
			.clk(clk),
			.rst(rst),
			.pipe_in(corrected_E),
			.pipe_out(corrected_E_ff[1])
		);
		for (genvar j = 20; j < 30; j++) begin
			pipeline #(.W(8), .STAGES(4)) DOT2_M_PIPE (
				.clk(clk),
				.rst(rst),
				.pipe_in(int8mant[j]),
				.pipe_out(int8mant_ff[j])
			);
		end
		pipeline #(.W(8), .STAGES(4)) DOT2_E_PIPE (
			.clk(clk),
			.rst(rst),
			.pipe_in(corrected_E),
			.pipe_out(corrected_E_ff[2])
		);
		for (genvar j = 30; j < 32; j++) begin
			pipeline #(.W(8), .STAGES(6)) DOT3_M_PIPE (
				.clk(clk),
				.rst(rst),
				.pipe_in(int8mant[j]),
				.pipe_out(int8mant_ff[j])
			);
		end
		pipeline #(.W(8), .STAGES(6)) DOT3_E_PIPE (
			.clk(clk),
			.rst(rst),
			.pipe_in(corrected_E),
			.pipe_out(corrected_E_ff[3])
		);
endgenerate

pipeline #(.W(1), .STAGES(1)) load_PIPE (
		.clk(clk),
		.rst(load_en | rst),
		.pipe_in(load_en),
		.pipe_out(load_en_ff)
);
pipeline #(.W(1), .STAGES(5)) valid0_PIPE (
		.clk(clk),
		.rst(load_en | rst),
		.pipe_in(valid_in),
		.pipe_out(internal_valid_out[0])
);

pipeline #(.W(1), .STAGES(2)) valid1_PIPE (
		.clk(clk),
		.rst(load_en | rst),
		.pipe_in(internal_valid_out[0]),
		.pipe_out(internal_valid_out[1])
);
pipeline #(.W(1), .STAGES(2)) valid2_PIPE (
		.clk(clk),
		.rst(load_en | rst),
		.pipe_in(internal_valid_out[1]),
		.pipe_out(internal_valid_out[2])
);
pipeline #(.W(1), .STAGES(1)) valid3_PIPE (
		.clk(clk),
		.rst(load_en | rst),
		.pipe_in(internal_valid_out[2]),
		.pipe_out(internal_valid_out[3])
);
assign valid_out = internal_valid_out[3];

fp_aitb #(.CHAIN_MODE("zero_tensor_chain_output")) dot_engine0 (
.clk(clk),
.rst(rst),
.acc_mode(2'b10),
.load_en(load_en),
.data_in(int8mant[0:9]),
.shared_exponent(corrected_E),
.fp32_cascade_in(),
.fp32_dot_out(dot_out[0]),
.fp32_cascade_out(cascade_out[0]),
.fp32_flags(fp32_flags[0])
);

fp_aitb dot_engine1 (
.clk(clk),
.rst(rst),
.acc_mode(2'b00),
.load_en(load_en),
.data_in(int8mant_eff[10:19]),
.shared_exponent(corrected_E_eff[1]),
//.shared_exponent(corrected_E),
.fp32_cascade_in(cascade_out[0]),
.fp32_dot_out(dot_out[1]),
.fp32_cascade_out(cascade_out[1]),
.fp32_flags(fp32_flags[1])
);

fp_aitb dot_engine2 (
.clk(clk),
.rst(rst),
.acc_mode(2'b00),
.load_en(load_en),
.data_in(int8mant_eff[20:29]),
.shared_exponent(corrected_E_eff[2]),
//.shared_exponent(corrected_E),
.fp32_cascade_in(cascade_out[1]),
.fp32_dot_out(dot_out[2]),
.fp32_cascade_out(cascade_out[2]),
.fp32_flags(fp32_flags[2])
);

fp_aitb /*#(.CHAIN_MODE("zero_tensor_chain_output"))*/ dot_engine3 (
.clk(clk),
.rst(rst),
.acc_mode(2'b00),
.load_en(load_en),
.data_in({int8mant_eff[30], int8mant_eff[31], 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0}),
.shared_exponent(corrected_E_eff[3]),
//.shared_exponent(corrected_E),
.fp32_cascade_in(cascade_out[2]),
.fp32_dot_out(dot_out[3]),
.fp32_cascade_out(/*cascade_out[3]*/),
.fp32_flags(fp32_flags[3])
);

assign fp32_dot_out = dot_out[3];

endmodule
