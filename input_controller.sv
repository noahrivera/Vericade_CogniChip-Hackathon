// =============================================================================
// Input Controller - Button Debouncing and Edge Detection
// Part of Vericade Logic Lab Arcade
// =============================================================================
// Provides clean button signals with:
// - Two-stage synchronizer (metastability protection)
// - Debouncing (16ms @ 50MHz clock)
// - Edge detection (single-cycle pulses)
//
// Outputs:
//   btn_pulse[4:0] - Single-cycle pulse on button press (rising edge)
//   btn_level[4:0] - Stable debounced button state
// =============================================================================

module input_controller #(
    parameter CLK_FREQ_HZ = 50_000_000,  // Clock frequency
    parameter DEBOUNCE_MS = 16           // Debounce time in milliseconds
) (
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  btn,             // Raw button inputs
    output logic [4:0]  btn_pulse,       // Single-cycle pulses
    output logic [4:0]  btn_level        // Stable debounced levels
);

    // Calculate debounce counter width
    localparam DEBOUNCE_CYCLES = (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;
    localparam COUNTER_WIDTH = $clog2(DEBOUNCE_CYCLES + 1);

    // Two-stage synchronizer for metastability protection
    logic [4:0] btn_sync1, btn_sync2;

    // Debounce logic
    logic [4:0] btn_stable;
    logic [COUNTER_WIDTH-1:0] debounce_counter [4:0];
    logic [4:0] btn_state;

    // Edge detection
    logic [4:0] btn_prev;

    // =========================================================================
    // Stage 1: Two-stage synchronizer
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst) begin
            btn_sync1 <= '0;
            btn_sync2 <= '0;
        end else begin
            btn_sync1 <= btn;
            btn_sync2 <= btn_sync1;
        end
    end

    // =========================================================================
    // Stage 2: Debouncing (per button)
    // =========================================================================
    generate
        for (genvar i = 0; i < 5; i++) begin : gen_debounce
            always_ff @(posedge clk) begin
                if (rst) begin
                    debounce_counter[i] <= '0;
                    btn_state[i] <= 1'b0;
                end else begin
                    if (btn_sync2[i] != btn_state[i]) begin
                        // Input changed - start/continue counting
                        if (debounce_counter[i] < DEBOUNCE_CYCLES) begin
                            debounce_counter[i] <= debounce_counter[i] + 1'b1;
                        end else begin
                            // Counter reached threshold - update stable state
                            btn_state[i] <= btn_sync2[i];
                            debounce_counter[i] <= '0;
                        end
                    end else begin
                        // Input matches stable state - reset counter
                        debounce_counter[i] <= '0;
                    end
                end
            end

            // Stable output
            assign btn_stable[i] = btn_state[i];
        end
    endgenerate

    assign btn_level = btn_stable;

    // =========================================================================
    // Stage 3: Edge detection (rising edge -> single-cycle pulse)
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst) begin
            btn_prev <= '0;
        end else begin
            btn_prev <= btn_stable;
        end
    end

    // Pulse on rising edge
    assign btn_pulse = btn_stable & ~btn_prev;

endmodule
