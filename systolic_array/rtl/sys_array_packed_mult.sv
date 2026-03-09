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
    // TODO: adapt some of the below for the packed multiplier dot
    input clk,
    input rst,
    input logic is_load_phase_i,
    // Weight interface (from left of the array)
    // All rows loaded at the same time.
    // The load_en_all signal has to be asserted (high) 
    // when the last weight enters.
    input  logic load_en_all_i,
    input logic [DATA_MX_W-1:0] weight_left_i [0:N-1][0:DOT_LEN-1],
    input logic [SHARED_EXP_W-1:0] weight_shared_exp_left_i [0:N-1],
    // Activation interface (from top of the array)
    input  logic valid_top_i [0:N-1],
    input logic [DATA_MX_W-1:0] x_top_i [0:N-1][0:DOT_LEN-1],
    input logic [SHARED_EXP_W-1:0] x_shared_exp_top_i [0:N-1],
    // Outputs (from bottom of the array)
    output logic [DATA_OUT_W-1:0] dot_fp32_o [0:N-1][0:N-1],
    output logic valid_o [0:N-1][0:N-1],
    output [3:0] fp32_flags_o [0:N-1][0:N-1][0:3]
);
endmodule