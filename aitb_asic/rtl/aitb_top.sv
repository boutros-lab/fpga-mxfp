import pkg_aitb::*;

module aitb_top (
	input logic clk,
	input logic rst,
	input logic acc_en,
	input logic zero_en,
	input logic load_bb_one,
	input logic load_bb_two,
	input logic load_buf_sel,
	input logic [FLAT_DATA_WIDTH-1:0] data_in,
	input logic [7:0] shared_exponent,
	input logic [31:0] fp32_cascade_in_col1,
	input logic [31:0] fp32_cascade_in_col2,

	output logic [31:0] fp32_dot_out_col1,
	output logic [31:0] fp32_dot_out_col2,
	output logic [31:0] fp32_cascade_out_col1,
	output logic [31:0] fp32_cascade_out_col2,
	output logic [3:0]  fp32_flags_col1,
	output logic [3:0]  fp32_flags_col2

);

// Input
logic [FLAT_DATA_WIDTH-1:0] data_in_pipe;
logic [DATA_WIDTH-1:0] data_in_sh_exp_pipe;
logic [DATA_WIDTH-1:0] data_in_sh_exp_pipe2;
logic [DATA_WIDTH-1:0] data_in_sh_exp_pipe3;
logic [FLAT_DATA_WIDTH-1:0] w_reg_c1;
logic [DATA_WIDTH-1:0] w_reg_c1_sh_exp;
logic [DATA_WIDTH-1:0] w_reg_c1_sh_exp_pipe2;
logic [DATA_WIDTH-1:0] w_reg_c1_sh_exp_pipe3;
logic [FLAT_DATA_WIDTH-1:0] w_reg_c2;
logic [DATA_WIDTH-1:0] w_reg_c2_sh_exp;
logic [DATA_WIDTH-1:0] w_reg_c2_sh_exp_pipe2;
logic [DATA_WIDTH-1:0] w_reg_c2_sh_exp_pipe3;

// Unpacked data
logic signed [FIXED_DATA_WIDTH-1:0] fixed_c1 [FIXED_ELEMENTS];
logic signed [FIXED_DATA_WIDTH-1:0] fixed_c2 [FIXED_ELEMENTS];
logic signed [FIXED_DATA_WIDTH-1:0] fixed_data_in [FIXED_ELEMENTS];

logic signed [FIXED_DATA_WIDTH-1:0] fixed_c1_pipe [FIXED_ELEMENTS];
logic signed [FIXED_DATA_WIDTH-1:0] fixed_c2_pipe [FIXED_ELEMENTS];
logic signed [FIXED_DATA_WIDTH-1:0] fixed_data_in_pipe [FIXED_ELEMENTS];

// Dot Product
logic signed [DOT_OUT_WIDTH-1:0] dot_out_col1;
logic signed [DOT_OUT_WIDTH-1:0] dot_out_col2;
logic signed [DOT_OUT_WIDTH-1:0] dot_out_col1_pipe;
logic signed [DOT_OUT_WIDTH-1:0] dot_out_col2_pipe;
logic signed [DOT_OUT_WIDTH-1:0] adder_out_col1;
logic signed [DOT_OUT_WIDTH-1:0] adder_out_col2;

// Fix2Float
logic [31:0] fix2float_out_col1;
logic [31:0] fix2float_out_col2;
logic [31:0] fix2float_out_col1_pipe;
logic [31:0] fix2float_out_col2_pipe;
logic [31:0] fp32_cascade_in_col1_pipe;
logic [31:0] fp32_cascade_in_col2_pipe;
logic [31:0] acc_mux_out_col1;
logic [31:0] acc_mux_out_col2;
logic [31:0] fp32_alu_out_col1;
logic [31:0] fp32_alu_out_col2;

