module dot_fp #(
    parameter exp_width = 5,
    parameter man_width = 2,
    parameter k         = 32,
    parameter bit_width = 1 + exp_width + man_width,
    parameter fi_width  = man_width + 2,
    parameter prd_width = 2 * ((1<<exp_width) + man_width),
    parameter out_width = prd_width + $clog2(k),

    parameter pipeline_stages = 0,
    parameter pipeline_add = 0
)(
    input  logic clk,
    input  logic rst,
    input  logic signed [bit_width-1:0] i_vec_a [k],
    input  logic signed [bit_width-1:0] i_vec_b [k],
    output logic signed [out_width-1:0] o_dp
);

    // Perform multiplications.
    logic signed [prd_width-1:0] p0_prd   [k];
    logic signed [prd_width-1:0] p0_prd_q [k];

    vec_mul_fp #(
        .exp_width(exp_width),
        .man_width(man_width),
        .length(k)
    ) u_vec_mul (
        .i_vec_a(i_vec_a),
        .i_vec_b(i_vec_b),
        .o_prd(p0_prd)
    );

    genvar i;
    
    generate
        for (i = 0; i < k; i++) begin
            pipeline #(
    	        .width(prd_width), 
    	        .depth(pipeline_stages)
            ) u_pipeline_dot_fp (
    	        .clk(clk), 
    	        .rst(rst), 
    	        .data(p0_prd[i]), 
    	        .data_q(p0_prd_q[i])
            );
        end
    endgenerate

    // Calculate sum.
    logic signed [out_width-1:0] p0_sum;

    vec_sum_int #(
        .bit_width(prd_width),
        .length(k),
	.pipeline(pipeline_add)
    ) u_tree_add (
	.clk(clk),
	.rst(rst),
        .i_vec(p0_prd_q),
        .o_sum(p0_sum)
    );

    assign o_dp = p0_sum;


endmodule
