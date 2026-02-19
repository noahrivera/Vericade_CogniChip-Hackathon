// =============================================================================
// Binary Adder Game - Teaching Binary Arithmetic
// Part of Vericade Logic Lab Arcade
// =============================================================================
// Educational calculator demonstrating binary addition/subtraction.
//
// Switch Mapping:
//   sw[3:0]  - Operand A (4-bit)
//   sw[7:4]  - Operand B (4-bit)
//   sw[9:8]  - Mode select:
//              00 = Show A
//              01 = Show B
//              10 = Show A + B (with carry)
//              11 = Show A - B (two's complement, wrapping)
//
// LED Outputs:
//   led[7:0] - Result value
//   led[8]   - Carry/borrow flag
//
// Display Grid: Shows binary representation of result (8 bits)
//   Bottom row = LSB, top row = MSB (visual vertical binary)
// =============================================================================

module binary_adder_game #(
    parameter USE_STRUCTURAL = 0  // 1=Use ripple-carry full_adder chain, 0=Use + operator
) (
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  btn_pulse,  // Not used in this game
    input  logic [15:0] sw,
    output logic [15:0] led,
    output logic [63:0] grid,
    output logic        check_ok,   // Always valid for this game
    output logic [7:0]  score       // Not used
);

    // Extract operands and mode
    logic [3:0] operand_a;
    logic [3:0] operand_b;
    logic [1:0] mode;

    assign operand_a = sw[3:0];
    assign operand_b = sw[7:4];
    assign mode = sw[9:8];

    // Result and carry/borrow
    logic [7:0] result;
    logic       carry_borrow;

    // =========================================================================
    // Arithmetic Logic
    // =========================================================================
    generate
        if (USE_STRUCTURAL) begin : gen_structural
            // Structural implementation using ripple-carry adder
            logic [4:0] sum_add;
            logic [4:0] carry;
            logic [4:0] sum_sub;
            logic [4:0] borrow;
            logic [3:0] b_complement;

            // Addition: 4-bit ripple-carry adder
            assign carry[0] = 1'b0;
            for (genvar i = 0; i < 4; i++) begin : gen_add
                full_adder fa_add (
                    .a(operand_a[i]),
                    .b(operand_b[i]),
                    .cin(carry[i]),
                    .sum(sum_add[i]),
                    .cout(carry[i+1])
                );
            end
            assign sum_add[4] = carry[4];  // Final carry out

            // Subtraction: A - B using two's complement (A + ~B + 1)
            assign b_complement = ~operand_b;
            assign borrow[0] = 1'b1;  // +1 for two's complement
            for (genvar i = 0; i < 4; i++) begin : gen_sub
                full_adder fa_sub (
                    .a(operand_a[i]),
                    .b(b_complement[i]),
                    .cin(borrow[i]),
                    .sum(sum_sub[i]),
                    .cout(borrow[i+1])
                );
            end
            assign sum_sub[4] = borrow[4];

            // Mode selection
            always_comb begin
                case (mode)
                    2'b00: begin  // Show A
                        result = {4'b0, operand_a};
                        carry_borrow = 1'b0;
                    end
                    2'b01: begin  // Show B
                        result = {4'b0, operand_b};
                        carry_borrow = 1'b0;
                    end
                    2'b10: begin  // Show A + B
                        result = {3'b0, sum_add[4:0]};
                        carry_borrow = sum_add[4];
                    end
                    2'b11: begin  // Show A - B
                        result = {4'b0, sum_sub[3:0]};
                        carry_borrow = ~sum_sub[4];  // Inverted for borrow
                    end
                endcase
            end

        end else begin : gen_behavioral
            // Behavioral implementation using + and - operators
            logic [4:0] sum_extended;
            logic [4:0] diff_extended;

            always_comb begin
                sum_extended = {1'b0, operand_a} + {1'b0, operand_b};
                diff_extended = {1'b0, operand_a} - {1'b0, operand_b};

                case (mode)
                    2'b00: begin  // Show A
                        result = {4'b0, operand_a};
                        carry_borrow = 1'b0;
                    end
                    2'b01: begin  // Show B
                        result = {4'b0, operand_b};
                        carry_borrow = 1'b0;
                    end
                    2'b10: begin  // Show A + B
                        result = {3'b0, sum_extended};
                        carry_borrow = sum_extended[4];
                    end
                    2'b11: begin  // Show A - B (wrap on underflow)
                        result = {4'b0, diff_extended[3:0]};
                        carry_borrow = diff_extended[4];  // Borrow if negative
                    end
                endcase
            end
        end
    endgenerate

    // =========================================================================
    // LED Outputs
    // =========================================================================
    assign led[7:0] = result;
    assign led[8] = carry_borrow;
    assign led[15:9] = '0;

    // =========================================================================
    // Grid Display - Show binary representation vertically
    // =========================================================================
    // Each bit of result controls a column (8 columns for 8 bits)
    // If bit is 1, light up that column; if 0, keep dark
    always_comb begin
        grid = 64'h0;
        for (int i = 0; i < 8; i++) begin
            if (result[i]) begin
                // Light up column i (all 8 rows)
                grid[i]      = 1'b1;  // Row 0
                grid[8+i]    = 1'b1;  // Row 1
                grid[16+i]   = 1'b1;  // Row 2
                grid[24+i]   = 1'b1;  // Row 3
                grid[32+i]   = 1'b1;  // Row 4
                grid[40+i]   = 1'b1;  // Row 5
                grid[48+i]   = 1'b1;  // Row 6
                grid[56+i]   = 1'b1;  // Row 7
            end
        end
    end

    // =========================================================================
    // Status Outputs
    // =========================================================================
    assign check_ok = 1'b1;  // Always valid
    assign score = 8'h00;     // Not used

endmodule
