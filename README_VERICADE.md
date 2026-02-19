# VERICADE - Educational FPGA Logic Lab Arcade

**An educational platform for teaching Verilog and digital logic through progressive game modules**

---

## Overview

Vericade is a complete FPGA-based educational system featuring four interactive games that progressively teach digital design concepts:

1. **Binary Adder Calculator** - Arithmetic logic & binary representation
2. **LED Maze Navigator** - I/O mapping & combinational logic  
3. **Tic-Tac-Toe** - Finite state machines (FSM)
4. **Connect Four** - Arrays & sequential logic (capstone)

Each game is implemented as a synthesizable SystemVerilog module with self-checking testbenches.

---

## File Structure

### Core RTL Modules
- `vericade_top.sv` - Top-level integration (game selector, I/O routing)
- `input_controller.sv` - Button debouncing & edge detection
- `game_manager.sv` - Game output multiplexer
- `matrix_driver.sv` - 8×8 LED matrix scanning controller

### Game Modules
- `binary_adder_game.sv` - Calculator with structural/behavioral adder options
- `full_adder.sv` - Educational 1-bit full adder (structural building block)
- `maze_game.sv` - Navigable maze with wall collision detection
- `tictactoe_game.sv` - 3×3 game with FSM-based control
- `connect4_game.sv` - 7×6 game with 4-in-a-row win detection

### Testbenches
- `tb_binary_adder_game.sv` - Exhaustive arithmetic verification
- `tb_maze_game.sv` - Path navigation & goal detection tests
- `tb_tictactoe_game.sv` - Win/draw scenario coverage
- `tb_connect4_game.sv` - Multi-direction win detection tests
- `vericade_autograde_tb.sv` - Comprehensive integration test suite

---

## Hardware Interface

### Inputs
- **clk** - System clock (default: 50 MHz)
- **rst** - Active-high synchronous reset
- **sw[15:0]** - 16 switches (game selection + game-specific controls)
- **btn[4:0]** - 5 buttons (Up, Down, Left, Right, Select)

### Outputs
- **matrix_row[7:0]** - LED matrix row select (one-hot, active-high)
- **matrix_col[7:0]** - LED matrix column data (active-high = LED on)
- **led[15:0]** - Status LEDs (game-specific + game selection indicator)
- **debug[31:0]** - Internal state visibility for debugging

### Display System
The platform uses an 8×8 LED matrix with row-scanning refresh:
- Refresh rate: 1 kHz (configurable)
- Row multiplexing: one row active at a time
- Active-high signaling for both rows and columns

---

## Game Controls

### Game Selection
**sw[1:0]** selects the active game:
- `00` = Binary Adder Calculator
- `01` = LED Maze Navigator
- `10` = Tic-Tac-Toe
- `11` = Connect Four

### Button Functions (Game-Dependent)
- **btn[0]** - Up / Move cursor up
- **btn[1]** - Down / Move cursor down
- **btn[2]** - Left / Move cursor left
- **btn[3]** - Right / Move cursor right
- **btn[4]** - Select / Place mark / Drop piece / Reset

---

## Game-Specific Details

### 1. Binary Adder Calculator (Game 00)

**Educational Focus:** Binary arithmetic, carry propagation, two's complement

