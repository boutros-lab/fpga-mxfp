module packed_matmul #(
    // Matrix dimensions
    parameter ROWS_A = 250, 
    parameter COLS_A = 400,
    parameter ROWS_B = 400,
    parameter COLS_B = 250,
    // A [ROWS_AxCOLS_A] x B [ROWS_BxCOLS_B] -> C [ROWS_AxCOLS_B]
    localparam ROWS_C = ROWS_A,
    localparam COLS_C = COLS_B,
    // Packed multiplier parameters
    parameter exponent_width = 4,
    parameter mantissa_width = 3,
    parameter mul_width = 18,
    parameter block_size = 32, // must be divisible by 2 since the DSP can handle 2 multiplications at once
    localparam num_ops = mul_width / 2 / / (1+mantissa_width), 
) (
    input logic clk,
    input logic valid_in,
    output logic valid_out,
    // input in mxfp
    input logic [1 + mantissa_width + exponent_width -1:0] matrix_a [ROWS_A-1:0][COLS_A-1:0], matrix_b [ROWS_B-1:0][COLS_B-1:0],
    // output in floating point 32
    output logic [31:0] matrix_c [ROWS_C-1:0][COLS_C-1:0]
);
    
// Every row in A is dot-producted with every column in B

// MXFP format has 

endmodule