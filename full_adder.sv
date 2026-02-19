// =============================================================================
// Full Adder - Structural Implementation for Teaching
// Part of Vericade Logic Lab Arcade
// =============================================================================
// Educational 1-bit full adder using gate-level logic.
// Used in binary_adder_game when USE_STRUCTURAL parameter is set.
//
// Truth Table:
//   A B Cin | Sum Cout
//   --------|----------
//   0 0  0  |  0   0
//   0 0  1  |  1   0
//   0 1  0  |  1   0
//   0 1  1  |  0   1
//   1 0  0  |  1   0
//   1 0  1  |  0   1
//   1 1  0  |  0   1
//   1 1  1  |  1   1
// =============================================================================

module full_adder (
    input  logic a,      // First operand bit
    input  logic b,      // Second operand bit
    input  logic cin,    // Carry in
    output logic sum,    // Sum output
    output logic cout    // Carry out
);

    // Intermediate signals for teaching gate-level design
    logic sum_ab;        // XOR of A and B
    logic carry_ab;      // AND of A and B
    logic carry_sum_cin; // AND of (A XOR B) and Cin

    // Sum logic: A XOR B XOR Cin
    assign sum_ab = a ^ b;
    assign sum = sum_ab ^ cin;

    // Carry logic: (A AND B) OR ((A XOR B) AND Cin)
    assign carry_ab = a & b;
    assign carry_sum_cin = sum_ab & cin;
    assign cout = carry_ab | carry_sum_cin;

endmodule