**Switch Mapping:**
- `sw[3:0]` - Operand A (4-bit)
- `sw[7:4]` - Operand B (4-bit)  
- `sw[9:8]` - Mode select:
  - `00` = Display A
  - `01` = Display B
  - `10` = Display A + B (with carry)
  - `11` = Display A - B (two's complement)

**LED Outputs:**
- `led[7:0]` - Result value
- `led[8]` - Carry/borrow flag

**Display:** Visual binary representation (vertical bars for each bit)

**Design Note:** Can switch between structural (ripple-carry) and behavioral implementation via `USE_STRUCTURAL` parameter.

---

### 2. LED Maze Navigator (Game 01)

**Educational Focus:** Combinational boundaries, collision detection, state tracking

**Maze Layout:** 8×8 grid with fixed wall positions (educational path from (0,0) to (7,7))

**Button Controls:**
- Arrow buttons move player (if not blocked by wall)
- Select button resets position to start

**LED Outputs:**
- `led[0]` - Goal reached flag
- `led[7:1]` - Move counter (valid moves only)

**Display:** 
- Walls: solid pixels
- Player: blinking marker (~12 Hz)
- Goal: solid marker at (7,7)

---

### 3. Tic-Tac-Toe (Game 10)

**Educational Focus:** FSM design, game logic, win condition detection

**Game Flow:**
1. Press Select to start game (IDLE → PLAY)
2. Move cursor with arrow buttons
3. Press Select to place mark (if cell empty)
4. Game alternates between X and O
5. Automatic win/draw detection (PLAY → CHECK_WIN → GAME_OVER)
6. Press Select to reset and play again

**LED Outputs:**
- `led[1:0]` - Current player (`01`=X, `10`=O)
- `led[2]` - Win flag
- `led[3]` - Draw flag
- `led[7:4]` - Move count

**Display:** 3×3 board mapped to center of 8×8 grid
- X markers: solid 2×2 blocks
- O markers: hollow 2×2 blocks (diagonal pixels clear)
- Cursor: corner pixels highlighted

**FSM States:** IDLE, PLAY, CHECK_WIN, GAME_OVER

---

### 4. Connect Four (Game 11)

**Educational Focus:** 2D arrays, gravity simulation, complex win detection

**Game Rules:**
- 7 columns × 6 rows (classic Connect Four dimensions)
- Pieces drop to lowest available row in selected column
- Connect 4 pieces horizontally, vertically, or diagonally to win

**Button Controls:**
- Left/Right: move column selector
- Select: drop piece in current column (starts drop animation)

**LED Outputs:**
- `led[1:0]` - Current player (`01`=Red, `10`=Yellow)
- `led[2]` - Win flag
- `led[3]` - Invalid move flag (column full)
- `led[6:4]` - Current column cursor position
- `led[10:7]` - Move count

**Display:** 7×6 board mapped to 8×8 grid (bottom-left aligned)
- Shows falling piece during drop animation (~50ms per row)
- Column cursor visible at top row

**Win Detection:** Checks all four directions:
- Horizontal (4 adjacent in any row)
- Vertical (4 stacked in any column)
- Diagonal down-right
- Diagonal down-left

---

## Testbench Usage

### Individual Game Tests

Run each game's dedicated testbench for focused verification:

```bash
# Binary Adder - tests all modes and arithmetic cases
vsim -do "run -all" tb_binary_adder_game

# Maze - tests path navigation and collision
vsim -do "run -all" tb_maze_game

# Tic-Tac-Toe - tests win/draw scenarios
vsim -do "run -all" tb_tictactoe_game

# Connect Four - tests win detection
vsim -do "run -all" tb_connect4_game
```

### Comprehensive Auto-Grader

Run the complete integration test suite:

```bash
vsim -do "run -all" vericade_autograde_tb
```

**Auto-Grader Output:**
- Per-game test statistics
- Overall pass/fail summary
- Detailed test case results
- Final pass rate percentage

---

## Design Features

### Educational Highlights

1. **Progressive Complexity**
   - Game 1: Pure combinational (adder)
   - Game 2: Basic sequential (position tracking)
   - Game 3: FSM + game logic (state-based control)
   - Game 4: Complex sequential (2D arrays + multi-directional checks)

2. **Teaching Constructs**
   - `always_ff` for sequential logic (no latches)
   - `always_comb` for combinational logic
   - Parameterization for configurability
   - Generate blocks for scalable structures
   - Functions for code reuse

3. **Best Practices Demonstrated**
   - Synchronous resets throughout
   - Two-stage synchronizers for external inputs
   - Debouncing with configurable time constants
   - Edge detection for button presses
   - Modular hierarchy with clean interfaces

### Board-Agnostic Design

- No vendor-specific IP or primitives
- Generic clock frequency parameter (default 50 MHz)
- Simple I/O: switches, buttons, LEDs, matrix display
- Easily portable to any FPGA platform

---

## Synthesis Notes

### Resource Estimates (Typical FPGA)

| Module | Logic Elements | Registers | Notes |
|--------|---------------|-----------|-------|
| Input Controller | ~100 | ~150 | 5 debouncers + sync |
| Matrix Driver | ~50 | ~30 | Row scanner |
| Binary Adder | ~100 | ~20 | Behavioral mode |
| Maze Game | ~200 | ~50 | ROM + position |
| Tic-Tac-Toe | ~300 | ~100 | FSM + 3×3 array |
| Connect Four | ~500 | ~150 | FSM + 7×6 array |
| **Total System** | **~1500** | **~500** | Including top-level |

### Timing Considerations

- All paths meet timing at 50 MHz (20ns period)
- Longest combinational path: win detection logic in Connect Four (~15ns)
- Matrix driver uses simple counter (minimal fanout)
- No timing-critical paths between games (multiplexed outputs)

---

## Parameters

### Top-Level (vericade_top.sv)

```systemverilog
parameter CLK_FREQ_HZ = 50_000_000;      // System clock frequency
parameter USE_STRUCTURAL_ADDER = 0;       // 1=ripple-carry, 0=behavioral
```

### Input Controller

```systemverilog
parameter CLK_FREQ_HZ = 50_000_000;      // Must match top-level
parameter DEBOUNCE_MS = 16;               // Debounce time (milliseconds)
```

### Matrix Driver

```systemverilog
parameter CLK_FREQ_HZ = 50_000_000;      // Must match top-level
parameter REFRESH_HZ = 1000;              // Matrix refresh rate (all rows)
```

---

## Extension Ideas

### For Advanced Students

1. **Add VGA Output**
   - Replace matrix_driver with simple VGA timing generator
   - Render games as colored tiles on monitor
   - Use 640×480 @ 60Hz standard timing

2. **Score Tracking**
   - Add persistent score memory (register file)
   - Display high scores on LED matrix
   - Implement score decay or reset mechanism

3. **AI Opponent**
   - Implement minimax for Tic-Tac-Toe
   - Add basic heuristic AI for Connect Four
   - Toggle between 2-player and player-vs-AI modes

4. **Sound Effects**
   - Add PWM-based buzzer/speaker output
   - Generate tones for moves, wins, invalid actions
   - Implement simple melody sequencer for game over

5. **Additional Games**
   - Snake (arrays + collision + growth)
   - Pong (continuous movement + collision)
   - Simon Says (memory + sequence generation)
   - Tetris (advanced: rotation + line clearing)

---

## Educational Integration

### Suggested Lab Sequence

**Lab 1 - Binary Adder (Week 1-2)**
- Learn: Binary arithmetic, full adder design, structural vs behavioral
- Tasks: Modify to 8-bit, add overflow detection, implement BCD mode

**Lab 2 - LED Maze (Week 3-4)**  
- Learn: Combinational boundaries, ROM, collision detection
- Tasks: Design custom maze, add multiple levels, implement timer

**Lab 3 - Tic-Tac-Toe (Week 5-6)**
- Learn: FSM design, state transitions, game logic
- Tasks: Add move undo, implement 4×4 variant, create AI opponent

**Lab 4 - Connect Four (Week 7-8)**
- Learn: 2D arrays, complex sequential logic, win detection
- Tasks: Add gravity animation, implement score system, create replay mode

**Lab 5 - Integration Project (Week 9-10)**
- Integrate all games, add game selection menu, implement save/load

---

## Troubleshooting

### Common Issues

**Problem:** Buttons don't respond reliably
- **Solution:** Increase DEBOUNCE_MS parameter (default 16ms may be too short for some switches)

**Problem:** LED matrix flickers
- **Solution:** Increase REFRESH_HZ parameter or reduce clock frequency divider

**Problem:** Game state doesn't reset properly
- **Solution:** Verify reset is connected and active-high throughout hierarchy

**Problem:** Synthesis warnings about inferred latches
- **Solution:** All combinational blocks should assign all outputs in all paths (use default assignments)

### Simulation Tips

- Use long enough simulation times for drop animations (~1ms real-time = 50,000 clock cycles @ 50MHz)
- Debounce logic requires ~1-2 million cycles to test properly (or reduce DEBOUNCE_MS in testbench)
- Matrix driver refresh takes 8 row periods to complete full frame

---

## License & Credits

**Vericade Educational Platform**  
Designed for teaching digital logic and Verilog/SystemVerilog

**Author:** Cognichip Co-Designer  
**Target Audience:** Undergraduate digital design courses, FPGA hobbyists

**Usage:** Free for educational purposes. Commercial use requires permission.

---

## Contact & Support

For questions, bug reports, or contributions:
- Review testbench outputs for debugging guidance
- Check synthesis reports for resource utilization
- Verify timing reports meet 50 MHz constraint

**Happy Learning!** 🎮🔧
