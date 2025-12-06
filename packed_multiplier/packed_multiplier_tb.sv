module packed_multiplier_tb;

parameter tests = 1000;
parameter op_width = 3;
parameter mul_width = 18;
parameter is_registered = 0;
localparam num_ops = mul_width / 2 / op_width;

logic clk;
logic [op_width-1:0] operands [num_ops];
logic [op_width-1:0] sharedOperand;
logic [2*op_width-1:0] products [num_ops];

packed_multiplier #(
    .op_width(op_width), 
    .mul_width(mul_width),
    .is_registered(is_registered)
) dut (
    .clk(clk),
    .operands(operands),
    .sharedOperand(sharedOperand),
    .products(products)
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
            operands[i] = $random % (1 << op_width);
        end
        sharedOperand = $random % (1 << op_width);
        #10; // Wait for result
        
        // Check results
        for (int i = 0; i < num_ops; i++) begin
            logic [2*op_width-1:0] expected_product;
            expected_product = operands[i] * sharedOperand;
            if (products[i] != expected_product) begin
                $display("Test failed for operand %0d: %0d * %0d = %0d, got %0d", i, operands[i], sharedOperand, expected_product, products[i]);
                $finish;
            end
            //$display("Test passed for operand %0d: %0d * %0d = %0d", i, operands[i], sharedOperand, products[i]);
        end

    end

    $display("All tests passed!");
    $finish;

end

endmodule