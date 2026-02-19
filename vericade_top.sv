// =============================================================================
// VERICADE TOP - Educational FPGA Logic Lab Arcade
// =============================================================================
// An educational platform teaching Verilog and digital logic through 4 games:
//   1. Binary Adder    - Arithmetic logic + binary representation
//   2. LED Maze        - I/O mapping + combinational logic
//   3. Tic-Tac-Toe     - Finite state machines
//   4. Connect Four    - Arrays + sequential logic (capstone)
//
// =============================================================================
// SWITCH AND BUTTON MAPPING
// =============================================================================
// Game Selection: sw[1:0]
//   00 = Binary Adder Calculator
//   01 = LED Maze Navigator
//   10 = Tic-Tac-Toe
//   11 = Connect Four
//
// Binary Adder Mode (when sw[1:0] = 00):
//   sw[3:0]  = Operand A (4-bit)
//   sw[7:4]  = Operand B (4-bit)
//   sw[9:8]  = Mode (00=show A, 01=show B, 10=A+B, 11=A-B)
//
// Button Functions (game-dependent):
//   btn[0] = Up/Move Up
//   btn[1] = Down/Move Down
//   btn[2] = Left/Move Left
//   btn[3] = Right/Move Right
//   btn[4] = Select/Place/Drop
//
// LED Outputs:
//   led[15:14] = Current game selection
//   led[13:0]  = Game-specific status (see individual game modules)
//
// Matrix Display:
//   matrix_row[7:0] = Row select (one-hot, active-high)
//   matrix_col[7:0] = Column data (active-high = LED on)
//
// Debug Output:
//   debug[31:0] = Internal state for observation
//     [31:28] = Current game (extended)
//     [27:24] = Button states
//     [23:16] = Score
//     [15:0]  = Game LEDs
//
// =============================================================================
// PARAMETER CONFIGURATION
// =============================================================================
// CLK_FREQ_HZ - System clock frequency (default 50MHz)
// USE_STRUCTURAL_ADDER - Use ripple-carry full_adder chain in Binary Adder
//
// =============================================================================

