module causal_mask #(
    parameter N = 128 // context width (square matrix)
) (
    input  logic        clk,
    input  logic        valid_in,
    output logic        valid_out,
    input  logic [31:0] in_data  [N][N],
    output logic [31:0] out_data [N][N]
);

// FP32 negative infinity: sign=1, exp=0xFF, mantissa=0
localparam logic [31:0] NEG_INF = 32'hFF800000;

always_ff @(posedge clk) begin
    valid_out <= valid_in;
    for (int i = 0; i < N; i++) begin
        for (int j = 0; j < N; j++) begin
            if (j > i)
                out_data[i][j] <= NEG_INF;
            else
                out_data[i][j] <= in_data[i][j];
        end
    end
end

endmodule
