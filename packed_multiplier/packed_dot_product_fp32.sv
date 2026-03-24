module packed_dot_product_fp32 #(
    parameter exponent_width = 4,
    parameter mantissa_width = 3,
    parameter mul_width = 18,
    parameter block_size = 32, // must be divisible by 2 since the DSP can handle 2 multiplications at once
    localparam num_ops = mul_width / 2 / (1+mantissa_width), 
    localparam fixed_point_result_width = 1 + 2 * (mantissa_width + 1) + 2 ** (exponent_width + 1) - 2 + $clog2(block_size)
) (
    input logic clk,
    input logic valid_in,
    output logic valid_out,
    // NOTE: operands are a sequence of block-length vectors
    input logic [1 + mantissa_width + exponent_width -1:0] operands [block_size-1:0][num_ops-1:0], sharedOperands [block_size-1:0],
    input logic [7:0] block_exponent [num_ops-1:0], sharedBlock_exponent, 
    output logic [31:0] results [num_ops-1:0]
);

wire [fixed_point_result_width-1:0] fixed_point_results [num_ops-1:0];
wire signed [fixed_point_result_width-2:0] shifted_results [num_ops-1:0];
wire [33:0] flopoco_results [num_ops-1:0];
wire valid_out_fxp;

packed_dot_product #(
    .exponent_width(exponent_width),
    .mantissa_width(mantissa_width),
    .mul_width(mul_width),
    .block_size(block_size)
) u_packed_dot_product (
    .clk(clk),
    .operands(operands),
    .sharedOperands(sharedOperands),
    .results(fixed_point_results),
    .valid_in(valid_in),
    .valid_out(valid_out_fxp)
);

// Pick latency based on exponent and mantissa width
localparam fxp_to_fp32_latency = 
    (exponent_width == 2 && mantissa_width == 1) ? 5 :
    (exponent_width == 2 && mantissa_width == 3) ? 6 :
    (exponent_width == 3 && mantissa_width == 2) ? 6 :
    (exponent_width == 4 && mantissa_width == 3) ? 11 :
    (exponent_width == 5 && mantissa_width == 2) ? 14 : 0;
// Total latency from input to flopoco output: reduction tree + flopoco converter
localparam total_latency = $clog2(block_size) + fxp_to_fp32_latency;

// Valid signal pipeline to match flopoco
logic [fxp_to_fp32_latency-1:0] valid_sr;
always_ff @(posedge clk) begin
    valid_sr <= {valid_sr[fxp_to_fp32_latency-2:0], valid_out_fxp};
end
assign valid_out = valid_sr[fxp_to_fp32_latency-1];

// Delay block exponents to align with flopoco output
logic [7:0] block_exponent_delayed [num_ops-1:0][total_latency-1:0];
logic [7:0] sharedBlock_exponent_delayed [total_latency-1:0];
always_ff @(posedge clk) begin
    for (int n = 0; n < num_ops; n++) begin
        block_exponent_delayed[n][0] <= block_exponent[n];
        for (int d = 1; d < total_latency; d++)
            block_exponent_delayed[n][d] <= block_exponent_delayed[n][d-1];
    end
    sharedBlock_exponent_delayed[0] <= sharedBlock_exponent;
    for (int d = 1; d < total_latency; d++)
        sharedBlock_exponent_delayed[d] <= sharedBlock_exponent_delayed[d-1];
end

// Convert fixed-point results to FP32 using Flopoco-generated modules
for (genvar n = 0; n < num_ops; n++) begin
    // Handle flopoco output format and add block exponent and shared block exponent 
    assign shifted_results[n] = $signed(fixed_point_results[n]) >>> 2;
    // flopoco_results is 34-bit: {exc[1:0], sign, exponent[7:0], fraction[22:0]}
    // exc="00" means zero, exc="01" means normal, exc="10" means overflow
    logic [9:0] combined_exponent;
    assign combined_exponent = {2'b0, flopoco_results[n][30:23]} + {2'b0, block_exponent_delayed[n][total_latency-1]} + {2'b0, sharedBlock_exponent_delayed[total_latency-1]};
    assign results[n] = (flopoco_results[n][33:32] == 2'b00) ? 32'b0 : // underflow to zero
        (flopoco_results[n][33:32] == 2'b10 || combined_exponent >= 10'd255) ? {flopoco_results[n][31], 8'hFF, 23'b0} :  // overflow to infinity
        {flopoco_results[n][31], combined_exponent[7:0], flopoco_results[n][22:0]};

    // Pick flopoco unit based on exponent and mantissa width
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