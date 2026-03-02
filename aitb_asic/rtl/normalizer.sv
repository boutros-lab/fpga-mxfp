import pkg_aitb::*;

module normalizer #(
	parameter IN_WIDTH = 20,
	parameter INTERNAL_WIDTH = 32,
	parameter OUT_WIDTH = 23
) (
	input logic [IN_WIDTH-1:0] shift_in,
	output logic [OUT_WIDTH-1:0] shift_out,
	output logic [$clog2(INTERNAL_WIDTH)-1:0] lead_zero_count 
);

localparam STAGES = $clog2(INTERNAL_WIDTH);
localparam PAD = INTERNAL_WIDTH - IN_WIDTH;

logic [INTERNAL_WIDTH-1:0] shift_in_pad;

assign shift_in_pad = { '0, shift_in };

logic [INTERNAL_WIDTH-1:0] stage [0:STAGES];
logic [STAGES-1:0] shift_amount;

assign stage[0] = shift_in_pad;

genvar i;
generate
	for (i = 0; i < STAGES; i++) begin
		localparam SHIFT = (1 << (STAGES-i-1));

		assign shift_amount[STAGES-i-1] = ~|stage[i][INTERNAL_WIDTH-1 -: SHIFT]; // NOR deteshift_amounttor
		assign stage[i+1] = shift_amount[STAGES-i-1] ? (stage[i] << SHIFT) : stage[i]; // Shift MUX
 	end
endgenerate

assign lead_zero_count = (shift_in == '0) ? '0 : shift_amount-PAD;
assign shift_out = stage[STAGES][INTERNAL_WIDTH-1 -: OUT_WIDTH];
endmodule
