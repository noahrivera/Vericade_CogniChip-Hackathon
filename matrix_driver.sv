// =============================================================================
// Matrix Driver - 8x8 LED Matrix Scanner
// Part of Vericade Logic Lab Arcade
// =============================================================================
// Scans an 8x8 LED matrix using row multiplexing.
// Updates at ~1kHz refresh rate to avoid flicker.
//
// Operation:
//   - Activates one row at a time (active-high)
//   - Sets column data for that row (active-high = LED on)
//   - Cycles through all 8 rows continuously
//
// Input: grid[63:0] - 64-bit flattened representation
//        grid[7:0]   = row 0
//        grid[15:8]  = row 1
//        ...
//        grid[63:56] = row 7
// =============================================================================

module matrix_driver #(
    parameter CLK_FREQ_HZ = 50_000_000,   // Clock frequency
    parameter REFRESH_HZ = 1000            // Total refresh rate (all rows)
) (
    input  logic         clk,
    input  logic         rst,
    input  logic [63:0]  grid,             // 8x8 grid (flattened)
    output logic [7:0]   matrix_row,       // Row select (active-high, one-hot)
    output logic [7:0]   matrix_col        // Column data (active-high = LED on)
);

    // Calculate cycles per row update
    localparam CYCLES_PER_ROW = CLK_FREQ_HZ / (REFRESH_HZ * 8);
    localparam COUNTER_WIDTH = $clog2(CYCLES_PER_ROW + 1);

    // State
    logic [2:0] current_row;               // Which row we're scanning (0-7)
    logic [COUNTER_WIDTH-1:0] cycle_counter;

    // =========================================================================
    // Row scanning state machine
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst) begin
            current_row <= 3'b000;
            cycle_counter <= '0;
        end else begin
            if (cycle_counter < (CYCLES_PER_ROW - 1)) begin
                cycle_counter <= cycle_counter + 1'b1;
            end else begin
                cycle_counter <= '0;
                current_row <= current_row + 1'b1;  // Wrap automatically (3-bit)
            end
        end
    end

    // =========================================================================
    // Output generation
    // =========================================================================
    // One-hot row select
    always_comb begin
        matrix_row = 8'b0000_0000;
        matrix_row[current_row] = 1'b1;
    end

    // Column data from grid
    // Extract 8 bits corresponding to current row
    always_comb begin
        case (current_row)
            3'd0: matrix_col = grid[7:0];
            3'd1: matrix_col = grid[15:8];
            3'd2: matrix_col = grid[23:16];
            3'd3: matrix_col = grid[31:24];
            3'd4: matrix_col = grid[39:32];
            3'd5: matrix_col = grid[47:40];
            3'd6: matrix_col = grid[55:48];
            3'd7: matrix_col = grid[63:56];
        endcase
    end

endmodule