// Input register bank
in_reg_bank in_reg_bank (
	.clk(clk),
	.rst(rst),
	.data_in(data_in),
	.data_in_sh_exp(shared_exponent),
	.load_bb_one(load_bb_one),
	.load_bb_two(load_bb_two),
	.load_buf_sel(load_buf_sel),
	.w_reg_c1(w_reg_c1),
	.w_reg_c1_sh_exp(w_reg_c1_sh_exp),
	.w_reg_c2(w_reg_c2),
	.w_reg_c2_sh_exp(w_reg_c2_sh_exp)
);

// Pipe 1 (Input stage)
pipeline #(.W(FLAT_DATA_WIDTH), .STAGES(1)) PIPE_1_data_in (
	.clk(clk),
	.rst(rst),
	.pipe_in(data_in),
	.pipe_out(data_in_pipe)
);

pipeline #(.W(8), .STAGES(1)) PIPE_1_sh_exp (
	.clk(clk),
	.rst(rst),
	.pipe_in(shared_exponent),
	.pipe_out(data_in_sh_exp_pipe)
);

// Arrange flat input into unpacked arrays
input_preparation #(
	.FLAT_WIDTH(FLAT_DATA_WIDTH), 
	.ELEMENT_WIDTH(FIXED_DATA_WIDTH),
	.ELEMENT_COUNT(FIXED_ELEMENTS)
) u_input_preparation_col1 (
	.i_flat(w_reg_c1),
	.o_elements(fixed_c1)
);

input_preparation #(
	.FLAT_WIDTH(DATA_WIDTH * DOT_LENGTH), 
	.ELEMENT_WIDTH(DATA_WIDTH)
) u_input_preparation_col2 (
	.i_flat(w_reg_c2),
	.o_elements(fixed_c2)
);

input_preparation #(
	.FLAT_WIDTH(DATA_WIDTH * DOT_LENGTH), 
	.ELEMENT_WIDTH(DATA_WIDTH)
) u_input_preparation_data_in (
	.i_flat(data_in_pipe),
	.o_elements(fixed_data_in)
);

// Pipe 2
generate
	for (genvar i = 0; i < DOT_LENGTH; i++) begin
		pipeline #(.W(FIXED_DATA_WIDTH), .STAGES(1)) PIPE_2_fixed_c1 (
			.clk(clk),
			.rst(rst),
			.pipe_in(fixed_c1[i]),
			.pipe_out(fixed_c1_pipe[i])
		);

		pipeline #(.W(FIXED_DATA_WIDTH), .STAGES(1)) PIPE_2_fixed_c2 (
			.clk(clk),
			.rst(rst),
			.pipe_in(fixed_c2[i]),
			.pipe_out(fixed_c2_pipe[i])
		);

		pipeline #(.W(FIXED_DATA_WIDTH), .STAGES(1)) PIPE_2_fixed_data_in (
			.clk(clk),
			.rst(rst),
			.pipe_in(fixed_data_in[i]),
			.pipe_out(fixed_data_in_pipe[i])
		);
	end
endgenerate

pipeline #(.W(8), .STAGES(1)) PIPE_2_sh_exp (
	.clk(clk),
	.rst(rst),
	.pipe_in(data_in_sh_exp_pipe),
	.pipe_out(data_in_sh_exp_pipe2)
);

pipeline #(.W(8), .STAGES(1)) PIPE_2_w_reg_c1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c1_sh_exp),
	.pipe_out(w_reg_c1_sh_exp_pipe2)
);

pipeline #(.W(8), .STAGES(1)) PIPE_2_w_reg_c2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c2_sh_exp),
	.pipe_out(w_reg_c2_sh_exp_pipe2)
);

// Dot engine (out: 20b vector)
dot dot_col1 (
	.data_in(fixed_data_in_pipe),
	.w_reg(fixed_c1_pipe),
	.dot_out(dot_out_col1)
);

dot dot_col2 (
	.data_in(fixed_data_in_pipe),
	.w_reg(fixed_c2_pipe),
	.dot_out(dot_out_col2)
);

// Pipe 3 (out: 32b extended from the 20b) ?
pipeline #(.W(DOT_OUT_WIDTH), .STAGES(1)) PIPE_3_dot_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col1),
	.pipe_out(dot_out_col1_pipe)
);

