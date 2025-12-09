module rnd_rne #(
    parameter width_i = 24,
    parameter width_o = 4
)(
    // Input augmented mantissa
    input  logic [width_i-1:0] i_num,
    // Output augmented mantissa
    output logic [width_o-1:0] o_man,
    // Overflow flag
    output logic               o_ofl
);

    // Decide how to round mantissa.
    logic round_bit;
    logic stcky_bit;
    logic round_up;

    assign round_bit =  i_num[width_i-1-width_o];
    assign stcky_bit = |i_num[width_i-1-width_o-1:0];
    assign round_up  = round_bit && (i_num[width_i-1-width_o+1] || stcky_bit);

    // Do rounding.
    logic [width_o:0] p0_man_ofl;  // Extra bit to check for overflow after rounding.

    assign p0_man_ofl = i_num[width_i-1 -: width_o] + {{(width_o-1){1'b0}}, round_up};

    // Assign outputs.
    // Flag: Set to 1 if overflow, 0 otherwise.
    always_comb begin
        o_ofl = p0_man_ofl[width_o];
    end

    // Output mantissa, only valid if no overflow.
    always_comb begin
        o_man = p0_man_ofl[width_o-1:0];
    end

endmodule
