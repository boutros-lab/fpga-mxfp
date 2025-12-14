module packed_dot_product #(
    parameter op_width = 3,
    parameter mul_width = 18,
    parameter is_registered = 0,
    localparam num_ops = mul_width / 2 / op_width,
    parameter length = 32
) (
    ports
);
    
endmodule