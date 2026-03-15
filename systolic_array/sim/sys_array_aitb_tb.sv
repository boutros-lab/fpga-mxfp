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
    
    // Read hex files
    logic hex_loaded_done;
    logic [DATA_MX_W-1:0] w0_vec_mem [0:DOT_LEN-1];
    logic [DATA_MX_W-1:0] x0_vec_mem [0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] w0_shared_exp_mem [0:0];
    logic [SHARED_EXP_W-1:0] x0_shared_exp_mem [0:0];
    logic [DATA_OUT_W-1:0] gold_dot_mem [0:0];
    initial begin : LOAD_HEX
        hex_loaded_done = 1'b0;
        $display("[%0t] Reading hex files...", $time);

        $readmemh("../data_e2_m3_t1/w0_vector_a.hex", w0_vec_mem);
        $readmemh("../data_e2_m3_t1/x0_vector_b.hex", x0_vec_mem);
        $readmemh("../data_e2_m3_t1/w0_shared_exp_a.hex", w0_shared_exp_mem);
        $readmemh("../data_e2_m3_t1/x0_shared_exp_b.hex", x0_shared_exp_mem);
        $readmemh("../data_e2_m3_t1/w0_dot_x0_fp32_result.hex", gold_dot_mem);

        $display("[%0t] Finished reading hex files.", $time);
        hex_loaded_done = 1'b1;
    end

    // Signals for DUT
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

    // Golden signals
    logic [DATA_OUT_W-1:0] dot_fp32_o_gold [0:N-1][0:N-1];

    integer i, j;
    initial begin : DRIVER
        wait(hex_loaded_done);
        // Initialize inputs
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
        
        // Load in hex values
        weight_shared_exp_left_i_dut[0] = w0_shared_exp_mem[0];
        x_shared_exp_top_i_dut[0] = x0_shared_exp_mem[0];
        for (j = 0; j < DOT_LEN; j = j + 1) begin
            weight_left_i_dut[0][j] = w0_vec_mem[j];
            x_top_i_dut[0][j] = x0_vec_mem[j];
        end
        dot_fp32_o_gold[0][0] = gold_dot_mem[0];

        // Wait a few cycles for clarity
        repeat (4) @(posedge clk);

        // Place ourselves on a negative edge
        @(negedge clk);

        // Generate first weights, activations and the golden outputs
        $finish;

    end

    // "Golden" model
    function automatic shortreal dot (shortreal vec1[], shortreal vec2[], byte shared_exp1, byte shared_exp2);
        int corrected_exp = shared_exp1-127+shared_exp2-127;
        dot = 0.0;

        foreach (vec1[i])
            dot += vec1[i] * vec2[i]; 
        dot = shortreal'(dot * (2.0 ** (corrected_exp))); // 127 is exponent bias from OCP-MX Standard
    endfunction

    function automatic shortreal to_fp32 (int fp_bits);

        localparam int M = MAN_W;
        localparam int E = EXP_W;

        int BIAS = (1 << (E-1)) - 1;
        //logic [M+E:0] fp_bits = bits[M+E:0];

        shortreal sign = fp_bits[M+E] ? -1.0 : 1.0;
        int M_bits = fp_bits[M-1:0];
        int E_bits = fp_bits[M+E-1:M];



        if (M_bits == 0 && E_bits == 0) begin // ZERO
            to_fp32 = sign * 0.0;
        end
        else if (E_bits == 0) begin //CURSED SUBNORMALS
            to_fp32 = sign * (2.0 ** (1 - BIAS)) * (M_bits / shortreal'(1 << M));
        end
        else begin // NORMALs
            to_fp32 = sign * (2.0 ** (E_bits - BIAS)) * (1.0 + M_bits / shortreal'(1 << M));
        end

    endfunction

endmodule