/*
* Fixed input implementation of MXFP AITB
*/

import pkg_aitb::*;

module fixed_input_mxfp_aitb_top (
	input logic clk,
	input logic rst,
	input logic acc_en,
	input logic zero_en,
	input logic load_bb_one,
	input logic load_bb_two,
	input logic load_buf_sel,

	input mxfp_mode_e i_mxfp_mode,

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
localparam E3M2_ELEMENTS  = 8;
localparam FIXED_ELEMENTS = 2;
localparam E2M3_ELEMENTS  = 1;
localparam E2M1_ELEMENTS  = 5;

localparam E3M2_WIDTH  = 10; // 1 + (M + 1) + (2^E - 2)
localparam FIXED_WIDTH =  8;
localparam E2M3_WIDTH  =  7;
localparam E2M1_WIDTH  =  5;

localparam FIXED_RESULT_WIDTH = (E3M2_WIDTH * 2) + $clog2(E3M2_ELEMENTS);

// Input
logic [FLAT_DATA_WIDTH-1:0] data_in_pipe;
logic [SH_EXP_WIDTH-1:0]    data_in_sh_exp_pipe;
logic [SH_EXP_WIDTH-1:0]    data_in_sh_exp_pipe2;
logic [SH_EXP_WIDTH-1:0]    data_in_sh_exp_pipe3;
logic [FLAT_DATA_WIDTH-1:0] w_reg_c1;
logic [SH_EXP_WIDTH-1:0]    w_reg_c1_sh_exp;
logic [SH_EXP_WIDTH-1:0]    w_reg_c1_sh_exp_pipe2;
logic [SH_EXP_WIDTH-1:0]    w_reg_c1_sh_exp_pipe3;
logic [FLAT_DATA_WIDTH-1:0] w_reg_c2;
logic [SH_EXP_WIDTH-1:0]    w_reg_c2_sh_exp;
logic [SH_EXP_WIDTH-1:0]    w_reg_c2_sh_exp_pipe2;
logic [SH_EXP_WIDTH-1:0]    w_reg_c2_sh_exp_pipe3;

// Unpacked data
logic signed [E3M2_WIDTH-1:0]  e3m2_c1       [E3M2_ELEMENTS];
logic signed [E3M2_WIDTH-1:0]  e3m2_c2       [E3M2_ELEMENTS];
logic signed [E3M2_WIDTH-1:0]  e3m2_data_in  [E3M2_ELEMENTS];

logic signed [FIXED_WIDTH-1:0] fixed_c1      [FIXED_ELEMENTS];
logic signed [FIXED_WIDTH-1:0] fixed_c2      [FIXED_ELEMENTS];
logic signed [FIXED_WIDTH-1:0] fixed_data_in [FIXED_ELEMENTS];

logic signed [E2M3_WIDTH-1:0]  e2m3_c1       [E2M3_ELEMENTS];
logic signed [E2M3_WIDTH-1:0]  e2m3_c2       [E2M3_ELEMENTS];
logic signed [E2M3_WIDTH-1:0]  e2m3_data_in  [E2M3_ELEMENTS];

logic signed [E2M1_WIDTH-1:0]  e2m1_c1       [E2M1_ELEMENTS];
logic signed [E2M1_WIDTH-1:0]  e2m1_c2       [E2M1_ELEMENTS];
logic signed [E2M1_WIDTH-1:0]  e2m1_data_in  [E2M1_ELEMENTS];

logic signed [E3M2_WIDTH-1:0]  e3m2_c1_pipe       [E3M2_ELEMENTS];
logic signed [E3M2_WIDTH-1:0]  e3m2_c2_pipe       [E3M2_ELEMENTS];
logic signed [E3M2_WIDTH-1:0]  e3m2_data_in_pipe  [E3M2_ELEMENTS];

logic signed [FIXED_WIDTH-1:0] fixed_c1_pipe      [FIXED_ELEMENTS];
logic signed [FIXED_WIDTH-1:0] fixed_c2_pipe      [FIXED_ELEMENTS];
logic signed [FIXED_WIDTH-1:0] fixed_data_in_pipe [FIXED_ELEMENTS];

logic signed [E2M3_WIDTH-1:0]  e2m3_c1_pipe       [E2M3_ELEMENTS];
logic signed [E2M3_WIDTH-1:0]  e2m3_c2_pipe       [E2M3_ELEMENTS];
logic signed [E2M3_WIDTH-1:0]  e2m3_data_in_pipe  [E2M3_ELEMENTS];

logic signed [E2M1_WIDTH-1:0]  e2m1_c1_pipe       [E2M1_ELEMENTS];
logic signed [E2M1_WIDTH-1:0]  e2m1_c2_pipe       [E2M1_ELEMENTS];
logic signed [E2M1_WIDTH-1:0]  e2m1_data_in_pipe  [E2M1_ELEMENTS];

// Dot Product
logic signed [FIXED_RESULT_WIDTH-1:0] dot_out_col1;
logic signed [FIXED_RESULT_WIDTH-1:0] dot_out_col2;
logic signed [FIXED_RESULT_WIDTH-1:0] dot_out_col1_pipe;
logic signed [FIXED_RESULT_WIDTH-1:0] dot_out_col2_pipe;
logic signed [FIXED_RESULT_WIDTH-1:0] adder_out_col1;
logic signed [FIXED_RESULT_WIDTH-1:0] adder_out_col2;

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

// Configuration
logic signed [7:0] exponent_correction;

config_gen #(
	.FIXED_WIDTH_LOCAL(24) // Needs to be at least 24 for fix2float
) u_config_gen (
	.i_mxfp_mode(i_mxfp_mode),
	.o_sign_shift(),
	.o_exp_bits(),
	.o_man_bits(),
	.o_exp_mask(),
	.o_man_mask(),
	.o_exponent_correction(exponent_correction)
);

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

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_1_sh_exp (
	.clk(clk),
	.rst(rst),
	.pipe_in(shared_exponent),
	.pipe_out(data_in_sh_exp_pipe)
);

