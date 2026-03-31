module transpose #(
    parameter ROWS = 16,// input rows
    parameter COLS = 16, // input columns
    parameter DATA_WIDTH = 16
) (
    input logic clk,
    input logic valid_in,
    output logic valid_out,
    input logic [DATA_WIDTH-1:0] in_data [ROWS][COLS],
    output logic [DATA_WIDTH-1:0] out_data [COLS][ROWS]
);

always_ff @(posedge clk) begin
    valid_out <= valid_in;
    for (int i = 0; i < ROWS; i++) begin
        for (int j = 0; j < COLS; j++) begin
            out_data[j][i] <= in_data[i][j];
        end
    end
end
    
endmodule