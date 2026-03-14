`timescale 1ns/1ps
module sys_array_aitb_tb;
    localparam N = 1;
    localparam MAN_W = 3;
    localparam EXP_W = 2;
    localparam DATA_MX_W = 1 + MAN_W + EXP_W;
    localparam SHARED_EXP_W = 8;
    localparam FP_BIAS = 1;
    localparam SHARED_EXP_BIAS = 127;
    localparam DOT_LEN = 32;
    localparam DATA_OUT_W = 32;
    
    logic clk;
    logic rst;
    logic is_load_phase_i_dut;
    logic load_en_all_i_dut;
    logic [DATA_MX_W-1:0] weight_left_i_dut [0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] weight_shared_exp_left_i_dut [0:N-1];
    logic valid_top_i_dut [0:N-1];
    logic [DATA_MX_W-1:0] x_top_i_dut [0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] x_shared_exp_top_i_dut [0:N-1];
    logic [DATA_OUT_W-1:0] dot_fp32_o_dut [0:N-1][0:N-1];
    logic valid_o_dut [0:N-1][0:N-1];
    logic [3:0] fp32_flags_o_dut [0:N-1][0:N-1][0:3];
    // DUT
    sys_array_aitb #(
        .N(N),
        .MAN_W(MAN_W),
        .EXP_W(EXP_W),
        .DATA_MX_W(DATA_MX_W),
        .SHARED_EXP_W(SHARED_EXP_W),
        .FP_BIAS(FP_BIAS),
        .SHARED_EXP_BIAS(SHARED_EXP_BIAS),
        .DOT_LEN(DOT_LEN),
        .DATA_OUT_W(DATA_OUT_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .is_load_phase_i(is_load_phase_i_dut),
        .load_en_all_i(load_en_all_i_dut),
        .weight_left_i(weight_left_i_dut),
        .weight_shared_exp_left_i(weight_shared_exp_left_i_dut),
        .valid_top_i(valid_top_i_dut),
        .x_top_i(x_top_i_dut),
        .x_shared_exp_top_i(x_shared_exp_top_i_dut),
        .dot_fp32_o(dot_fp32_o_dut),
        .valid_o(valid_o_dut),
        .fp32_flags_o(fp32_flags_o_dut)
    );

    // CLK Gen (100 MHz)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Reset: assert for a few clock cycles
    initial begin
        rst = 1'b1;
        repeat (4) @(posedge clk);
        rst = 1'b0;
    end

    initial begin : DRIVER
        // Initialize inputs
        integer i, j;

        is_load_phase_i_dut = 1'b0;
        load_en_all_i_dut = 1'b0;

        for (i = 0; i < N; i = i + 1) begin
            weight_shared_exp_left_i_dut[i] = '0;
            valid_top_i_dut[i] = 1'b0;
            x_shared_exp_top_i_dut[i] = '0;
            for (j = 0; j < DOT_LEN; j = j + 1) begin
                weight_left_i_dut[i][j] = '0;
                x_top_i_dut[i][j] = '0;
            end
        end

        // Wait for out of reset
        @(negedge rst);
        
        // Wait a few cycles for clarity
        repeat (4) @(posedge clk);

        // Place ourselves on a negative edge
        @(negedge clk);
        
    end
endmodule