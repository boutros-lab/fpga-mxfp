import pkg_aitb::*;

module aitb_top (
	input logic clk,
	input logic rst,
//	input logic [1:0] acc_mode,
	input logic acc_en,
	input logic zero_en,
	input logic load_bb_one,
	input logic load_bb_two,
	input logic load_buf_sel,
	input logic signed [DATA_WIDTH-1:0] data_in [0:DOT_LENGTH-1],
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


logic signed [DATA_WIDTH-1:0] data_in_pipe [0:DOT_LENGTH-1];
logic [DATA_WIDTH-1:0] data_in_sh_exp_pipe;
logic signed [DATA_WIDTH-1:0] w_reg_c1 [0:DOT_LENGTH-1];
logic [DATA_WIDTH-1:0] w_reg_c1_sh_exp;
logic signed [DATA_WIDTH-1:0] w_reg_c2 [0:DOT_LENGTH-1];
logic [DATA_WIDTH-1:0] w_reg_c2_sh_exp;
logic signed [DOT_OUT_WIDTH-1:0] dot_out_col1;
logic [7:0] dot_out_col1_sh_exp;
logic signed [DOT_OUT_WIDTH-1:0] dot_out_col2;
logic [7:0] dot_out_col2_sh_exp;
logic signed [DOT_OUT_WIDTH-1:0] dot_out_col1_pipe;
logic [7:0] dot_out_col1_sh_exp_pipe;
logic signed [DOT_OUT_WIDTH-1:0] dot_out_col2_pipe;
logic [7:0] dot_out_col2_sh_exp_pipe;
logic signed [DOT_OUT_WIDTH-1:0] adder_out_col1;
logic signed [DOT_OUT_WIDTH-1:0] adder_out_col2;
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

// Pipe 1 (out: 2 8bx10 vectors)
generate
	for (genvar i = 0; i < DOT_LENGTH; i++) begin
		pipeline #(.W(DATA_WIDTH), .STAGES(1)) PIPE_1_data_in (
			.clk(clk),
			.rst(rst),
			.pipe_in(data_in[i]),
			.pipe_out(data_in_pipe[i])
		);
	end
	pipeline #(.W(8), .STAGES(1)) PIPE_1_sh_exp (
		.clk(clk),
		.rst(rst),
		.pipe_in(shared_exponent),
		.pipe_out(data_in_sh_exp_pipe)
	);
endgenerate

// Dot engine (out: 20b vector)
dot dot_col1 (
	.data_in(data_in_pipe),
	.w_reg(w_reg_c1),
	.data_in_sh_exp(data_in_sh_exp_pipe),
	.w_reg_sh_exp(w_reg_c1_sh_exp),
	.dot_out(dot_out_col1),
	.sh_exp_out(dot_out_col1_sh_exp)
);

dot dot_col2 (
	.data_in(data_in_pipe),
	.w_reg(w_reg_c2),
	.data_in_sh_exp(data_in_sh_exp_pipe),
	.w_reg_sh_exp(w_reg_c2_sh_exp),
	.dot_out(dot_out_col2),
	.sh_exp_out(dot_out_col2_sh_exp)
);

// Pipe 2 (out: 32b extended from the 20b) ?
pipeline #(.W(DOT_OUT_WIDTH), .STAGES(1)) PIPE_2_dot_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col1),
	.pipe_out(dot_out_col1_pipe)
);
pipeline #(.W(8), .STAGES(1)) PIPE_2_dot_sh_exp_col1 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col1_sh_exp),
	.pipe_out(dot_out_col1_sh_exp_pipe)
);

pipeline #(.W(DOT_OUT_WIDTH), .STAGES(1)) PIPE_2_dot_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col2),
	.pipe_out(dot_out_col2_pipe)
);
pipeline #(.W(8), .STAGES(1)) PIPE_2_dot_sh_exp_col2 (
	.clk(clk),
	.rst(rst),
	.pipe_in(dot_out_col2_sh_exp),
	.pipe_out(dot_out_col2_sh_exp_pipe)
);

// CPA Adder (used for FXP Tensor Mode but in this datapath nonetheless)
assign adder_out_col1 = dot_out_col1_pipe + '0;
assign adder_out_col2 = dot_out_col2_pipe + '0;

// FXP to FP32
fix2fp32 FXP2FP32_col1 (
	.fix_in(adder_out_col1),
	.shared_exp(dot_out_col1_sh_exp_pipe),
	.fp32_out(fix2float_out_col1)
);

fix2fp32 FXP2FP32_col2 (
	.fix_in(adder_out_col2),
	.shared_exp(dot_out_col2_sh_exp_pipe),
	.fp32_out(fix2float_out_col2)
);
// PIPE 3
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
	//.Y(fp32_cascade_in_col1_pipe),
	.Y(acc_mux_out_col1),
	.R(fp32_alu_out_col1)
);
ieee_fp32_add FP32_ALU_col2 (
	.X(fix2float_out_col2_pipe),
	//.Y(fp32_cascade_in_col2_pipe),
	.Y(acc_mux_out_col2),
	.R(fp32_alu_out_col2)
);

// Output PIPE
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
/*
tennm_dsp_prime		tennm_dsp_prime_component (
			 .clk (clk),
			 .ena (1'b1),
			 .acc_en (acc_mode[0]),
			 .zero_en (acc_mode[1]),
			 .load_bb_one (load_en),
			 .load_bb_two (1'b0),
			 .load_buf_sel (1'b0),
			 .shared_exponent (shared_exponent),
			 .clr ({rst,rst}),

			 .data_in({16'b0,data_in[10],data_in[9],data_in[8],data_in[7],data_in[6],data_in[5],data_in[4],data_in[3],data_in[2],data_in[1]}),

			 .cascade_data_in ({32'b0,fp32_cascade_in}),
			 .cascade_data_out ({cascade_data_out_col_2_w,fp32_cascade_out}),
			 .result_l({fp32_col_2_w[4:0],fp32_dot_out[31:0]}),
			 .result_h({fp32_col_2_flag_w[3:0],fp32_flags[3:0],fp32_col_2_w[31:5]}));
*/
