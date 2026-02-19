// =============================================================================
// Connect Four Game - Teaching Arrays and Sequential Logic (Capstone)
// Part of Vericade Logic Lab Arcade
// =============================================================================
// Classic Connect Four: 7 columns x 6 rows, drop pieces to connect 4.
//
// Button Mapping:
//   btn_pulse[2] - Move cursor Left
//   btn_pulse[3] - Move cursor Right
//   btn_pulse[4] - Drop piece / Reset game (Select)
//
// LED Outputs:
//   led[1:0] - Current player (01=Red, 10=Yellow)
//   led[2]   - Win flag
//   led[3]   - Invalid move flag (column full)
//   led[6:4] - Current column cursor
//   led[10:7] - Move count
//
// Board representation: 0=empty, 1=Red, 2=Yellow
// Display: 7x6 board mapped to center of 8x8 grid
// =============================================================================

module connect4_game (
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  btn_pulse,
    input  logic [15:0] sw,         // Not used
    output logic [15:0] led,
    output logic [63:0] grid,
    output logic        check_ok,   // 1 when game won
    output logic [7:0]  score       // Moves to win (if won)
);

    // FSM States
    typedef enum logic [2:0] {
        IDLE       = 3'b001,
        PLAY       = 3'b010,
        DROP       = 3'b011,
        CHECK_WIN  = 3'b100,
        GAME_OVER  = 3'b101
    } state_t;

    state_t state, next_state;

    // Board: 7 columns x 6 rows, each cell is 2 bits (00=empty, 01=Red, 10=Yellow)
    logic [1:0] board [5:0][6:0];  // [row][col]

    // Cursor position (column selector)
    logic [2:0] cursor_col;

    // Current player (1=Red, 2=Yellow)
    logic [1:0] current_player;

    // Drop animation
    logic [2:0] drop_row;       // Current drop position
    logic [2:0] target_row;     // Final row for dropped piece
    logic drop_active;

    // Game status
    logic win_flag;
    logic invalid_move_flag;
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
                if (btn_pulse[4]) begin
                    next_state = PLAY;
                end
            end

            PLAY: begin
                if (btn_pulse[4]) begin
                    next_state = DROP;
                end
            end

            DROP: begin
                // Wait for drop animation to complete
                if (!drop_active) begin
                    next_state = CHECK_WIN;
                end
            end

            CHECK_WIN: begin
                if (win_flag) begin
                    next_state = GAME_OVER;
                end else if (invalid_move_flag) begin
                    next_state = PLAY;  // Try again
                end else begin
                    next_state = PLAY;
                end
            end

            GAME_OVER: begin
                if (btn_pulse[4]) begin
                    next_state = IDLE;
                end
            end

            default: next_state = IDLE;
        endcase
    end

    // =========================================================================
    // Cursor Movement (Column Selection)
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst || state == IDLE) begin
            cursor_col <= 3'd3;  // Start at center
        end else if (state == PLAY) begin
            if (btn_pulse[2] && cursor_col > 0) cursor_col <= cursor_col - 1'b1;  // Left
            if (btn_pulse[3] && cursor_col < 6) cursor_col <= cursor_col + 1'b1;  // Right
        end
    end

    // =========================================================================
    // Find Lowest Empty Row in Column
    // =========================================================================
    function automatic logic [2:0] find_empty_row(input logic [2:0] col);
        for (int r = 5; r >= 0; r--) begin
            if (board[r][col] == 2'b00) begin
                return r[2:0];
            end
        end
        return 3'd7;  // Invalid (column full)
    endfunction

    // =========================================================================
    // Drop Animation Logic
    // =========================================================================
    logic [23:0] drop_counter;
    localparam DROP_DELAY = 24'd2_500_000;  // ~50ms @ 50MHz

    always_ff @(posedge clk) begin
        if (rst || state == IDLE) begin
            drop_active <= 1'b0;
            drop_row <= 3'd0;
            drop_counter <= '0;
        end else if (state == DROP && !drop_active) begin
            // Start drop animation
            target_row <= find_empty_row(cursor_col);
            if (target_row != 3'd7) begin  // Valid drop
                drop_active <= 1'b1;
                drop_row <= 3'd0;
                drop_counter <= '0;
            end else begin
                drop_active <= 1'b0;  // Invalid, skip animation
            end
        end else if (drop_active) begin
            if (drop_counter < DROP_DELAY) begin
                drop_counter <= drop_counter + 1'b1;
            end else begin
                drop_counter <= '0;
                if (drop_row < target_row) begin
                    drop_row <= drop_row + 1'b1;
                end else begin
                    drop_active <= 1'b0;  // Animation complete
                end
            end
        end
    end

    // =========================================================================
    // Board Update Logic
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst || (state == IDLE && btn_pulse[4])) begin
            // Clear board
            for (int i = 0; i < 6; i++) begin
                for (int j = 0; j < 7; j++) begin
                    board[i][j] <= 2'b00;
                end
            end
            current_player <= 2'b01;  // Red starts
            move_count <= 4'd0;
            invalid_move_flag <= 1'b0;
        end else if (state == DROP && !drop_active && target_row != 3'd7) begin
            // Place piece at target row
            board[target_row][cursor_col] <= current_player;
            invalid_move_flag <= 1'b0;
        end else if (state == DROP && !drop_active && target_row == 3'd7) begin
            // Invalid move (column full)
            invalid_move_flag <= 1'b1;
        end else if (state == CHECK_WIN && !win_flag && !invalid_move_flag) begin
            // Switch player and increment move count
            current_player <= (current_player == 2'b01) ? 2'b10 : 2'b01;
            move_count <= move_count + 1'b1;
        end
    end

    // =========================================================================
    // Win Detection Logic (4 in a row)
    // =========================================================================
    logic win_red, win_yellow;

    always_comb begin
        win_red = 1'b0;
        win_yellow = 1'b0;

        // Check horizontal
        for (int r = 0; r < 6; r++) begin
            for (int c = 0; c < 4; c++) begin
                if (board[r][c] == 2'b01 && board[r][c+1] == 2'b01 && 
                    board[r][c+2] == 2'b01 && board[r][c+3] == 2'b01) win_red = 1'b1;
                if (board[r][c] == 2'b10 && board[r][c+1] == 2'b10 && 
                    board[r][c+2] == 2'b10 && board[r][c+3] == 2'b10) win_yellow = 1'b1;
            end
        end

        // Check vertical
        for (int r = 0; r < 3; r++) begin
            for (int c = 0; c < 7; c++) begin
                if (board[r][c] == 2'b01 && board[r+1][c] == 2'b01 && 
                    board[r+2][c] == 2'b01 && board[r+3][c] == 2'b01) win_red = 1'b1;
                if (board[r][c] == 2'b10 && board[r+1][c] == 2'b10 && 
                    board[r+2][c] == 2'b10 && board[r+3][c] == 2'b10) win_yellow = 1'b1;
            end
        end

        // Check diagonal (down-right)
        for (int r = 0; r < 3; r++) begin
            for (int c = 0; c < 4; c++) begin
                if (board[r][c] == 2'b01 && board[r+1][c+1] == 2'b01 && 
                    board[r+2][c+2] == 2'b01 && board[r+3][c+3] == 2'b01) win_red = 1'b1;
                if (board[r][c] == 2'b10 && board[r+1][c+1] == 2'b10 && 
                    board[r+2][c+2] == 2'b10 && board[r+3][c+3] == 2'b10) win_yellow = 1'b1;
            end
        end

        // Check diagonal (down-left)
        for (int r = 0; r < 3; r++) begin
            for (int c = 3; c < 7; c++) begin
                if (board[r][c] == 2'b01 && board[r+1][c-1] == 2'b01 && 
                    board[r+2][c-2] == 2'b01 && board[r+3][c-3] == 2'b01) win_red = 1'b1;
                if (board[r][c] == 2'b10 && board[r+1][c-1] == 2'b10 && 
                    board[r+2][c-2] == 2'b10 && board[r+3][c-3] == 2'b10) win_yellow = 1'b1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst || state == IDLE) begin
            win_flag <= 1'b0;
        end else if (state == CHECK_WIN) begin
            win_flag <= win_red || win_yellow;
        end
    end

    // =========================================================================
    // LED Outputs
    // =========================================================================
    assign led[1:0] = current_player;
    assign led[2] = win_flag;
    assign led[3] = invalid_move_flag;
    assign led[6:4] = cursor_col;
    assign led[10:7] = move_count;
    assign led[15:11] = '0;

    // =========================================================================
    // Grid Display - Map 7x6 board to 8x8 grid
    // =========================================================================
    // Board occupies rows 1-6, cols 0-6 (bottom-left aligned)
    always_comb begin
        grid = 64'h0;

        // Draw board (rows 0-5 map to grid rows 2-7, cols 0-6)
        for (int r = 0; r < 6; r++) begin
            for (int c = 0; c < 7; c++) begin
                logic [2:0] grid_row, grid_col;
                grid_row = 7 - r;  // Flip vertically (bottom = row 7)
                grid_col = c;

                if (board[r][c] != 2'b00) begin
                    grid[{grid_row, grid_col}] = 1'b1;
                end
            end
        end

        // Draw dropping piece during animation
        if (drop_active) begin
            logic [2:0] anim_row;
            anim_row = 7 - drop_row;
            grid[{anim_row, cursor_col}] = 1'b1;
        end

        // Draw cursor at top (row 0)
        if (state == PLAY) begin
            grid[{3'd0, cursor_col}] = 1'b1;
        end
    end

    // =========================================================================
    // Status Outputs
    // =========================================================================
    assign check_ok = win_flag;
    assign score = {4'b0, move_count};

endmodule
