module sys_array_aitb #(
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
    // TODO: need to know what the PE output latency ...
    localparam int PE_OUT_LAT = 0,
    localparam NUM_OPS = MUL_WIDTH / 2 / (1 + MAN_W),
    localparam FIXED_POINT_W = 1 + 2 * (MAN_W + 1) + 2 ** (EXP_W + 1) + $clog2(DOT_LEN)
) (
    input clk,
    input rst,
    // Weight interface (from left of the array)
    // Weights shifted from left to right
    input logic weights_valid_left_i [N-1:0],
    input logic [DATA_MX_W-1:0] weight_left_i [N-1:0][DOT_LEN-1:0],
    // Activation interface (from top of the array)
    input logic x_valid_top_i [N-1:0],
    input logic [DATA_MX_W-1:0] x_top_i [N-1:0][DOT_LEN-1:0],
    // Outputs (from bottom of the array)
    output logic [FIXED_POINT_W-1:0] dot_fixed_o [N-1:0][N-1:0][NUM_OPS-1:0],
    output logic valid_o [N-1:0][N-1:0]
);

    // TODO: Currently no scales because the underlying packed_mult dot does not support them yet

    // Boundary delay
    // Each row has its input delayed by 1 cycle compared to the previous row.
    // Each column has its input delayed by 1 cycle compared to the previous col.
    logic [DATA_MX_W-1:0] w_row_delayed [N-1:0][N-1:0][DOT_LEN-1:0];
    logic w_row_valid_delayed [N-1:0][N-1:0]; // redundant, will only keep the activation like for the other SA

    logic [DATA_MX_W-1:0] x_col_delayed [N-1:0][N-1:0][DOT_LEN-1:0][NUM_OPS-1:0];
    logic x_col_valid_delayed [N-1:0][N-1:0];

    // Boundary delay
    integer r, c, i, n;
    always_ff @( posedge clk ) begin
        if (rst) begin
            w_row_delayed <= '0;
            w_row_valid_delayed <= '0;
            x_col_delayed <= '0;
            x_col_valid_delayed <= '0;
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
                        w_row_delayed[r][0][i] <= w_row_delayed[r][c-1][i];
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

                for (r = 0; r < N; r++) begin
                    x_col_valid_delayed[c][r] <= x_col_valid_delayed[c][r-1];
                    for (i = 0; i < DOT_LEN; i++) begin
                        for (n = 0; n < NUM_OPS; n++) begin
                            x_col_delayed[c][r][i][n] <= x_col_delayed[c][r-1][i][n];
                        end
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

    // Weight pipeline implementation
    // - Weights go right every cycle
    always_ff @( posedge clk ) begin
        if (rst) begin
            w_pipe <= '0;
            w_valid_pipe <= '0;
        end
        else begin
            for (r = 0; r < N; r++) begin
                // Column 0 takes inputs
                w_valid_pipe[r][0] <= weights_valid_left_i[r];
                for (i = 0; i < DOT_LEN; i++) begin
                    w_pipe[r][0][i] <= weight_left_i[r][i];
                end

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
        end
        else begin
            for (c = 0; c < N; c++) begin
                // Row 0 takes inputs
                x_valid_pipe[0][c] <= x_valid_top_i[c];
                for (i = 0; i < DOT_LEN; i++) begin
                    for (n = 0; n < NUM_OPS; n++) begin
                        x_pipe[0][c][i][n] <= x_top_i[c][i][n];
                    end
                end

                for (r = 1; r < N; r++) begin
                    x_valid_pipe[r][c] <= x_valid_pipe[r-1][c];
                    for (i = 0; i < DOT_LEN; i++) begin
                        for (n = 0; n < NUM_OPS; n++) begin
                            x_pipe[r][c][i][n] <= x_pipe[r-1][c][i][n];
                        end
                    end
                end
            end
        end
    end


endmodule