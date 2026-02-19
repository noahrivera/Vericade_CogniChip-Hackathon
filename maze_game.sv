// =============================================================================
// LED Maze Game - Teaching I/O and Combinational Logic
// Part of Vericade Logic Lab Arcade
// =============================================================================
// Navigate an 8x8 maze from start (0,0) to goal (7,7).
//
// Button Mapping:
//   btn_pulse[0] - Move Up
//   btn_pulse[1] - Move Down
//   btn_pulse[2] - Move Left
//   btn_pulse[3] - Move Right
//   btn_pulse[4] - Reset position (Select)
//
// LED Outputs:
//   led[0] - Goal reached flag
//   led[7:1] - Move counter (counts valid moves)
//
// Display: Shows walls (dim), player (bright pulse), goal (bright solid)
// =============================================================================

module maze_game (
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  btn_pulse,
    input  logic [15:0] sw,         // Not used
    output logic [15:0] led,
    output logic [63:0] grid,
    output logic        check_ok,   // 1 when at goal
    output logic [7:0]  score       // Move count
);

    // Player position
    logic [2:0] player_x, player_y;

    // Goal position (fixed)
    localparam logic [2:0] GOAL_X = 3'd7;
    localparam logic [2:0] GOAL_Y = 3'd7;

    // Move counter
    logic [6:0] move_count;

    // =========================================================================
    // Maze Definition - 1=wall, 0=path
    // Simple maze with clear path from (0,0) to (7,7)
    // =========================================================================
    logic [63:0] maze_walls;
    initial begin
        maze_walls = 64'h0;
        // Define walls (educational simple maze)
        // Row 0: ....###.
        maze_walls[4] = 1'b1; maze_walls[5] = 1'b1; maze_walls[6] = 1'b1;
        // Row 1: ..#.###.
        maze_walls[10] = 1'b1; maze_walls[12] = 1'b1; 
        maze_walls[13] = 1'b1; maze_walls[14] = 1'b1;
        // Row 2: ..#.....
        maze_walls[18] = 1'b1;
        // Row 3: ..###.#.
        maze_walls[26] = 1'b1; maze_walls[27] = 1'b1; 
        maze_walls[28] = 1'b1; maze_walls[30] = 1'b1;
        // Row 4: ....#.#.
        maze_walls[36] = 1'b1; maze_walls[38] = 1'b1;
        // Row 5: .##.#...
        maze_walls[41] = 1'b1; maze_walls[42] = 1'b1; maze_walls[44] = 1'b1;
        // Row 6: .##.....
        maze_walls[49] = 1'b1; maze_walls[50] = 1'b1;
        // Row 7: ........ (clear path to goal)
    end

    // =========================================================================
    // Wall Check Function (Yosys-compatible classic Verilog syntax)
    // =========================================================================
    function is_wall;
        input [2:0] x;
        input [2:0] y;
        reg [5:0] index;
        begin
            index = {y, x};  // Flatten 2D coordinate
            is_wall = maze_walls[index];
        end
    endfunction

    // =========================================================================
    // Player Movement Logic
    // =========================================================================
    logic [2:0] next_x, next_y;
    logic move_valid;

    always_comb begin
        // Default: no movement
        next_x = player_x;
        next_y = player_y;
        move_valid = 1'b0;

        // Check button presses and calculate next position
        if (btn_pulse[0]) begin  // Up
            if (player_y > 0) begin
                next_y = player_y - 1'b1;
                move_valid = !is_wall(next_x, next_y);
            end
        end else if (btn_pulse[1]) begin  // Down
            if (player_y < 7) begin
                next_y = player_y + 1'b1;
                move_valid = !is_wall(next_x, next_y);
            end
        end else if (btn_pulse[2]) begin  // Left
            if (player_x > 0) begin
                next_x = player_x - 1'b1;
                move_valid = !is_wall(next_x, next_y);
            end
        end else if (btn_pulse[3]) begin  // Right
            if (player_x < 7) begin
                next_x = player_x + 1'b1;
                move_valid = !is_wall(next_x, next_y);
            end
        end

        // Reset button overrides
        if (btn_pulse[4]) begin
            next_x = 3'd0;
            next_y = 3'd0;
            move_valid = 1'b1;
        end
    end

    // Update player position
    always_ff @(posedge clk) begin
        if (rst) begin
            player_x <= 3'd0;
            player_y <= 3'd0;
            move_count <= 7'd0;
        end else begin
            if (move_valid) begin
                player_x <= next_x;
                player_y <= next_y;
                if (!btn_pulse[4]) begin  // Don't count resets
                    move_count <= move_count + 1'b1;
                end
            end
        end
    end

    // =========================================================================
    // Goal Detection
    // =========================================================================
    logic goal_reached;
    assign goal_reached = (player_x == GOAL_X) && (player_y == GOAL_Y);

    // =========================================================================
    // LED Outputs
    // =========================================================================
    assign led[0] = goal_reached;
    assign led[7:1] = move_count;
    assign led[15:8] = '0;

    // =========================================================================
    // Grid Display
    // =========================================================================
    // Show: walls (solid), player (blinking), goal (solid)
    logic blink;
    logic [25:0] blink_counter;

    // Blink counter for player visibility (~12Hz blink @ 50MHz)
    always_ff @(posedge clk) begin
        if (rst) begin
            blink_counter <= '0;
            blink <= 1'b0;
        end else begin
            if (blink_counter < 26'd4_166_666) begin
                blink_counter <= blink_counter + 1'b1;
            end else begin
                blink_counter <= '0;
                blink <= ~blink;
            end
        end
    end

    // Generate grid
    always_comb begin
        grid = maze_walls;  // Start with walls

        // Add goal marker (always on)
        grid[{GOAL_Y, GOAL_X}] = 1'b1;

        // Add player marker (blinking unless at goal)
        if (blink || goal_reached) begin
            grid[{player_y, player_x}] = 1'b1;
        end
    end

    // =========================================================================
    // Status Outputs
    // =========================================================================
    assign check_ok = goal_reached;
    assign score = {1'b0, move_count};

endmodule
