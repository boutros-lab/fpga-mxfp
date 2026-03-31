module attention #(
    parameter N = 128, // context width
    parameter D = 2048, // embedding dimension
    parameter A = 128, // attention dimension
    // Packed multiplier parameters
    parameter exponent_width = 4,
    parameter mantissa_width = 3,
    parameter mul_width = 18,
    parameter block_size = 32, // must be divisible by 2 since the DSP can handle 2 multiplications at once
) (
    input logic [1 + exponent_width + mantissa_width - 1:0] x [N][D], W_Q [D][A], W_K [D][A], W_V [D][A], W_O [A][D],
    input logic [1 + exponent_width + mantissa_width - 1:0] W_Q_blk_exp [A][D],
    output logic [1 + exponent_width + mantissa_width - 1:0] y [D][N],
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
logic [1 + exponent_width + mantissa_width - 1:0] Q_mxfp [N][A], K_T_mxfp [A][N], V_mxfp [N][A];
logic Q_mxfp_valid, K_T_mxfp_valid, V_mxfp_valid;
fp32_to_mxfp #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .block_size(block_size),
    .freq_mhz(400) // max
) convert_Q (
    .clk(clk),
    .valid_in(Q_valid),
    .valid_out(Q_mxfp_valid),
    .in(Q),
    .out(Q_mxfp),
    .out_blk_exp() // not used
);
fp32_to_mxfp #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .block_size(block_size),
    .freq_mhz(400) // max
) convert_K_T (
    .clk(clk),
    .valid_in(K_T_valid),
    .valid_out(K_T_mxfp_valid),
    .in(K_T),
    .out(K_T_mxfp),
    .out_blk_exp() // not used
);
fp32_to_mxfp #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .block_size(block_size),
    .freq_mhz(400) // max
) convert_V (
    .clk(clk),
    .valid_in(V_valid),
    .valid_out(V_mxfp_valid),
    .in(V),
    .out(V_mxfp),
    .out_blk_exp() // not used
);

// Dot product QK^T
logic [31:0] QK_T_mxfp [N][N];
logic QK_T_valid;
packed_matmul #(
    .ROWS_A(N),
    .COLS_A(A),
    .ROWS_B(A),
    .COLS_B(N),
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) matmul_QK_T (
    .clk(clk),
    .valid_in(Q_mxfp_valid && K_T_mxfp_valid), // not accurate, but good enough for now
    .valid_out(QK_T_valid),
    .matrix_a(Q_mxfp),
    .matrix_b(K_T_mxfp),
    .matrix_c(QK_T_mxfp),
    .shared_exp_a(W_Q_blk_exp) // using the same block exponent for all rows of Q
);

// Causal mask
logic [31:0] masked [N][N];
logic masked_valid;
causal_mask #(
    .N(N)
) causal_mask_inst (
    .clk(clk),
    .valid_in(QK_T_valid),
    .valid_out(masked_valid),
    .in_data(QK_T_mxfp),
    .out_data(masked)
);

// Softmax
logic [31:0] attn_weights [N][N];
logic attn_weights_valid;
softmax #(
    .N(N)
) softmax_inst (
    .clk(clk),
    .valid_in(masked_valid),
    .valid_out(attn_weights_valid),
    .in_data(masked),
    .out_data(attn_weights)
);

// Convert attn_weights back to MXFP for matmul with V
logic [1 + exponent_width + mantissa_width - 1:0] attn_weights_mxfp [N][N];
logic attn_weights_mxfp_valid;
fp32_to_mxfp #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .block_size(block_size),
    .freq_mhz(400) // max
) convert_attn_weights (
    .clk(clk),
    .valid_in(attn_weights_valid),
    .in(attn_weights),
    .out(attn_weights_mxfp_valid),
    .out_blk_exp() // not used
);

// Matmul with V
logic [31:0] O [N][A];
logic O_valid;
packed_matmul #(
    .ROWS_A(N),
    .COLS_A(N), 
    .ROWS_B(N),
    .COLS_B(A),
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) matmul_attn_V (
    .clk(clk),
    .valid_in(attn_weights_mxfp_valid && V_mxfp_valid), 
    .valid_out(O_valid),
    .matrix_a(attn_weights_mxfp),
    .matrix_b(V_mxfp),
    .matrix_c(O)
);

// Convert attn_out to MXFP for matmul with W_O
logic [1 + exponent_width + mantissa_width - 1:0] O_mxfp [N][A];
logic O_mxfp_valid;
fp32_to_mxfp #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .block_size(block_size),
    .freq_mhz(400) // max
) convert_attn_out (
    .clk(clk),
    .valid_in(O_valid),
    .in(O),
    .out(O_mxfp_valid),
    .out_blk_exp() // not used
);

// Matmul with W_O to get final output
logic [31:0] Y [N][D];
logic Y_valid;
packed_matmul #(
    .ROWS_A(N),
    .COLS_A(A),
    .ROWS_B(A),
    .COLS_B(D),
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) matmul_Y_W_O (
    .clk(clk),
    .valid_in(O_mxfp_valid), // not accurate, but good enough for now
    .valid_out(Y_valid),
    .matrix_a(O_mxfp),
    .matrix_b(W_O),
    .matrix_c(Y)
);

// Convert final FP32 output back to MXFP
logic [1 + exponent_width + mantissa_width - 1:0] Y_mxfp [N][D];
logic Y_mxfp_valid;
fp32_to_mxfp #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .block_size(block_size),
    .freq_mhz(400) // max
) convert_out (
    .clk(clk),
    .valid_in(Y_valid),
    .valid_out(Y_mxfp_valid),
    .in(Y),
    .out(Y_mxfp),
    .out_blk_exp() // not used
);

// return Y
assign y = Y_mxfp;
assign valid_out = Y_mxfp_valid;

endmodule