module vericade_top #(
    parameter CLK_FREQ_HZ = 50_000_000,
    parameter USE_STRUCTURAL_ADDER = 0
) (
    // System signals
    input  logic        clk,
    input  logic        rst,
    
    // User inputs
    input  logic [15:0] sw,
    input  logic [4:0]  btn,
    
    // Display outputs (8x8 LED Matrix)
    output logic [7:0]  matrix_row,
    output logic [7:0]  matrix_col,
    
    // Status outputs
    output logic [15:0] led,
    output logic [31:0] debug
);

    // =========================================================================
    // Internal Signals
    // =========================================================================
    
    // Debounced and pulsed button signals
    logic [4:0] btn_pulse;
    logic [4:0] btn_level;
    
    // Game selection
    logic [1:0] game_select;
    assign game_select = sw[1:0];
    
    // Display grid (8x8 flattened)
    logic [63:0] grid;
    
    // Game outputs
    logic [15:0] led_adder, led_maze, led_tictactoe, led_connect4;
    logic [63:0] grid_adder, grid_maze, grid_tictactoe, grid_connect4;
    logic check_ok_adder, check_ok_maze, check_ok_tictactoe, check_ok_connect4;
    logic [7:0] score_adder, score_maze, score_tictactoe, score_connect4;
    
    // Multiplexed outputs
    logic [15:0] led_mux;
    logic [63:0] grid_mux;
    logic check_ok_mux;
    logic [7:0] score_mux;

    // =========================================================================
    // Module Instantiations
    // =========================================================================

    // -------------------------------------------------------------------------
    // Input Controller - Debouncing and Edge Detection
    // -------------------------------------------------------------------------
    input_controller #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .DEBOUNCE_MS(16)
    ) u_input_controller (
        .clk        (clk),
        .rst        (rst),
        .btn        (btn),
        .btn_pulse  (btn_pulse),
        .btn_level  (btn_level)
    );

    // -------------------------------------------------------------------------
    // Game Module 1: Binary Adder Calculator
    // -------------------------------------------------------------------------
    binary_adder_game #(
        .USE_STRUCTURAL(USE_STRUCTURAL_ADDER)
    ) u_binary_adder (
        .clk        (clk),
        .rst        (rst),
        .btn_pulse  (btn_pulse),
        .sw         (sw),
        .led        (led_adder),
        .grid       (grid_adder),
        .check_ok   (check_ok_adder),
        .score      (score_adder)
    );

    // -------------------------------------------------------------------------
    // Game Module 2: LED Maze Navigator
    // -------------------------------------------------------------------------
    maze_game u_maze (
        .clk        (clk),
        .rst        (rst),
        .btn_pulse  (btn_pulse),
        .sw         (sw),
        .led        (led_maze),
        .grid       (grid_maze),
        .check_ok   (check_ok_maze),
        .score      (score_maze)
    );

    // -------------------------------------------------------------------------
    // Game Module 3: Tic-Tac-Toe
    // -------------------------------------------------------------------------
    tictactoe_game u_tictactoe (
        .clk        (clk),
        .rst        (rst),
        .btn_pulse  (btn_pulse),
        .sw         (sw),
        .led        (led_tictactoe),
        .grid       (grid_tictactoe),
        .check_ok   (check_ok_tictactoe),
        .score      (score_tictactoe)
    );

    // -------------------------------------------------------------------------
    // Game Module 4: Connect Four
    // -------------------------------------------------------------------------
    connect4_game u_connect4 (
        .clk        (clk),
        .rst        (rst),
        .btn_pulse  (btn_pulse),
        .sw         (sw),
        .led        (led_connect4),
        .grid       (grid_connect4),
        .check_ok   (check_ok_connect4),
        .score      (score_connect4)
    );

    // -------------------------------------------------------------------------
    // Game Manager - Multiplexes Game Outputs
    // -------------------------------------------------------------------------
    game_manager u_game_manager (
        .clk               (clk),
        .rst               (rst),
        .game_select       (game_select),
        .btn_pulse         (btn_pulse),
        .sw                (sw),
        .led_adder         (led_adder),
        .grid_adder        (grid_adder),
        .check_ok_adder    (check_ok_adder),
        .score_adder       (score_adder),
        .led_maze          (led_maze),
        .grid_maze         (grid_maze),
        .check_ok_maze     (check_ok_maze),
        .score_maze        (score_maze),
        .led_tictactoe     (led_tictactoe),
        .grid_tictactoe    (grid_tictactoe),
        .check_ok_tictactoe(check_ok_tictactoe),
        .score_tictactoe   (score_tictactoe),
        .led_connect4      (led_connect4),
        .grid_connect4     (grid_connect4),
        .check_ok_connect4 (check_ok_connect4),
        .score_connect4    (score_connect4),
        .led_out           (led_mux),
        .grid_out          (grid_mux),
        .check_ok_out      (check_ok_mux),
        .score_out         (score_mux)
    );

    // -------------------------------------------------------------------------
    // Matrix Driver - 8x8 LED Display Controller
    // -------------------------------------------------------------------------
    matrix_driver #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .REFRESH_HZ(1000)
    ) u_matrix_driver (
        .clk        (clk),
        .rst        (rst),
        .grid       (grid_mux),
        .matrix_row (matrix_row),
        .matrix_col (matrix_col)
    );

    // =========================================================================
    // Output Assignments
    // =========================================================================
    assign led = led_mux;

    // Debug output for internal state visibility
    assign debug = {
        4'b0, game_select, 2'b0,  // [31:24] Game select
        3'b0, btn_level,           // [23:16] Button states
        score_mux,                 // [15:8]  Score
        check_ok_mux, 7'b0         // [7:0]   Status flags
    };

endmodule
