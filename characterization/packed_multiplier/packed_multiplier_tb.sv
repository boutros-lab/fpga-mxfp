`timescale 1ns/1ns

module packed_multiplier_tb;

parameter tests = 1024;
parameter op_width = 3;
parameter mul_width = 18;
localparam num_ops = (mul_width / (op_width)) - (mul_width / (2*(op_width)));

logic clk;
logic [op_width-1:0] operands_a [num_ops], operands_b [num_ops];
logic [op_width-1:0] sharedOperand_a, sharedOperand_b;
logic [2*op_width-1:0] products_a [num_ops], products_b [num_ops];

logic [mul_width-1:0] mul_ax, mul_ay, mul_bx, mul_by;
logic [2 * mul_width-1:0] mul_resulta, mul_resultb;

DSP_2x18x18 dsp (
    .ax (mul_ax),
    .ay (mul_ay),
    .bx (mul_bx),
    .by (mul_by),
    .clk (clk),
    .resulta (mul_resulta[35:0]),
    .resultb (mul_resultb[35:0])
);

packed_multiplier #(
    .op_width(op_width), 
    .mul_width(mul_width)
) dut_a (
    .clk(clk),
    .operands(operands_a),
    .sharedOperand(sharedOperand_a),
    .products(products_a),
    .mul_x(mul_ax),
    .mul_y(mul_ay),
    .mul_result(mul_resulta)
);

packed_multiplier #(
    .op_width(op_width), 
    .mul_width(mul_width)
) dut_b (
    .clk(clk),
    .operands(operands_b),
    .sharedOperand(sharedOperand_b),
    .products(products_b),
    .mul_x(mul_bx),
    .mul_y(mul_by),
    .mul_result(mul_resultb)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test sequence
initial begin

    $display("!!!DUT=packed_multiplier");
    $display("op_width=%0d", op_width);
    $display("num_ops=%0d", num_ops);
    $display("tests=%0d", tests);

    for (int test = 0; test < tests; test++) begin

        for (int i = 0; i < num_ops; i++) begin
            operands_a[i] = $random % (1 << op_width);
            operands_b[i] = $random % (1 << op_width);
        end
        sharedOperand_a = $random % (1 << op_width);
        sharedOperand_b = $random % (1 << op_width);
        #10; // Wait for result

        $display("test=%0d", test);
        $display("sharedOperand_a=%b", sharedOperand_a);
        $display("sharedOperand_b=%b", sharedOperand_b);
        for (int i = 0; i < num_ops; i++) begin
            $display("operand_a[%0d]=%b", i, operands_a[i]);
            $display("operand_b[%0d]=%b", i, operands_b[i]);
        end
        for (int i = 0; i < num_ops; i++) begin
            $display("product_a[%0d]=%b", i, products_a[i]);
            $display("product_b[%0d]=%b", i, products_b[i]);
        end

    end

    $finish;

end

endmodule
