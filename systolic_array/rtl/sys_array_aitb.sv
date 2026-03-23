module sys_array_aitb #(
    // Size of the array (NxN)
    parameter N = 2,
    // Number format params
    parameter MAN_W = 3,
    parameter EXP_W = 2,
    parameter DATA_MX_W = 1 + MAN_W + EXP_W,
    parameter SHARED_EXP_W = 8,
    // MX-FP Bias
    parameter FP_BIAS = 1,
    parameter SHARED_EXP_BIAS = 127,
    // Number of elements in vector to "dot"
    parameter DOT_LEN = 32,
    parameter PIPE = 0,
    // PEs compute a FP32 output
    parameter DATA_OUT_W = 32
) (
    input clk,
    input rst,
    input logic is_load_phase_i,
    // Weight interface (from left of the array)
    // All rows loaded at the same time.
    // The load_en_all signal has to be asserted (high) 
    // when the last weight enters.
    input logic load_en_all_i,
    input logic [DATA_MX_W-1:0] weight_left_i [0:N-1][0:DOT_LEN-1],
    input logic [SHARED_EXP_W-1:0] weight_shared_exp_left_i [0:N-1],
    // Activation interface (from top of the array)
    input logic valid_top_i [0:N-1],
    input logic [DATA_MX_W-1:0] x_top_i [0:N-1][0:DOT_LEN-1],
    input logic [SHARED_EXP_W-1:0] x_shared_exp_top_i [0:N-1],
    // Outputs (from bottom of the array)
    output logic [DATA_OUT_W-1:0] dot_fp32_col1_o [0:N-1][0:N-1],
    output logic [DATA_OUT_W-1:0] dot_fp32_col2_o [0:N-1][0:N-1],
    output logic valid_o [0:N-1][0:N-1],
    output [3:0] fp32_flags_col1_o [0:N-1][0:N-1],
    output [3:0] fp32_flags_col2_o [0:N-1][0:N-1]
);
    
    logic load_en_all_ff;
    always_ff @( posedge clk ) begin
        if (rst) begin
            load_en_all_ff <= 1'b0;
        end
        else begin
            load_en_all_ff <= load_en_all_i;
        end
    end

    // Weight pipeline (row, col, k)
    logic [DATA_MX_W-1:0] w_pipe [0:N-1][0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] w_scale_pipe [0:N-1][0:N-1];

    // Activation pipeline (row, col, k)
    logic [DATA_MX_W-1:0] x_pipe [0:N-1][0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] x_scale_pipe [0:N-1][0:N-1];
    logic valid_pipe [0:N-1][0:N-1];

    // Weight pipeline implementation
    // - Weights go right every cycle
    // - Driver must make sure to pulse load_en_all_i, 
    //   at the appropriate cycle for the weights to load
    always_ff @( posedge clk) begin
        integer r, c, i;
        if (rst) begin
            // In every row, reset every column
            for (r = 0; r < N; r++) begin
                for (c = 0; c < N; c++) begin
                    w_scale_pipe[r][c] <= '0;
                    // For each element, reset the vector
                    for (i = 0; i < DOT_LEN; i++) begin
                        w_pipe[r][c][i] <= '0;
                    end
                end
            end
        end
        else begin
            // Weights move to the right
            for (r = 0; r < N; r++) begin
                // Column 0 takes in the inputs
                w_scale_pipe[r][0] <= weight_shared_exp_left_i[r];
                for (i = 0; i < DOT_LEN; i++) begin
                    w_pipe[r][0][i] <= weight_left_i[r][i];
                end

                for (c = 1; c < N; c++) begin
                    w_scale_pipe[r][c] <= w_scale_pipe[r][c-1];
                    for (i = 0; i < DOT_LEN; i++) begin
                        w_pipe[r][c][i] <= w_pipe[r][c-1][i];
                    end 
                end
            end
        end
    end

    // Activation pipeline implementation
    // - Activations go down every cycle
    // - Driver must make activations provided when weight loading is done
    always_ff @( posedge clk) begin
        integer r, c, i;
        if (rst) begin
            // In every row, reset every column
            for (r = 0; r < N; r++) begin
                for (c = 0; c < N; c++) begin
                    valid_pipe[r][c] <= 1'b0;
                    x_scale_pipe[r][c] <= '0;
                    // For each element, reset the vector
                    for (i = 0; i < DOT_LEN; i++) begin
                        x_pipe[r][c][i] <= '0;
                    end
                end
            end
        end
        else begin
            // Activations move down
            // Treat column by column
            for (c = 0; c < N; c++) begin
                // Row 0 takes in the inputs
                valid_pipe[0][c] <= valid_top_i[c];
                x_scale_pipe[0][c] <= x_shared_exp_top_i[c];
                for (i = 0; i < DOT_LEN; i++) begin
                    x_pipe[0][c][i] <= x_top_i[c][i];
                end

                for (r = 1; r < N; r++) begin
                    valid_pipe[r][c] <= valid_pipe[r-1][c];
                    x_scale_pipe[r][c] <= x_scale_pipe[r-1][c];
                    for (i = 0; i < DOT_LEN; i++) begin
                        x_pipe[r][c][i] <= x_pipe[r-1][c][i];
                    end
                end

            end
        end
    end

    // Instantiate PEs
    genvar gr, gc, gi;
    // Signals for PEs (row, col, k)
    logic pe_valid_in [0:N-1][0:N-1];
    logic [DATA_MX_W-1:0] pe_data_in [0:N-1][0:N-1][0:DOT_LEN-1];
    logic [SHARED_EXP_W-1:0] pe_shared_exp [0:N-1][0:N-1];
    generate
        for (gr = 0; gr < N; gr++) begin : ROW_GEN
            for (gc = 0; gc < N; gc++) begin : COL_GEN

                // Gate the PE inputs by a "is_load_phase_i"
                // Since valid is only used to do computations
                assign pe_valid_in[gr][gc] = is_load_phase_i ? 1'b0 : valid_pipe[gr][gc];
                // w or x depending on phase
                assign pe_shared_exp[gr][gc] = is_load_phase_i  ? w_scale_pipe[gr][gc]
                                                                : x_scale_pipe[gr][gc];
                for (gi = 0; gi < DOT_LEN; gi++) begin
                    assign pe_data_in[gr][gc][gi] = is_load_phase_i ? w_pipe[gr][gc][gi]
                                                                    : x_pipe[gr][gc][gi];
                end

                // PE Instance
                mxfp_dot #(
                    .M(MAN_W),
                    .E(EXP_W),
                    .E_SHARED(SHARED_EXP_W),
                    .FP_BIAS(FP_BIAS),
                    .SH_BIAS(SHARED_EXP_BIAS),
                    .DOT_LEN(DOT_LEN),
                    .PIPE(PIPE)
                ) pe_inst (
                    .clk(clk),
                    .rst(rst),
                    .load_en(load_en_all_ff),
                    .valid_in(pe_valid_in[gr][gc]),
                    .mx_data_in(pe_data_in[gr][gc]),
                    .shared_exponent(pe_shared_exp[gr][gc]),
                    .fp32_dot_out_col1(dot_fp32_col1_o[gr][gc]),
                    .fp32_dot_out_col2(dot_fp32_col2_o[gr][gc]),
                    .valid_out(valid_o[gr][gc]),
                    .fp32_flags_col1(fp32_flags_col1_o[gr][gc]),
                    .fp32_flags_col2(fp32_flags_col2_o[gr][gc])
                );

            end
        end
    endgenerate

endmodule