pipeline #(.W(DOT_OUT_WIDTH), .STAGES(1)) PIPE_3_dot_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col2),
	.pipe_out(dot_out_col2_pipe)
);

pipeline #(.W(8), .STAGES(1)) PIPE_3_in_sh_exp (
	.clk(clk),
	.rst(rst),
	.pipe_in(data_in_sh_exp_pipe2),
	.pipe_out(data_in_sh_exp_pipe3)
);

pipeline #(.W(8), .STAGES(1)) PIPE_3_w_reg_c1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c1_sh_exp_pipe2),
	.pipe_out(w_reg_c1_sh_exp_pipe3)
);

pipeline #(.W(8), .STAGES(1)) PIPE_3_w_reg_c2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c2_sh_exp_pipe2),
	.pipe_out(w_reg_c2_sh_exp_pipe3)
);

// CPA Adder (used for FXP Tensor Mode but in this datapath nonetheless)
assign adder_out_col1 = dot_out_col1_pipe + '0;
assign adder_out_col2 = dot_out_col2_pipe + '0;

// FXP to FP32
fix2fp32 FXP2FP32_col1 (
	.fix_in(adder_out_col1),
	.data_in_sh_exp(data_in_sh_exp_pipe3),
	.w_reg_sh_exp(w_reg_c1_sh_exp_pipe3),
	.fp32_out(fix2float_out_col1)
);

fix2fp32 FXP2FP32_col2 (
	.fix_in(adder_out_col2),
	.data_in_sh_exp(data_in_sh_exp_pipe3),
	.w_reg_sh_exp(w_reg_c2_sh_exp_pipe3),
	.fp32_out(fix2float_out_col2)
);

// Pipe 4
pipeline #(.W(32), .STAGES(1)) PIPE_3_fix2float_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fix2float_out_col1),
	.pipe_out(fix2float_out_col1_pipe)
);
pipeline #(.W(32), .STAGES(1)) PIPE_3_fix2float_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fix2float_out_col2),
	.pipe_out(fix2float_out_col2_pipe)
);

pipeline #(.W(32), .STAGES(1)) PIPE_cascade_in_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fp32_cascade_in_col1),
	.pipe_out(fp32_cascade_in_col1_pipe)
);
pipeline #(.W(32), .STAGES(1)) PIPE_cascade_in_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fp32_cascade_in_col2),
	.pipe_out(fp32_cascade_in_col2_pipe)
);

always_comb begin
	case({zero_en, acc_en})
		2'b00: begin
			acc_mux_out_col1 = fp32_cascade_in_col1_pipe;
			acc_mux_out_col2 = fp32_cascade_in_col2_pipe;
		end
		2'b01: begin
			acc_mux_out_col1 = fp32_dot_out_col1;
			acc_mux_out_col2 = fp32_dot_out_col2;
		end
		2'b10,
		2'b11: begin
			acc_mux_out_col1 = '0;
			acc_mux_out_col2 = '0;
		end
	endcase
end

// FP32 ALU
ieee_fp32_add FP32_ALU_col1 (
	.X(fix2float_out_col1_pipe),
	.Y(acc_mux_out_col1),
	.R(fp32_alu_out_col1)
);
ieee_fp32_add FP32_ALU_col2 (
	.X(fix2float_out_col2_pipe),
	.Y(acc_mux_out_col2),
	.R(fp32_alu_out_col2)
);

// Pipe 5 (Output)
pipeline #(.W(32), .STAGES(1)) PIPE_OUT_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fp32_alu_out_col1),
	.pipe_out(fp32_dot_out_col1)
);

pipeline #(.W(32), .STAGES(1)) PIPE_OUT_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(fp32_alu_out_col2),
	.pipe_out(fp32_dot_out_col2)
);
assign fp32_cascade_out_col1 = fp32_dot_out_col1;
assign fp32_cascade_out_col2 = fp32_dot_out_col2;

endmodule 
