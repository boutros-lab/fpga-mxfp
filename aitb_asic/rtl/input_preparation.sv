/*
* Input preparation muxes, takes flat input to DSP and separates it into
* individual signed elements
*/

module input_preparation #(
	parameter FLAT_WIDTH    = 80,
	parameter ELEMENT_WIDTH = 8,

	parameter ELEMENT_COUNT = FLAT_WIDTH/ELEMENT_WIDTH
)(
	input  logic        [FLAT_WIDTH-1:0]    i_flat,
	output logic signed [ELEMENT_WIDTH-1:0] o_elements [ELEMENT_COUNT]
);

always_comb begin
	for (int i = 0; i < ELEMENT_COUNT; i++) begin
		o_elements[i] = $signed(i_flat[i*ELEMENT_WIDTH+:ELEMENT_WIDTH]);
	end
end

endmodule
