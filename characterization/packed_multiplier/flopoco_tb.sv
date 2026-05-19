`timescale 1ns/1ns

module flopoco_tb;

logic clk;
initial begin
    clk = 0;
    forever #1 clk = ~clk;
end

// E2M1: 15-bit input, Fix2FP_S_M2_12
logic [14:0] i_e2m1;
logic [33:0] o_e2m1;
MXFP_E2M1_to_FP32 u_e2m1 (.clk(clk), .I(i_e2m1), .O(o_e2m1));

// E2M3: 19-bit input, Fix2FP_S_M6_12
logic [18:0] i_e2m3;
logic [33:0] o_e2m3;
MXFP_E2M3_to_FP32 u_e2m3 (.clk(clk), .I(i_e2m3), .O(o_e2m3));

// E3M2: 24-bit input, Fix2FP_S_M8_15
logic [23:0] i_e3m2;
logic [33:0] o_e3m2;
MXFP_E3M2_to_FP32 u_e3m2 (.clk(clk), .I(i_e3m2), .O(o_e3m2));

// E4M3: 43-bit input, Fix2FP_S_M18_24
logic [42:0] i_e4m3;
logic [33:0] o_e4m3;
MXFP_E4M3_to_FP32 u_e4m3 (.clk(clk), .I(i_e4m3), .O(o_e4m3));

// E5M2: 73-bit input, Fix2FP_S_M32_40
logic [72:0] i_e5m2;
logic [33:0] o_e5m2;
MXFP_E5M2_to_FP32 u_e5m2 (.clk(clk), .I(i_e5m2), .O(o_e5m2));

// Drive values 1..16 on successive cycles, then wait for pipeline to flush
// FloPoCo input is signed fixed-point. Integer N is represented as N << (-LSB).
// E2M1: LSB=-2, E2M3: LSB=-6, E3M2: LSB=-8, E4M3: LSB=-18, E5M2: LSB=-32
initial begin
    i_e2m1 = '0; i_e2m3 = '0; i_e3m2 = '0; i_e4m3 = '0; i_e5m2 = '0;

    for (int v = 0; v < 16; v++) begin
        @(posedge clk);
        i_e2m1 <= 15'(1 << v) << 2;
        i_e2m3 <= 19'(1 << v) << 6;
        i_e3m2 <= 24'(1 << v) << 8;
        i_e4m3 <= 43'(1 << v) << 18;
        i_e5m2 <= 73'(1 << v) << 32;
    end
    // Hold last value for remaining cycles
end

// Monitor outputs
initial begin
    for (int cyc = 0; cyc < 32; cyc++) begin
        @(posedge clk);
        #1;
        $display("cycle=%0d  E4M3: exc=%b sgn=%b exp=%0d frac=%0d  O=%b",
            cyc, o_e4m3[33:32], o_e4m3[31], o_e4m3[30:23], o_e4m3[22:0], o_e4m3);
    end
    $finish;
end

endmodule
