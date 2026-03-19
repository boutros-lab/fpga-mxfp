module attention #(
    parameter N = 128, // context width
    parameter D = 2048, // embedding dimension
    parameter A = 128 // attention dimension
) (
    logic [15:0] x [D][N]
);
    
endmodule