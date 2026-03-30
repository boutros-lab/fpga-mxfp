module softmax #(
    parameter N = 128 // row length (operates row-wise on N×N matrix)
) (
    input  logic        clk,
    input  logic        valid_in,
    output logic        valid_out,
    input  logic [31:0] in_data  [N][N],
    output logic [31:0] out_data [N][N]
);

// Pipeline:
//   Stage 1: find max per row
//   Stage 2: subtract max, compute exp per element
//   Stage 3: sum exp values per row
//   Stage 4: divide each exp by row sum

//  Stage 1 : Row max
logic [31:0] s1_data [N][N];
logic [31:0] s1_row_max [N];
logic        s1_valid;

always_ff @(posedge clk) begin
    s1_valid <= valid_in;
    for (int i = 0; i < N; i++) begin
        automatic shortreal mx = $bitstoshortreal(in_data[i][0]);
        for (int j = 1; j < N; j++) begin
            automatic shortreal v = $bitstoshortreal(in_data[i][j]);
            if (v > mx) mx = v;
        end
        s1_row_max[i] <= $shortrealtobits(mx);
        for (int j = 0; j < N; j++) begin
            s1_data[i][j] <= in_data[i][j];
        end
    end
end

//  Stage 2: exp(x - max)
logic [31:0] s2_exp [N][N];
logic        s2_valid;

always_ff @(posedge clk) begin
    s2_valid <= s1_valid;
    for (int i = 0; i < N; i++) begin
        automatic shortreal mx = $bitstoshortreal(s1_row_max[i]);
        for (int j = 0; j < N; j++) begin
            automatic shortreal v = $bitstoshortreal(s1_data[i][j]);
            automatic shortreal diff = v - mx;
            // exp(-inf) = 0, handled naturally by shortreal math
            automatic shortreal e = $exp(diff);
            s2_exp[i][j] <= $shortrealtobits(e);
        end
    end
end

// Stage 3: sum of exp per row
logic [31:0] s3_exp [N][N];
logic [31:0] s3_row_sum [N];
logic        s3_valid;

always_ff @(posedge clk) begin
    s3_valid <= s2_valid;
    for (int i = 0; i < N; i++) begin
        automatic shortreal s = 0.0;
        for (int j = 0; j < N; j++) begin
            s = s + $bitstoshortreal(s2_exp[i][j]);
            s3_exp[i][j] <= s2_exp[i][j];
        end
        s3_row_sum[i] <= $shortrealtobits(s);
    end
end

// Stage 4: divide
always_ff @(posedge clk) begin
    valid_out <= s3_valid;
    for (int i = 0; i < N; i++) begin
        automatic shortreal s = $bitstoshortreal(s3_row_sum[i]);
        for (int j = 0; j < N; j++) begin
            automatic shortreal e = $bitstoshortreal(s3_exp[i][j]);
            out_data[i][j] <= $shortrealtobits(e / s);
        end
    end
end

endmodule
