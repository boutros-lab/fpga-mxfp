module packed_multiplier_tb;

localparam width = 3;
localparam number = 18 / 2 / (width + 1); // 2

logic clk;
logic rst;
logic [width-1:0] operands [number];
logic [width-1:0] sharedOperand;
logic [2*width-1:0] products [number];

packed_multiplier #(.width(width), .number(number)) dut (
    .clk(clk),
    .rst(rst),
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
    
    // Initialize
    rst = 1;
    operands[0] = 0;
    operands[1] = 0;
    sharedOperand = 0;
    #10; // Wait for reset
    rst = 0;
    #10; // Wait for one clock cycle

    // Test case 1
    operands[0] = 5;
    operands[1] = 3;
    sharedOperand = 2;
    #10; // Wait for result

    $display("operands[0]: %p, operands[1]: %p, sharedOperand: %p, products[0]: %p, products[1]: %p", operands[0], operands[1], sharedOperand, products[0], products[1]);
    if (products[0] !== operands[0] * sharedOperand) $error("Test 1a failed");
    if (products[1] !== operands[1] * sharedOperand) $error("Test 1b failed");

    // Test case 2
    operands[0] = 7;
    operands[1] = 7;
    sharedOperand = 7;
    #10; // Wait for result

    $display("operands[0]: %p, operands[1]: %p, sharedOperand: %p, products[0]: %p, products[1]: %p", operands[0], operands[1], sharedOperand, products[0], products[1]);
    if (products[0] !== operands[0] * sharedOperand) $error("Test 2a failed");
    if (products[1] !== operands[1] * sharedOperand) $error("Test 2b failed");

    $finish;

end

endmodule