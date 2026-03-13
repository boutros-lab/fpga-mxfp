module transpose #(
    parameter M = 16,// input rows
    parameter N = 16, // input columns
    parameter DATA_WIDTH = 16
) (
    input logic clk,
    input logic [DATA_WIDTH-1:0] in_data [M][N],
    output logic [DATA_WIDTH-1:0] out_data [N][M]
);

always_ff @(posedge clk) begin
    for (int i = 0; i < M; i++) begin
        for (int j = 0; j < N; j++) begin
            out_data[j][i] <= in_data[i][j];
        end
    end
end
    
endmodule