module rnd_stc #(
    parameter width_i = 24,
    parameter width_o = 4
)(
    // Clock stuff
    input i_clk,
    input i_rst,
    // Input augmented mantissa
    input  logic [width_i-1:0] i_num,
    // // Random noise used for rounding
    // input  logic         [5:0] i_noise,
    // Output augmented mantissa
    output logic [width_o-1:0] o_man,
    // Overflow flag
    output logic               o_ofl
);

    // LFSR
    logic [5:0] noise;
    logic       feedback;

    // assign noise = i_noise;

    // Polynomial: x^6 + x^5 + 1 (primitive for 6-bit)
    assign feedback = noise[5] ^ noise[4];  // taps at bit 6 and 5

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            noise <= 6'b000001; // Reset to non-zero value
        end else begin
            noise <= {noise[4:0], feedback};
        end
    end

    // Do rounding.
    logic [width_o-1+6:0] num_trunc;  // The highest (width_o + 6) bits of the input
    logic [width_o  +6:0] p0_man_ofl; // Extra bit to check for overflow after rounding.

    assign num_trunc  = i_num[width_i-1 -: width_o+6];
    assign p0_man_ofl = num_trunc + {{(width_o){1'b0}}, noise};

    // Assign outputs.
    // Flag: Set to 1 if overflow, 0 otherwise.
    always_comb begin
        o_ofl = p0_man_ofl[width_o+6];
    end

    // Output mantissa, only valid if no overflow.
    always_comb begin
        o_man = p0_man_ofl[width_o-1+6 -: width_o];
    end

endmodule