// Arrange flat input into unpacked arrays
fixed_mxfp_input_preparation
u_fixed_mxfp_input_preparation_col1 (
	.i_mxfp_mode(i_mxfp_mode),
	.i_flat(w_reg_c1),

	.o_e3m2(e3m2_c1),
	.o_fixed(fixed_c1),
	.o_e2m3(e2m3_c1),
	.o_e2m1(e2m1_c1)
);

fixed_mxfp_input_preparation 
u_fixed_mxfp_input_preparation_col2 (
	.i_mxfp_mode(i_mxfp_mode),
	.i_flat(w_reg_c2),

	.o_e3m2(e3m2_c2),
	.o_fixed(fixed_c2),
	.o_e2m3(e2m3_c2),
	.o_e2m1(e2m1_c2)
);

fixed_mxfp_input_preparation 
u_fixed_mxfp_input_preparation_data_in (
	.i_mxfp_mode(i_mxfp_mode),
	.i_flat(data_in_pipe),

	.o_e3m2(e3m2_data_in),
	.o_fixed(fixed_data_in),
	.o_e2m3(e2m3_data_in),
	.o_e2m1(e2m1_data_in)
);

// Pipe 2

always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		e3m2_c1_pipe       <= '{default: 'b0};
		e3m2_c2_pipe       <= '{default: 'b0};
		e3m2_data_in_pipe  <= '{default: 'b0};
		
		fixed_c1_pipe      <= '{default: 'b0};
		fixed_c2_pipe      <= '{default: 'b0};
		fixed_data_in_pipe <= '{default: 'b0};
		
		e2m3_c1_pipe       <= '{default: 'b0};
		e2m3_c2_pipe       <= '{default: 'b0};
		e2m3_data_in_pipe  <= '{default: 'b0};
		
		e2m1_c1_pipe       <= '{default: 'b0};
		e2m1_c2_pipe       <= '{default: 'b0};
		e2m1_data_in_pipe  <= '{default: 'b0};
	end else begin
		e3m2_c1_pipe       <= e3m2_c1;
		e3m2_c2_pipe       <= e3m2_c2;
		e3m2_data_in_pipe  <= e3m2_data_in;
		                      
		fixed_c1_pipe      <= fixed_c1;
		fixed_c2_pipe      <= fixed_c2;
		fixed_data_in_pipe <= fixed_data_in;
		                      
		e2m3_c1_pipe       <= e2m3_c1;
		e2m3_c2_pipe       <= e2m3_c2;
		e2m3_data_in_pipe  <= e2m3_data_in;
		                      
		e2m1_c1_pipe       <= e2m1_c1;
		e2m1_c2_pipe       <= e2m1_c2;
		e2m1_data_in_pipe  <= e2m1_data_in;
	end
