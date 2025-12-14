module packed_multiplier_tb;

parameter tests = 1024;
parameter op_width = 3;
parameter mul_width = 18;
parameter is_registered = 0;
localparam num_ops = mul_width / 2 / op_width;

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
    .mul_width(mul_width),
    .is_registered(is_registered)
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
    .mul_width(mul_width),
    .is_registered(is_registered)
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

    for (int test = 0; test < tests; test++) begin

        for (int i = 0; i < num_ops; i++) begin
            operands_a[i] = $random % (1 << op_width);
            operands_b[i] = $random % (1 << op_width);
        end
        sharedOperand_a = $random % (1 << op_width);
        sharedOperand_b = $random % (1 << op_width);
        #10; // Wait for result
        
        // Check results
        for (int i = 0; i < num_ops; i++) begin
            logic [2*op_width-1:0] expected_product_a;
            logic [2*op_width-1:0] expected_product_b;
            expected_product_a = operands_a[i] * sharedOperand_a;
            expected_product_b = operands_b[i] * sharedOperand_b;
            if (products_a[i] != expected_product_a || products_b[i] != expected_product_b) begin
                $display("A Test failed for operand %0d: %0d * %0d = %0d, got %0d", i, operands_a[i], sharedOperand_a, expected_product_a, products_a[i]);
                $display("B Test failed for operand %0d: %0d * %0d = %0d, got %0d", i, operands_b[i], sharedOperand_b, expected_product_b, products_b[i]);
                $finish;
            end
            //$display("A Test passed for operand %0d: %0d * %0d = %0d", i, operands_a[i], sharedOperand_a, products_a[i]);
            //$display("B Test passed for operand %0d: %0d * %0d = %0d", i, operands_b[i], sharedOperand_b, products_b[i]);
        end

    end

    $display("All tests passed!");
    $finish;

end

endmodule