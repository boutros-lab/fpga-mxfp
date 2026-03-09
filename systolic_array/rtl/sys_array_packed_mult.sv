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

    // Each row has its input delayed by 1 cycle compared to the previous row.
    // Each column has its input delayed by 1 cycle compared to the previous col.
    logic [DATA_MX_W-1:0] w_row_delayed [N-1:0][N-1:0][DOT_LEN-1:0];
    logic w_valid_delayed [N-1:0][N-1:0];

    logic [DATA_MX_W-1:0] x_col_delayed [N-1:0][N-1:0][DOT_LEN-1:0][NUM_OPS-1:0];
    logic x_valid_delayed [N-1:0][N-1:0];

endmodule