end

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_2_sh_exp_c1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c1_sh_exp),
	.pipe_out(w_reg_c1_sh_exp_pipe2)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_2_sh_exp_c2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c2_sh_exp),
	.pipe_out(w_reg_c2_sh_exp_pipe2)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_2_sh_exp (
	.clk(clk),
	.rst(rst),
	.pipe_in(data_in_sh_exp_pipe),
	.pipe_out(data_in_sh_exp_pipe2)
);

// Dot engine (out: 70b vector)
fixed_input_mxfp_dot
u_fixed_input_mxfp_dot_col1 (
	.i_mxfp_mode(i_mxfp_mode),

	.i_e3m2_a(e3m2_data_in_pipe),
	.i_e3m2_b(e3m2_c1_pipe),

	.i_fixed_a(fixed_data_in_pipe),
	.i_fixed_b(fixed_c1_pipe),

	.i_e2m3_a(e2m3_data_in_pipe),
	.i_e2m3_b(e2m3_c1_pipe),

	.i_e2m1_a(e2m1_data_in_pipe),
	.i_e2m1_b(e2m1_c1_pipe),

	.o_fixed_result(dot_out_col1)
);

fixed_input_mxfp_dot
u_fixed_input_mxfp_dot_col2 (
	.i_mxfp_mode(i_mxfp_mode),

	.i_e3m2_a(e3m2_data_in_pipe),
	.i_e3m2_b(e3m2_c2_pipe),

	.i_fixed_a(fixed_data_in_pipe),
	.i_fixed_b(fixed_c2_pipe),

	.i_e2m3_a(e2m3_data_in_pipe),
	.i_e2m3_b(e2m3_c2_pipe),

	.i_e2m1_a(e2m1_data_in_pipe),
	.i_e2m1_b(e2m1_c2_pipe),

	.o_fixed_result(dot_out_col2)
);

// Pipe 3 (out: 32b extended from the 20b) ?
pipeline #(.W(FIXED_RESULT_WIDTH), .STAGES(1)) PIPE_3_dot_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col1),
	.pipe_out(dot_out_col1_pipe)
);

pipeline #(.W(FIXED_RESULT_WIDTH), .STAGES(1)) PIPE_3_dot_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col2),
	.pipe_out(dot_out_col2_pipe)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_3_in_sh_exp (
	.clk(clk),
	.rst(rst),
	.pipe_in(data_in_sh_exp_pipe2),
	.pipe_out(data_in_sh_exp_pipe3)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_3_w_reg_c1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c1_sh_exp_pipe2),
	.pipe_out(w_reg_c1_sh_exp_pipe3)
);

pipeline #(.W(SH_EXP_WIDTH), .STAGES(1)) PIPE_3_w_reg_c2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(w_reg_c2_sh_exp_pipe2),
	.pipe_out(w_reg_c2_sh_exp_pipe3)
);

// CPA Adder (used for FXP Tensor Mode but in this datapath nonetheless)
assign adder_out_col1 = dot_out_col1_pipe + '0; // TODO, not sure what to do about this
assign adder_out_col2 = dot_out_col2_pipe + '0;

// FXP to FP32
config_fix2fp32  #(
	.INPUT_WIDTH(FIXED_RESULT_WIDTH)
) u_fix2fp32_col1 (
	.i_exponent_correction(exponent_correction),
	.i_fixed(adder_out_col1),
	.i_shared_exp_a(data_in_sh_exp_pipe3),
	.i_shared_exp_b(w_reg_c1_sh_exp_pipe3),
	.o_fp(fix2float_out_col1)
);

config_fix2fp32  #(
	.INPUT_WIDTH(FIXED_RESULT_WIDTH)
) u_fix2fp32_col2 (
	.i_exponent_correction(exponent_correction),
	.i_fixed(adder_out_col2),
	.i_shared_exp_a(data_in_sh_exp_pipe3),
	.i_shared_exp_b(w_reg_c2_sh_exp_pipe3),
	.o_fp(fix2float_out_col2)
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
