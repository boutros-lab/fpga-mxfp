module rnd_rne_top #(
    parameter width_i = 10,
    parameter width_o = 4
)(
    // Clock stuff
    input i_clk,
    input i_rst,
    // Input augmented mantissa
    input  logic [width_i-1:0] i_num,
    // Output augmented mantissa
    output logic [width_o-1:0] o_man,
    // Overflow flag
    output logic               o_ofl
);


logic [width_i-1:0] r_num;

always_ff @(posedge i_clk) begin
    r_num <= i_num;
end


rnd_rne # (
    .width_i(width_i),
    .width_o(width_o)
) u0_rnd_rne (
    .i_num(r_num),
    .o_man(o_man),
    .o_ofl(o_ofl)
);

endmodule
