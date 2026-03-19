`timescale 1ns/1ns

module transpose_tb;

parameter tests = 1024;
parameter M = 2;
parameter N = 4;
parameter DATA_WIDTH = 8;

logic clk;
logic [DATA_WIDTH-1:0] in_data [M][N];
logic [DATA_WIDTH-1:0] out_data [N][M];

transpose #(
    .M(M),
    .N(N),
    .DATA_WIDTH(DATA_WIDTH)
) dut (
    .clk(clk),
    .in_data(in_data),
    .out_data(out_data)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test sequence
initial begin

    $display("!!!DUT=transpose");
    $display("M=%0d", M);
    $display("N=%0d", N);
    $display("DATA_WIDTH=%0d", DATA_WIDTH);
    $display("tests=%0d", tests);

    for (int test = 0; test < tests; test++) begin

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                in_data[i][j] = $random;
            end
        end
        @(posedge clk); // Apply inputs
        @(posedge clk); // Wait for registered output

        $display("test=%0d", test);
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                $display("in_data[%0d][%0d]=%b", i, j, in_data[i][j]);
            end
        end
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < M; j++) begin
                $display("out_data[%0d][%0d]=%b", i, j, out_data[i][j]);
            end
        end

    end

    $finish;

end

endmodule
