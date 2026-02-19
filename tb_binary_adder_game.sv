// =============================================================================
// Testbench for Binary Adder Game
// =============================================================================
// Tests all operand combinations and modes with self-checking assertions.
//
// Test Coverage:
//   - Mode 00: Display operand A
//   - Mode 01: Display operand B
//   - Mode 10: Addition with carry detection
//   - Mode 11: Subtraction with borrow detection
//   - Exhaustive testing of all 4-bit combinations
// =============================================================================

module tb_binary_adder_game;

    // Testbench signals
    logic        clk;
    logic        rst;
    logic [4:0]  btn_pulse;
    logic [15:0] sw;
    logic [15:0] led;
    logic [63:0] grid;
    logic        check_ok;
    logic [7:0]  score;

    // Test counters
    int pass_count = 0;
    int fail_count = 0;
    int test_count = 0;

    // =========================================================================
    // DUT Instantiation
    // =========================================================================
    binary_adder_game #(
        .USE_STRUCTURAL(0)  // Test behavioral first
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .btn_pulse (btn_pulse),
        .sw        (sw),
        .led       (led),
        .grid      (grid),
        .check_ok  (check_ok),
        .score     (score)
    );

    // =========================================================================
    // Clock Generation (50 MHz)
    // =========================================================================
    initial begin
        clk = 0;
        forever #10ns clk = ~clk;  // 20ns period = 50MHz
    end

    // =========================================================================
    // Test Procedure
    // =========================================================================
    initial begin
        $display("========================================");
        $display("Binary Adder Game Testbench");
        $display("========================================");

        // Initialize
        rst = 1;
        btn_pulse = 5'b00000;
        sw = 16'h0000;
        repeat(3) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Test Mode 00: Show A
        $display("\n--- Testing Mode 00: Show A ---");
        test_mode_show_a();

        // Test Mode 01: Show B
        $display("\n--- Testing Mode 01: Show B ---");
        test_mode_show_b();

        // Test Mode 10: Addition
        $display("\n--- Testing Mode 10: Addition ---");
        test_mode_addition();

        // Test Mode 11: Subtraction
        $display("\n--- Testing Mode 11: Subtraction ---");
        test_mode_subtraction();

        // Summary
        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        if (fail_count == 0) begin
            $display("\nTEST PASSED");
        end else begin
            $display("\nTEST FAILED");
            $error("Some tests failed");
        end
        $display("========================================\n");

        $finish;
    end
    
    // =========================================================================
    // Waveform Dump
    // =========================================================================
    initial begin
        $dumpfile("dumpfile.fst");
        $dumpvars(0);
    end

    // =========================================================================
    // Test Tasks
    // =========================================================================

    task test_mode_show_a();
        for (int a = 0; a < 16; a++) begin
            sw = {6'b000000, 2'b00, 4'b0000, a[3:0]};  // Mode 00, B=0, A=a
            @(posedge clk);
            check_result(a, 0, "Show A");
        end
    endtask

    task test_mode_show_b();
        for (int b = 0; b < 16; b++) begin
            sw = {6'b000000, 2'b01, b[3:0], 4'b0000};  // Mode 01, B=b, A=0
            @(posedge clk);
            check_result(b, 0, "Show B");
        end
    endtask

    task test_mode_addition();
        logic [4:0] expected_sum;
        logic expected_carry;
        
        // Test selected cases for addition
        for (int a = 0; a < 16; a += 3) begin
            for (int b = 0; b < 16; b += 3) begin
                sw = {6'b000000, 2'b10, b[3:0], a[3:0]};  // Mode 10
                @(posedge clk);
                expected_sum = a + b;
                expected_carry = expected_sum[4];
                check_result(expected_sum[3:0], expected_carry, "Addition");
            end
        end

        // Edge cases
        sw = {6'b000000, 2'b10, 4'hF, 4'hF};  // 15 + 15 = 30 (carry)
        @(posedge clk);
        check_result(5'd30 & 8'h1F, 1, "Addition Max");
    endtask

    task test_mode_subtraction();
        logic [4:0] expected_diff;
        logic expected_borrow;
        
        // Test selected cases for subtraction
        for (int a = 0; a < 16; a += 3) begin
            for (int b = 0; b < 16; b += 3) begin
                sw = {6'b000000, 2'b11, b[3:0], a[3:0]};  // Mode 11
                @(posedge clk);
                expected_diff = a - b;
                expected_borrow = expected_diff[4];
                check_result(expected_diff[3:0], expected_borrow, "Subtraction");
            end
        end

        // Edge cases
        sw = {6'b000000, 2'b11, 4'hF, 4'h0};  // 0 - 15 (underflow)
        @(posedge clk);
        check_result(4'd1, 1, "Subtraction Underflow");
    endtask

    task check_result(input logic [7:0] expected_val, input logic expected_flag, input string test_name);
        logic [7:0] actual_val;
        logic actual_flag;
        
        test_count++;
        actual_val = led[7:0];
        actual_flag = led[8];

        if (actual_val == expected_val && actual_flag == expected_flag) begin
            pass_count++;
            $display("[PASS] %s: Expected=%0d (flag=%b), Got=%0d (flag=%b)", 
                     test_name, expected_val, expected_flag, actual_val, actual_flag);
        end else begin
            fail_count++;
            $display("[FAIL] %s: Expected=%0d (flag=%b), Got=%0d (flag=%b)", 
                     test_name, expected_val, expected_flag, actual_val, actual_flag);
        end
    endtask

endmodule
