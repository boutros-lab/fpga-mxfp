module attention #(
    parameter N = 128, // context width
    parameter D = 2048, // embedding dimension
    parameter A = 128 // attention dimension
    // Packed multiplier parameters
    parameter exponent_width = 4,
    parameter mantissa_width = 3,
    parameter mul_width = 18,
    parameter block_size = 32, // must be divisible by 2 since the DSP can handle 2 multiplications at once
) (
    input logic [1 + exponent_width + mantissa_width - 1:0] x [N][D], W_Q [D][A], W_K [D][A], W_V [D][A],
    output logic [1 + exponent_width + mantissa_width - 1:0] out [D][N],
    input logic clk,
    input logic valid_in,
    output logic valid_out
);

// Project to Q, K, V
logic [31:0] Q [N][A], K [N][A], V [N][A];
logic Q_valid, K_valid, V_valid;
packed_matmul #(
    .ROWS_A(N),
    .COLS_A(D),
    .ROWS_B(D),
    .COLS_B(A),
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) project_Q (
    .clk(clk),
    .valid_in(valid_in),
    .valid_out(Q_valid),
    .matrix_a(W_Q),
    .matrix_b(x),
    .matrix_c(Q)
);    
packed_matmul #(
    .ROWS_A(N),
    .COLS_A(D),
    .ROWS_B(D),
    .COLS_B(A),
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) project_K (
    .clk(clk),
    .valid_in(valid_in),
    .valid_out(K_valid), // not used
    .matrix_a(W_K),
    .matrix_b(x),
    .matrix_c(K)
);
packed_matmul #(
    .ROWS_A(N),
    .COLS_A(D),
    .ROWS_B(D),
    .COLS_B(A),
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) project_V (
    .clk(clk),
    .valid_in(valid_in),
    .valid_out(V_valid), // not used
    .matrix_a(W_V),
    .matrix_b(x),
    .matrix_c(V)
);

// Transpose K
logic [31:0] K_T [A][N];
logic K_T_valid;
transpose #(
    .ROWS(N),
    .COLS(A),
    .DATA_WIDTH(32)
) transpose_K (
    .clk(clk),
    .valid_in(valid_in), // not accurate, but good enough for now
    .valid_out(K_T_valid), // not used
    .in_data(K),
    .out_data(K_T)
);

// Convert all to MXFP


endmodule