module sys_array_packed_mult #(
    // Size of the array (NxN)
    parameter N = 2,
    // Number format params
    parameter MAN_W = 3,
    parameter EXP_W = 4,
    parameter DATA_MX_W = 1 + MAN_W + EXP_W,
    parameter SHARED_EXP_W = 8,
    // MX-FP Bias
    parameter FP_BIAS = 1,
    parameter SHARED_EXP_BIAS = 127,
    // Packed multiplier specific parameters
    parameter MUL_WIDTH = 18,
    // Number of elements in vector to "dot" aka block size
    parameter DOT_LEN = 32,
    // PEs compute a FP32 output
    parameter DATA_OUT_W = 32,

    // Local params
    localparam NUM_OPS = MUL_WIDTH / 2 / (1 + MAN_W)
) (
    input clk,
    input rst,
    // Weight interface (from left of the array)
    // Weights shifted from left to right
    input logic weights_valid_left_i [N-1:0],
    input logic [DATA_MX_W-1:0] weight_left_i [N-1:0][DOT_LEN-1:0],
    // Activation interface (from top of the array)
    input logic x_valid_top_i [N-1:0],
    input logic [DATA_MX_W-1:0] x_top_i [N-1:0][DOT_LEN-1:0][NUM_OPS-1:0],
    input logic [SHARED_EXP_W-1:0] x_shared_exp_top_i [N-1:0][NUM_OPS-1:0],
    // Outputs (from bottom of the array)
    output logic [DATA_OUT_W-1:0] dot_fp32_o [N-1:0][N-1:0][NUM_OPS-1:0],
    output logic valid_o [N-1:0][N-1:0]
);

    // Boundary delay
    // Each row has its input delayed by 1 cycle compared to the previous row.
    // Each column has its input delayed by 1 cycle compared to the previous col.
    logic [DATA_MX_W-1:0] w_row_delayed [N-1:0][N-1:0][DOT_LEN-1:0];
    logic w_row_valid_delayed [N-1:0][N-1:0];

    logic [DATA_MX_W-1:0] x_col_delayed [N-1:0][N-1:0][DOT_LEN-1:0][NUM_OPS-1:0];
    logic x_col_valid_delayed [N-1:0][N-1:0];
    logic [SHARED_EXP_W-1:0] x_shared_exp_col_delayed [N-1:0][N-1:0][NUM_OPS-1:0];

    // Boundary delay
    integer r, c, i, n;
    always_ff @( posedge clk ) begin
        if (rst) begin
            w_row_delayed <= '0;
            w_row_valid_delayed <= '0;
            x_col_delayed <= '0;
            x_col_valid_delayed <= '0;
            x_shared_exp_col_delayed <= '0;
        end
        else begin
            // Weight delay
            // The different rows
            for (r = 0; r < N; r++) begin
                // First "column" of the pipeline gets the inputs
                w_row_valid_delayed[r][0] <= weights_valid_left_i[r];
                for (i = 0; i < DOT_LEN; i++) begin
                    w_row_delayed[r][0][i] <= weight_left_i[r][i];
                end

                // Additional delays get delay from previous stage
                for (c = 1; c < N; c++) begin
                    w_row_valid_delayed[r][c] <= w_row_valid_delayed[r][c-1];
                    for (i = 0; i < DOT_LEN; i++) begin
                        w_row_delayed[r][c][i] <= w_row_delayed[r][c-1][i];
                    end
                end
            end

            // Activation delay
            // The different columns
            for (c = 0; c < N; c++) begin
                // First "row" of the pipeline gets the inputs
                x_col_valid_delayed[c][0] <= x_valid_top_i[c];
                for (i = 0; i < DOT_LEN; i++) begin
                    for (n = 0; n < NUM_OPS; n++) begin
                       x_col_delayed[c][0][i][n] <= x_top_i[c][i][n]; 
                    end
                end
                for (n = 0; n < NUM_OPS; n++) begin
                    x_shared_exp_col_delayed[c][0][n] <= x_shared_exp_top_i[c][n];
                end

                // Additional delays get delay from previous stage
                for (r = 1; r < N; r++) begin
                    x_col_valid_delayed[c][r] <= x_col_valid_delayed[c][r-1];
                    for (i = 0; i < DOT_LEN; i++) begin
                        for (n = 0; n < NUM_OPS; n++) begin
                            x_col_delayed[c][r][i][n] <= x_col_delayed[c][r-1][i][n];
                        end
                    end
                    for (n = 0; n < NUM_OPS; n++) begin
                        x_shared_exp_col_delayed[c][r][n] <= x_shared_exp_col_delayed[c][r-1][n];
                    end
                end
            end

        end
    end

    // Weight pipeline (weights shift to the right)
    logic [DATA_MX_W-1:0] w_pipe [N-1:0][N-1:0][DOT_LEN-1:0];
    logic w_valid_pipe [N-1:0][N-1:0];
    
    // Activation pipeline (activations shift down)
    logic [DATA_MX_W-1:0] x_pipe [N-1:0][N-1:0][DOT_LEN-1:0][NUM_OPS-1:0];
    logic x_valid_pipe [N-1:0][N-1:0];
    logic [SHARED_EXP_W-1:0] x_shared_exp_pipe [N-1:0][N-1:0][NUM_OPS-1:0];

    // Weight pipeline implementation
    // - Weights go right every cycle
    always_ff @( posedge clk ) begin
        if (rst) begin
            w_pipe <= '0;
            w_valid_pipe <= '0;
        end
        else begin
            for (r = 0; r < N; r++) begin
                // Column 0 takes inputs from the boundary delay
                if (r == 0) begin
                    // Row 0 has no delay
                    w_valid_pipe[r][0] <= weights_valid_left_i[r];
                    for (i = 0; i < DOT_LEN; i++) begin
                        w_pipe[r][0][i] <= weight_left_i[r][i];
                    end
                end
                else begin
                    // Other rows have delay
                    // row 1 has a 1 cycle delay so from delayed[r-1 = 1-1 = 0]
                    w_valid_pipe[r][0] <= w_row_valid_delayed[r-1];
                    for (i = 0; i < DOT_LEN; i++) begin
                        w_pipe[r][0][i] <= w_row_delayed[r][r-1][i];
                    end
                end

                // Other columns take from the previous column
                for (c = 1; c < N; c++) begin
                    w_valid_pipe[r][c] <= w_valid_pipe[r][c-1];
                    for (i = 0; i < DOT_LEN; i++) begin
                        w_pipe[r][c][i] <= w_pipe[r][c-1][i];
                    end
                end

            end
        end
    end

    // Activation pipeline implementation
    // - Activations go down every cycle
    always_ff @( posedge clk ) begin
        if (rst) begin
            x_pipe <= '0;
            x_valid_pipe <= '0;
            x_shared_exp_pipe <= '0;
        end
        else begin
            for (c = 0; c < N; c++) begin
                // Row 0 takes inputs from delayed pipeline
                if (c == 0) begin
                    // Column 0 has no delay
                    x_valid_pipe[0][c] <= x_valid_top_i[c];
                    for (i = 0; i < DOT_LEN; i++) begin
                        for (n = 0; n < NUM_OPS; n++) begin
                            x_pipe[0][c][i][n] <= x_top_i[c][i][n];
                        end
                    end
                    for (n = 0; n < NUM_OPS; n++) begin
                        x_shared_exp_pipe[0][c][n] <= x_shared_exp_top_i[c][n];
                    end
                end
                else begin
                    // Next columns has delays
                    x_valid_pipe[0][c] <= x_col_valid_delayed[c][c-1];
                    for (i = 0; i < DOT_LEN; i++) begin
                        x_pipe[0][c][i][n] <= x_col_delayed[c][c-1][i][n];
                    end
                    for (n = 0; n < NUM_OPS; n++) begin
                        x_shared_exp_pipe[0][c][n] <= x_shared_exp_col_delayed[c][c-1][n];
                    end
                end

                // Other rows take above row
                for (r = 1; r < N; r++) begin
                    x_valid_pipe[r][c] <= x_valid_pipe[r-1][c];
                    for (i = 0; i < DOT_LEN; i++) begin
                        for (n = 0; n < NUM_OPS; n++) begin
                            x_pipe[r][c][i][n] <= x_pipe[r-1][c][i][n];
                        end
                    end
                    for (n = 0; n < NUM_OPS; n++) begin
                        x_shared_exp_pipe[r][c][n] <= x_shared_exp_pipe[r-1][c][n];
                    end
                end
                
            end
        end
    end

    // Instantiate PEs
    genvar gr, gc;
    generate
        for (gr = 0; gr < N; gr++) begin : GEN_ROW
            for (gc = 0; gc < N; gc++) begin : GEN_COL
                packed_dot_product_fp32 #(
                    .exponent_width(EXP_W),
                    .mantissa_width(MAN_W),
                    .mul_width(MUL_WIDTH),
                    .block_size(DOT_LEN)
                ) u_packed_dot_product_fp32 (
                    .clk(clk),
                    .valid_in(w_valid_pipe[gr][gc] & x_valid_pipe[gr][gc]),
                    .valid_out(valid_o[gr][gc]),
                    .operands(x_pipe[gr][gc]),
                    .sharedOperands(w_pipe[gr][gc]),
                    .shared_exponent(x_shared_exp_pipe[gr][gc]),
                    .results(dot_fp32_o[gr][gc])
                );
            end
        end
    endgenerate

endmodule