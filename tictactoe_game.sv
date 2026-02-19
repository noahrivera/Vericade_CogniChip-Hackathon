// =============================================================================
// Tic-Tac-Toe Game - Teaching FSM and Game Logic
// Part of Vericade Logic Lab Arcade
// =============================================================================
// Classic 3x3 Tic-Tac-Toe with cursor-based input.
//
// Button Mapping:
//   btn_pulse[0] - Move cursor Up
//   btn_pulse[1] - Move cursor Down
//   btn_pulse[2] - Move cursor Left
//   btn_pulse[3] - Move cursor Right
//   btn_pulse[4] - Place mark / Reset game (Select)
//
// LED Outputs:
//   led[1:0] - Current player (00=none, 01=X, 10=O)
//   led[2]   - Win flag
//   led[3]   - Draw flag
//   led[7:4] - Move count
//
// Board representation: 0=empty, 1=X, 2=O
// Display: 3x3 board mapped to center of 8x8 grid (2 pixels per cell)
// =============================================================================

module tictactoe_game (
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  btn_pulse,
    input  logic [15:0] sw,         // Not used
    output logic [15:0] led,
    output logic [63:0] grid,
    output logic        check_ok,   // 1 when game won
    output logic [7:0]  score       // Moves to win (if won)
);

    // FSM States (one-hot encoding for clarity)
    typedef enum logic [3:0] {
        IDLE       = 4'b0001,  // Waiting to start
        PLAY       = 4'b0010,  // Active gameplay
        CHECK_WIN  = 4'b0100,  // Checking for win/draw
        GAME_OVER  = 4'b1000   // Win or draw - waiting for reset
    } state_t;

    state_t state, next_state;

    // Board: 3x3 array, each cell is 2 bits (00=empty, 01=X, 10=O)
    logic [1:0] board [2:0][2:0];

    // Cursor position
    logic [1:0] cursor_x, cursor_y;

    // Current player (1=X, 2=O)
    logic [1:0] current_player;

    // Game status
    logic win_flag, draw_flag;
    logic [3:0] move_count;

    // =========================================================================
    // FSM State Register
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // =========================================================================
    // FSM Next State Logic
    // =========================================================================
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                // Wait for select button to start
                if (btn_pulse[4]) begin
                    next_state = PLAY;
                end
            end

            PLAY: begin
                // After a valid move, check for win/draw
                if (btn_pulse[4] && board[cursor_y][cursor_x] == 2'b00) begin
                    next_state = CHECK_WIN;
                end
            end

            CHECK_WIN: begin
                // Immediately check then either continue or end game
                if (win_flag || draw_flag) begin
                    next_state = GAME_OVER;
                end else begin
                    next_state = PLAY;
                end
            end

            GAME_OVER: begin
                // Wait for select to reset
                if (btn_pulse[4]) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    // =========================================================================
    // Cursor Movement
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst || state == IDLE) begin
            cursor_x <= 2'd1;  // Start at center
            cursor_y <= 2'd1;
        end else if (state == PLAY) begin
            if (btn_pulse[0] && cursor_y > 0) cursor_y <= cursor_y - 1'b1;  // Up
            if (btn_pulse[1] && cursor_y < 2) cursor_y <= cursor_y + 1'b1;  // Down
            if (btn_pulse[2] && cursor_x > 0) cursor_x <= cursor_x - 1'b1;  // Left
            if (btn_pulse[3] && cursor_x < 2) cursor_x <= cursor_x + 1'b1;  // Right
        end
    end

    // =========================================================================
    // Board Update and Player Switch
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst || (state == IDLE && btn_pulse[4])) begin
            // Clear board
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    board[i][j] <= 2'b00;
                end
            end
            current_player <= 2'b01;  // X starts
            move_count <= 4'd0;
        end else if (state == PLAY && btn_pulse[4]) begin
            // Place mark if cell is empty
            if (board[cursor_y][cursor_x] == 2'b00) begin
                board[cursor_y][cursor_x] <= current_player;
                move_count <= move_count + 1'b1;
            end
        end else if (state == CHECK_WIN && !win_flag && !draw_flag) begin
            // Switch player for next turn
            current_player <= (current_player == 2'b01) ? 2'b10 : 2'b01;
        end
    end

    // =========================================================================
    // Win Detection Logic
    // =========================================================================
    logic win_x, win_o;

    always_comb begin
        win_x = 1'b0;
        win_o = 1'b0;

        // Check rows
        for (int i = 0; i < 3; i++) begin
            if (board[i][0] == 2'b01 && board[i][1] == 2'b01 && board[i][2] == 2'b01) win_x = 1'b1;
            if (board[i][0] == 2'b10 && board[i][1] == 2'b10 && board[i][2] == 2'b10) win_o = 1'b1;
        end

        // Check columns
        for (int j = 0; j < 3; j++) begin
            if (board[0][j] == 2'b01 && board[1][j] == 2'b01 && board[2][j] == 2'b01) win_x = 1'b1;
            if (board[0][j] == 2'b10 && board[1][j] == 2'b10 && board[2][j] == 2'b10) win_o = 1'b1;
        end

        // Check diagonals
        if (board[0][0] == 2'b01 && board[1][1] == 2'b01 && board[2][2] == 2'b01) win_x = 1'b1;
        if (board[0][0] == 2'b10 && board[1][1] == 2'b10 && board[2][2] == 2'b10) win_o = 1'b1;
        if (board[0][2] == 2'b01 && board[1][1] == 2'b01 && board[2][0] == 2'b01) win_x = 1'b1;
        if (board[0][2] == 2'b10 && board[1][1] == 2'b10 && board[2][0] == 2'b10) win_o = 1'b1;
    end

    // =========================================================================
    // Draw Detection Logic
    // =========================================================================
    logic board_full;

    always_comb begin
        board_full = 1'b1;
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                if (board[i][j] == 2'b00) board_full = 1'b0;
            end
        end
    end

    // =========================================================================
    // Game Status Flags
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst || state == IDLE) begin
            win_flag <= 1'b0;
            draw_flag <= 1'b0;
        end else if (state == CHECK_WIN) begin
            win_flag <= win_x || win_o;
            draw_flag <= board_full && !win_x && !win_o;
        end
    end

    // =========================================================================
    // LED Outputs
    // =========================================================================
    assign led[1:0] = current_player;
    assign led[2] = win_flag;
    assign led[3] = draw_flag;
    assign led[7:4] = move_count;
    assign led[15:8] = '0;

    // =========================================================================
    // Grid Display - Map 3x3 board to 8x8 grid (2x2 pixels per cell)
    // =========================================================================
    // Board occupies rows 1-6, cols 1-6 (centered in 8x8)
    always_comb begin
        grid = 64'h0;

        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                logic [2:0] base_row, base_col;
                base_row = 1 + i * 2;  // Rows 1,3,5
                base_col = 1 + j * 2;  // Cols 1,3,5

                // Draw 2x2 block for each cell if occupied
                if (board[i][j] != 2'b00) begin
                    grid[{base_row, base_col}] = 1'b1;
                    grid[{base_row, base_col + 3'd1}] = 1'b1;
                    grid[{base_row + 3'd1, base_col}] = 1'b1;
                    grid[{base_row + 3'd1, base_col + 3'd1}] = 1'b1;

                    // Differentiate X (solid) vs O (hollow)
                    if (board[i][j] == 2'b10) begin  // O is hollow
                        grid[{base_row, base_col}] = 1'b0;
                        grid[{base_row + 3'd1, base_col + 3'd1}] = 1'b0;
                    end
                end

                // Draw cursor (blinking border) if in PLAY state
                if (state == PLAY && cursor_x == j && cursor_y == i) begin
                    // Simple cursor: light up corners
                    grid[{base_row, base_col}] = 1'b1;
                    grid[{base_row + 3'd1, base_col + 3'd1}] = 1'b1;
                end
            end
        end
    end

    // =========================================================================
    // Status Outputs
    // =========================================================================
    assign check_ok = win_flag;
    assign score = {4'b0, move_count};

endmodule
