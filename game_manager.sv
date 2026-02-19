// =============================================================================
// Game Manager - Routes Between Four Game Modules
// Part of Vericade Logic Lab Arcade
// =============================================================================
// Selects active game based on sw[1:0] and routes I/O appropriately.
//
// Game Selection (sw[1:0]):
//   00 - Binary Adder Calculator
//   01 - LED Maze
//   10 - Tic-Tac-Toe
//   11 - Connect Four
//
// Routes button inputs to selected game and multiplexes outputs back to top.
// =============================================================================

module game_manager (
    input  logic        clk,
    input  logic        rst,
    input  logic [1:0]  game_select,      // From sw[1:0]
    input  logic [4:0]  btn_pulse,
    input  logic [15:0] sw,
    
    // Outputs from all games (inputs to this module)
    input  logic [15:0] led_adder,
    input  logic [63:0] grid_adder,
    input  logic        check_ok_adder,
    input  logic [7:0]  score_adder,
    
    input  logic [15:0] led_maze,
    input  logic [63:0] grid_maze,
    input  logic        check_ok_maze,
    input  logic [7:0]  score_maze,
    
    input  logic [15:0] led_tictactoe,
    input  logic [63:0] grid_tictactoe,
    input  logic        check_ok_tictactoe,
    input  logic [7:0]  score_tictactoe,
    
    input  logic [15:0] led_connect4,
    input  logic [63:0] grid_connect4,
    input  logic        check_ok_connect4,
    input  logic [7:0]  score_connect4,
    
    // Multiplexed outputs
    output logic [15:0] led_out,
    output logic [63:0] grid_out,
    output logic        check_ok_out,
    output logic [7:0]  score_out
);

    // =========================================================================
    // Output Multiplexer - Select Active Game Outputs
    // =========================================================================
    always_comb begin
        // Default values
        led_out = 16'h0;
        grid_out = 64'h0;
        check_ok_out = 1'b0;
        score_out = 8'h0;

        case (game_select)
            2'b00: begin  // Binary Adder
                led_out = led_adder;
                grid_out = grid_adder;
                check_ok_out = check_ok_adder;
                score_out = score_adder;
            end

            2'b01: begin  // LED Maze
                led_out = led_maze;
                grid_out = grid_maze;
                check_ok_out = check_ok_maze;
                score_out = score_maze;
            end

            2'b10: begin  // Tic-Tac-Toe
                led_out = led_tictactoe;
                grid_out = grid_tictactoe;
                check_ok_out = check_ok_tictactoe;
                score_out = score_tictactoe;
            end

            2'b11: begin  // Connect Four
                led_out = led_connect4;
                grid_out = grid_connect4;
                check_ok_out = check_ok_connect4;
                score_out = score_connect4;
            end
        endcase

        // Game selection indicator on top LED bits
        led_out[15:14] = game_select;
    end

endmodule
