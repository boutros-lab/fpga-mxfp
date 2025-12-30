module add_shared_exp (
	input  logic [31:0] fp32_in,
	input  logic [7:0]  shared_exp_in_a,
	input  logic [7:0]  shared_exp_in_b,
	output logic [31:0] fp32_out
);
localparam max_exp = 2**8 - 1;

logic        sign_in;
logic [7:0]  exp_in;
logic [22:0] man_in;

assign {sign_in, exp_in, man_in} = fp32_in;

logic signed [9:0] signed_exp_i;
logic signed [9:0] signed_exp_a;
logic signed [9:0] signed_exp_b;
logic signed [9:0] exp_result;

// Extend to 10 bits to detect overflow and underflow
assign signed_exp_i = $signed({2'b0, exp_in});
assign signed_exp_a = $signed({2'b0, shared_exp_in_a});
assign signed_exp_b = $signed({2'b0, shared_exp_in_b});

// 254 = exp_bias * 2
assign exp_result = signed_exp_i + signed_exp_a + signed_exp_b - 10'd254;

// TODO: Need special handling for:
// 	Zero: ignore shared exponent
// 	Subnormal Input: need to adjust mantissa
// 	Subnormal output: idek
always_comb begin
	if (exp_result < $signed(10'b0)) begin
		// Underflow
		fp32_out = 32'b0;
	end else if (exp_result > $signed(10'hFF)) begin
		// Overflow
		fp32_out = 32'h7F800000; // Inf
	end else begin
		// Normal number
		fp32_out = {sign_in, exp_result[7:0], man_in};
	end
end

endmodule
