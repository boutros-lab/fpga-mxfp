module packed_dot_product_fp32 #(
    parameter exponent_width = 4,
    parameter mantissa_width = 3,
    parameter mul_width = 18,
    parameter block_size = 32, // must be divisible by 2 since the DSP can handle 2 multiplications at once
    localparam num_ops = mul_width / 2 / (1+mantissa_width), 
    localparam fixed_point_result_width = 1 + 2 * (mantissa_width + 1) + 2 ** (exponent_width + 1) - 2 + $clog2(block_size)
) (
    input logic clk,
    // NOTE: operands are a sequence of block-length vectors
    input logic [1 + mantissa_width + exponent_width -1:0] operands [block_size-1:0][num_ops-1:0], sharedOperands [block_size-1:0],
    input logic [7:0] shared_exponent [num_ops-1:0],
    output logic [31:0] results [num_ops-1:0]
);

wire [fixed_point_result_width-1:0] fixed_point_results [num_ops-1:0];
wire signed [fixed_point_result_width-2:0] shifted_results [num_ops-1:0];
wire [33:0] flopoco_results [num_ops-1:0];

packed_dot_product #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) u_packed_dot_product (
    .clk(clk),
    .operands(operands),
    .sharedOperands(sharedOperands),
    .results(fixed_point_results)
);

for (genvar n = 0; n < num_ops; n++) begin
    assign shifted_results[n] = $signed(fixed_point_results[n]) >>> 2;
    assign results[n] = {flopoco_results[n][31], flopoco_results[n][30:23] + shared_exponent[n], flopoco_results[n][22:0]};

    if (exponent_width == 2 && mantissa_width == 1) begin
        MXFP_E2M1_to_FP32 fx2fp (
            .clk(clk),
            .I(shifted_results[n][14:0]),
            .O(flopoco_results[n])
        );
    end else if (exponent_width == 2 && mantissa_width == 3) begin
        MXFP_E2M3_to_FP32 fx2fp (
            .clk(clk),
            .I(shifted_results[n][18:0]),
            .O(flopoco_results[n])
        );
    end else if (exponent_width == 3 && mantissa_width == 2) begin
        MXFP_E3M2_to_FP32 fx2fp (
            .clk(clk),
            .I(shifted_results[n][23:0]),
            .O(flopoco_results[n])
        );
    end else if (exponent_width == 4 && mantissa_width == 3) begin
        MXFP_E4M3_to_FP32 fx2fp (
            .clk(clk),
            .I(shifted_results[n][42:0]),
            .O(flopoco_results[n])
        );
    end else if (exponent_width == 5 && mantissa_width == 2) begin
        MXFP_E5M2_to_FP32 fx2fp (
            .clk(clk),
            .I(shifted_results[n][72:0]),
            .O(flopoco_results[n])
        );
    end else begin
        $fatal("ERROR: Illegal MXFP Format");
    end 
end

endmodule