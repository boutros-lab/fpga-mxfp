// dot_fp with input and output register stages

module dot_fp_fp32 #(
   	parameter exp_width = 2,
    	parameter man_width = 1,
   	parameter k         = 32,
   	parameter bit_width = 1 + exp_width + man_width,
   	parameter out_width = 2 * ((1<<exp_width) + man_width) + $clog2(k),

	parameter input_stages    = 1,
	parameter dot_fp_stages   = 1,
	parameter pipeline_add    = 1,
	parameter fp32_stages     = 1,
	parameter pipeline_fix2fp = 1,
	parameter output_stages   = 1
)(
	input  logic clk,
	input  logic rst,
	input  logic signed [bit_width-1:0] i_vec_a [k],
	input  logic signed [bit_width-1:0] i_vec_b [k],
	input  logic        [7:0]           i_shared_exp_a,
	input  logic        [7:0]           i_shared_exp_b,
	output logic        [31:0]          o_fp32_q
);
	localparam fix2fp_stages = pipeline_fix2fp ? ((exp_width == 5 && man_width == 2) ? 14 
								      : (exp_width == 4 && man_width == 3) ? 11 
								      : (exp_width == 3 && man_width == 2) ?  6 
								      : (exp_width == 2 && man_width == 3) ?  6 
								      : (exp_width == 2 && man_width == 1) ?  5 
								      : 0) : 0;

	localparam latency = input_stages + dot_fp_stages + (($clog2(k) - 1) * pipeline_add) + fp32_stages + fix2fp_stages + output_stages;

	logic signed [bit_width-1:0] i_vec_a_q [k];
	logic signed [bit_width-1:0] i_vec_b_q [k];
	logic        [7:0]           i_shared_exp_a_q;
	logic        [7:0]           i_shared_exp_b_q;

	logic [out_width-1:0] o_dp;
	logic [out_width-1:0] o_dp_q;
	logic [33:0]          o_fp32; // Flopoco FP32
	logic [31:0]          o_fp32_scaled; // scale factors added

	// Shared Exponent
	logic signed [9:0] shared_exp_sum, shared_exp_sum_q;
	logic signed [9:0] scaled_exponent;

	genvar i;

	generate
		for (i = 0; i < k; i++) begin
			pipeline #(
				.width(2*bit_width), 
				.depth(input_stages)
			) u_pipeline_in (
				.clk(clk), 
				.rst(rst), 
				.data({i_vec_a[i], i_vec_b[i]}), 
				.data_q({i_vec_a_q[i], i_vec_b_q[i]})
			);
		end
	endgenerate

	dot_fp #(
		.exp_width(exp_width), 
		.man_width(man_width), 
		.k(k),
		.pipeline_stages(dot_fp_stages),
		.pipeline_add(pipeline_add)
	) u_dot_fp (
		.clk(clk),
		.rst(rst),
		.i_vec_a(i_vec_a_q),
		.i_vec_b(i_vec_b_q),
		.o_dp(o_dp)
	);

	pipeline #(
		.width(out_width), 
		.depth(fp32_stages)
	) u_pipeline_dp (
		.clk(clk), 
		.rst(rst), 
		.data(o_dp), 
		.data_q(o_dp_q)
	);

	generate
		if (exp_width == 2 && man_width == 1) begin
			if (pipeline_fix2fp == 1) begin
				MXFP_E2M1_to_FP32 
				fix_to_fp32 (
					.clk(clk),
					.I(o_dp_q), 
					.O(o_fp32)
				);
			end else begin
				MXFP_E2M1_to_FP32 
				fix_to_fp32 (
					.I(o_dp_q), 
					.O(o_fp32)
				);
			end
		end else if (exp_width == 2 && man_width == 3) begin
			if (pipeline_fix2fp == 1) begin
				MXFP_E2M3_to_FP32 
				fix_to_fp32 (
					.clk(clk),
					.I(o_dp_q), 
					.O(o_fp32)
				);
			end else begin
				MXFP_E2M3_to_FP32 
				fix_to_fp32 (
					.I(o_dp_q), 
					.O(o_fp32)
				);
			end
		end else if (exp_width == 3 && man_width == 2) begin
			if (pipeline_fix2fp == 1) begin
				MXFP_E3M2_to_FP32 
				fix_to_fp32 (
					.clk(clk),
					.I(o_dp_q[23:0]), 
					.O(o_fp32)
				);
			end else begin
				MXFP_E3M2_to_FP32 
				fix_to_fp32 (
					.I(o_dp_q[23:0]), 
					.O(o_fp32)
				);
			end
		end else if (exp_width == 4 && man_width == 3) begin
			if (pipeline_fix2fp == 1) begin
				MXFP_E4M3_to_FP32 
				fix_to_fp32 (
					.clk(clk),
					.I(o_dp_q), 
					.O(o_fp32)
				);
			end else begin
				MXFP_E4M3_to_FP32 
				fix_to_fp32 (
					.I(o_dp_q), 
					.O(o_fp32)
				);
			end
		end else if (exp_width == 5 && man_width == 2) begin
			if (pipeline_fix2fp == 1) begin
				MXFP_E5M2_to_FP32 
				fix_to_fp32 (
					.clk(clk),
					.I(o_dp_q), 
					.O(o_fp32)
				);
			end else begin
				MXFP_E5M2_to_FP32 
				fix_to_fp32 (
					.I(o_dp_q), 
					.O(o_fp32)
				);
			end
		end else begin
			$fatal("ERROR: Illegal MXFP Format");
		end
	endgenerate

	// Shared Exponent Handling
	pipeline #(
		.width(16), 
		.depth(input_stages)
	) u_pipeline_shared_exp (
		.clk(clk), 
		.rst(rst), 
		.data({i_shared_exp_a, i_shared_exp_b}), 
		.data_q({i_shared_exp_a_q, i_shared_exp_b_q})
	);

	assign shared_exp_sum = $unsigned(i_shared_exp_a_q) + $unsigned(i_shared_exp_b_q) - $unsigned(10'd254);

	// Pipeline to output of fix2float
	pipeline #(
		.width(10), 
		.depth(latency - output_stages - input_stages)
	) u_pipeline_shared_exp_sum (
		.clk(clk), 
		.rst(rst), 
		.data(shared_exp_sum), 
		.data_q(shared_exp_sum_q)
	);

	// Add shared exponents and remove bias terms
	assign scaled_exponent = $signed({2'b0, o_fp32[30:23]}) + shared_exp_sum_q;

	always_comb begin
		if ((scaled_exponent[9] == 1) || ((scaled_exponent[7:0] == 0) && (scaled_exponent[8] == 0)) || ~(|o_fp32[33:32])) begin // underflow, subnormal flush, zero
			o_fp32_scaled = {o_fp32[31], 31'b0}; // 0
		end else if (scaled_exponent[8] == 1) begin // overflow
			o_fp32_scaled = {o_fp32[31], 31'h7f800000}; // inf
		end else begin // regular
			o_fp32_scaled = {o_fp32[31], scaled_exponent[7:0], o_fp32[22:0]}; // 0
		end
	end

	pipeline #(
		.width(32), 
		.depth(output_stages)
	) u_pipeline_out (
		.clk(clk), 
		.rst(rst), 
		.data(o_fp32_scaled), 
		.data_q(o_fp32_q)
	);

endmodule
