import pkg_aitb::*;

module in_reg_bank (
	input  logic clk,
	input  logic rst,
	input  logic signed [DATA_WIDTH-1:0] data_in [0:DOT_LENGTH-1],
	input  logic [DATA_WIDTH-1:0] data_in_sh_exp,
	input  logic load_bb_one,
	input  logic load_bb_two,
	input  logic load_buf_sel,
	output logic signed [DATA_WIDTH-1:0] w_reg_c1 [0:DOT_LENGTH-1],
	output logic [DATA_WIDTH-1:0] w_reg_c1_sh_exp,
	output logic signed [DATA_WIDTH-1:0] w_reg_c2 [0:DOT_LENGTH-1],
	output logic [DATA_WIDTH-1:0] w_reg_c2_sh_exp

);

logic load_bb_one_ff;
logic load_bb_two_ff;
logic load_buf_sel_ff;


logic signed [DATA_WIDTH-1:0] bb_one_c1 [0:DOT_LENGTH-1];
logic [DATA_WIDTH-1:0] bb_one_c1_sh_exp;
logic signed [DATA_WIDTH-1:0] bb_one_c2 [0:DOT_LENGTH-1];
logic [DATA_WIDTH-1:0] bb_one_c2_sh_exp;

logic signed [DATA_WIDTH-1:0] bb_two_c1 [0:DOT_LENGTH-1];
logic [DATA_WIDTH-1:0] bb_two_c1_sh_exp;
logic signed [DATA_WIDTH-1:0] bb_two_c2 [0:DOT_LENGTH-1];
logic [DATA_WIDTH-1:0] bb_two_c2_sh_exp;

// Control signals register
always_ff @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		load_bb_one_ff <= '0;
		load_bb_two_ff <= '0;
		load_buf_sel_ff <= '0;
	end else begin
		load_bb_one_ff <= load_bb_one;
		load_bb_two_ff <= load_bb_two;
		load_buf_sel_ff <= load_buf_sel;
	end
end

// Buffer Set 1
always_ff @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		bb_one_c1 <= '{default: '0};
		bb_one_c2 <= '{default: '0};
		bb_one_c1_sh_exp <= '0;
		bb_one_c2_sh_exp <= '0;
	end else if (load_bb_one_ff == 1'b1) begin
		bb_one_c1 <= data_in;
		bb_one_c2 <= bb_one_c1;
		bb_one_c1_sh_exp <= data_in_sh_exp;
		bb_one_c2_sh_exp <= bb_one_c1_sh_exp;
	end
end

// Buffer Set 2
always_ff @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		bb_two_c1 <= '{default: '0};
		bb_two_c2 <= '{default: '0};
		bb_two_c1_sh_exp <= '0;
		bb_two_c2_sh_exp <= '0;
	end else if (load_bb_two_ff == 1'b1) begin
		bb_two_c1 <= data_in;
		bb_two_c2 <= bb_two_c1;
		bb_two_c1_sh_exp <= data_in_sh_exp;
		bb_two_c2_sh_exp <= bb_two_c1_sh_exp;
	end
end

// Output 
always_comb begin
	if (load_buf_sel_ff == 1'b0) begin
		w_reg_c1 = bb_one_c1;
		w_reg_c1_sh_exp = bb_one_c1_sh_exp;
		w_reg_c2 = bb_one_c2;
		w_reg_c2_sh_exp = bb_one_c2_sh_exp;
	end else begin
		w_reg_c1 = bb_two_c1;
		w_reg_c1_sh_exp = bb_two_c1_sh_exp;
		w_reg_c2 = bb_two_c2;
		w_reg_c2_sh_exp = bb_two_c2_sh_exp;
	end
end

endmodule
