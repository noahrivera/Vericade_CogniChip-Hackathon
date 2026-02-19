# VERICADE DEPS.yml Usage Guide

**Status:** ✅ **DEPS FILE READY FOR SIMULATION**  
**File:** `DEPS.yml`

---

## Overview

The DEPS.yml file defines all simulation and build targets for the Vericade educational platform. It manages dependencies and ensures files are compiled in the correct order.

---

## Quick Start

### Run Individual Game Tests

```bash
# Test Binary Adder
sim DEPS.yml bench_binary_adder

# Test LED Maze
sim DEPS.yml bench_maze

# Test Tic-Tac-Toe
sim DEPS.yml bench_tictactoe

# Test Connect Four
sim DEPS.yml bench_connect4
```

### Run Integration Test

```bash
# Test complete system (all games)
sim DEPS.yml bench_autograde
```

---

## Available Targets

### Simulation Targets (Testbenches)

| Target Name | Description | Files Included | Top Module |
|-------------|-------------|----------------|------------|
| `bench_binary_adder` | Binary adder game test | full_adder.sv, binary_adder_game.sv, tb | tb_binary_adder_game |
| `bench_maze` | LED maze game test | maze_game.sv, tb | tb_maze_game |
| `bench_tictactoe` | Tic-tac-toe game test | tictactoe_game.sv, tb | tb_tictactoe_game |
| `bench_connect4` | Connect four game test | connect4_game.sv, tb | tb_connect4_game |
| `bench_autograde` | Complete system integration | All RTL + tb | vericade_autograde_tb |

### RTL-Only Targets (Synthesis/Elaboration)

| Target Name | Description | Files Included | Top Module |
|-------------|-------------|----------------|------------|
| `rtl_binary_adder` | Binary adder RTL only | full_adder.sv, binary_adder_game.sv | binary_adder_game |
| `rtl_maze` | Maze game RTL only | maze_game.sv | maze_game |
| `rtl_tictactoe` | Tic-tac-toe RTL only | tictactoe_game.sv | tictactoe_game |
| `rtl_connect4` | Connect four RTL only | connect4_game.sv | connect4_game |
| `rtl_top` | Complete system RTL | All 9 RTL files | vericade_top |

### Helper Targets (Module-Level)

| Target Name | Description | Top Module |
|-------------|-------------|------------|
| `rtl_input_controller` | Input debouncer/sync | input_controller |
| `rtl_matrix_driver` | LED matrix scanner | matrix_driver |
| `rtl_game_manager` | Game multiplexer | game_manager |
| `rtl_full_adder` | 1-bit full adder | full_adder |

---

## Target Details

### 1. bench_binary_adder

**Purpose:** Verify binary adder arithmetic operations

**Dependencies:**
```yaml
deps:
  - full_adder.sv              # 1-bit full adder building block
  - binary_adder_game.sv       # Main adder game module
  - tb_binary_adder_game.sv    # Testbench
```

**Usage:**
```bash
sim DEPS.yml bench_binary_adder
```

**Expected Output:**
- Test count: ~50 tests
- Simulation time: < 1 second
- Waveform: dumpfile.fst

---

### 2. bench_maze

**Purpose:** Verify maze navigation and collision detection

**Dependencies:**
```yaml
deps:
  - maze_game.sv           # Maze game module
  - tb_maze_game.sv        # Testbench
```

**Usage:**
```bash
sim DEPS.yml bench_maze
```

**Expected Output:**
- Test count: 3 tests
- Simulation time: < 1 second
- Waveform: dumpfile.fst

---

### 3. bench_tictactoe

**Purpose:** Verify FSM operation and win detection

**Dependencies:**
```yaml
deps:
  - tictactoe_game.sv           # Tic-tac-toe game module
  - tb_tictactoe_game.sv        # Testbench
```

**Usage:**
```bash
sim DEPS.yml bench_tictactoe
```

**Expected Output:**
- Test count: 4 tests
- Simulation time: < 1 second
- Waveform: dumpfile.fst

---

### 4. bench_connect4

**Purpose:** Verify complex win detection and drop animation

**Dependencies:**
```yaml
deps:
  - connect4_game.sv           # Connect four game module
  - tb_connect4_game.sv        # Testbench
```

**Usage:**
```bash
sim DEPS.yml bench_connect4
```

**Expected Output:**
- Test count: 4 tests
- Simulation time: 1-2 seconds
- Waveform: dumpfile.fst

---

### 5. bench_autograde (Integration Test)

**Purpose:** Comprehensive system integration testing

**Dependencies:**
```yaml
deps:
  - full_adder.sv                # Building block
  - input_controller.sv          # Button handling
  - matrix_driver.sv             # Display driver
  - binary_adder_game.sv         # Game 1
  - maze_game.sv                 # Game 2
  - tictactoe_game.sv            # Game 3
  - connect4_game.sv             # Game 4
  - game_manager.sv              # Game multiplexer
  - vericade_top.sv              # Top-level integration
  - vericade_autograde_tb.sv     # Integration testbench
```

**Usage:**
```bash
sim DEPS.yml bench_autograde
```

**Expected Output:**
- Test count: 8 tests (across all games)
- Simulation time: 1-2 seconds
- Waveform: dumpfile.fst
- Comprehensive summary with per-game statistics

---

## Dependency Order Rationale

### Why Order Matters

SystemVerilog requires modules to be compiled before they are instantiated. The DEPS.yml file ensures correct compilation order.

### Binary Adder Dependencies

```
full_adder.sv              # Compiled first (no dependencies)
    ↓
binary_adder_game.sv       # Uses full_adder in generate block
    ↓
tb_binary_adder_game.sv    # Instantiates binary_adder_game
```

### Integration Test Dependencies

```
Building Blocks:
    full_adder.sv
    input_controller.sv
    matrix_driver.sv
        ↓
Game Modules:
    binary_adder_game.sv   (uses full_adder)
    maze_game.sv
    tictactoe_game.sv
    connect4_game.sv
        ↓
Integration Layer:
    game_manager.sv        (uses all game outputs)
        ↓
Top Level:
    vericade_top.sv        (instantiates all above)
        ↓
Testbench:
    vericade_autograde_tb.sv
```

---

## Common Workflows

### Development Workflow

1. **Test Individual Game:**
   ```bash
   sim DEPS.yml bench_binary_adder
   ```

2. **View Waveforms:**
   ```bash
   # Waveform automatically saved as dumpfile.fst
   vaporview dumpfile.fst
   # or
   gtkwave dumpfile.fst
   ```

3. **Fix Issues & Re-test:**
   ```bash
   # Edit RTL file
   vim binary_adder_game.sv
   
   # Re-run simulation
   sim DEPS.yml bench_binary_adder
   ```

### Integration Testing Workflow

1. **Test All Games:**
   ```bash
   sim DEPS.yml bench_autograde
   ```

2. **Check Summary:**
   - Look for "TEST PASSED" or "TEST FAILED"
   - Review per-game statistics
   - Check overall pass rate

3. **Debug Failures:**
   - Open dumpfile.fst in waveform viewer
   - Find failure point from test output
   - Examine signals around failure time

### Synthesis Preparation Workflow

1. **Check RTL Elaboration:**
   ```bash
   # Check individual modules
   elaborate DEPS.yml rtl_binary_adder
   elaborate DEPS.yml rtl_maze
   elaborate DEPS.yml rtl_tictactoe
   elaborate DEPS.yml rtl_connect4
   ```

2. **Check Top-Level:**
   ```bash
   elaborate DEPS.yml rtl_top
   ```

3. **Run Synthesis:**
   ```bash
   synthesize DEPS.yml rtl_top
   ```

---

## File Organization

### Current Directory Structure

```
/Users/xxxtentacion/cognichip/
├── DEPS.yml                        # ← Dependency configuration
│
├── RTL Files (9 files):
│   ├── full_adder.sv
│   ├── input_controller.sv
│   ├── matrix_driver.sv
│   ├── binary_adder_game.sv
│   ├── maze_game.sv
│   ├── tictactoe_game.sv
│   ├── connect4_game.sv
│   ├── game_manager.sv
│   └── vericade_top.sv
│
├── Testbench Files (5 files):
│   ├── tb_binary_adder_game.sv
│   ├── tb_maze_game.sv
│   ├── tb_tictactoe_game.sv
│   ├── tb_connect4_game.sv
│   └── vericade_autograde_tb.sv
│
└── Documentation Files:
    ├── README_VERICADE.md
    ├── CONSISTENCY_VERIFICATION_REPORT.md
    ├── TESTBENCH_READINESS_REPORT.md
    └── DEPS_USAGE_GUIDE.md           # ← You are here
```

### Generated Files (after simulation)

```
├── dumpfile.fst               # Waveform dump (FST format)
├── transcript                 # Simulator log
└── work/                      # Compiled library (simulator-specific)
```

---

## Troubleshooting

### Issue: "File not found"

**Symptom:**
```
Error: Cannot find file 'binary_adder_game.sv'
```

**Solution:**
- Ensure you're running from the correct directory (`/Users/xxxtentacion/cognichip/`)
- All paths in DEPS.yml are relative to the file location
- Verify file exists: `ls -la binary_adder_game.sv`

---

### Issue: "Module not defined"

**Symptom:**
```
Error: Module 'full_adder' is not defined
```

**Solution:**
- Check dependency order in DEPS.yml
- Ensure modules are listed before they are used
- Verify no circular dependencies

---

### Issue: "Top module not found"

**Symptom:**
```
Error: Top-level module 'tb_binary_adder_game' not found
```

**Solution:**
- Verify `top:` field matches actual module name in testbench
- Check module name spelling (case-sensitive)
- Ensure testbench file is in deps list

---

### Issue: "Simulation hangs"

**Symptom:**
- Simulation runs but never completes
- No "TEST PASSED" or "TEST FAILED" message

**Solution:**
- All testbenches have $finish calls
- Check waveform to see where simulation stuck
- Look for infinite loops or missing state transitions
- For Connect Four: Drop animation takes time (~50ms simulation time)

---

## Advanced Usage

### Running Multiple Tests in Sequence

```bash
#!/bin/bash
# Script: run_all_tests.sh

echo "Running all Vericade testbenches..."

# Individual game tests
sim DEPS.yml bench_binary_adder || exit 1
sim DEPS.yml bench_maze || exit 1
sim DEPS.yml bench_tictactoe || exit 1
sim DEPS.yml bench_connect4 || exit 1

# Integration test
sim DEPS.yml bench_autograde || exit 1

echo "All tests completed successfully!"
```

### Custom Simulation Parameters

If your simulator supports custom parameters via DEPS.yml:

```yaml
bench_binary_adder:
  deps:
    - full_adder.sv
    - binary_adder_game.sv
    - tb_binary_adder_game.sv
  top: tb_binary_adder_game
  defines:
    FAST_SIM: 1              # Optional: Speed up simulation
  plusargs:
    - notimingchecks         # Optional: Disable timing checks
```

---

## Validation Checklist

Before running simulations, verify:

- [x] All RTL files exist (9 files)
- [x] All testbench files exist (5 files)
- [x] DEPS.yml is in the same directory as RTL files
- [x] File paths are relative (no absolute paths)
- [x] Top module names match actual module definitions
- [x] Dependencies are listed in correct order
- [x] No circular dependencies

---

## Target Summary Table

### Quick Reference

| Target | Type | Files | Time | Use Case |
|--------|------|-------|------|----------|
| bench_binary_adder | TB | 3 | <1s | Test adder arithmetic |
| bench_maze | TB | 2 | <1s | Test maze navigation |
| bench_tictactoe | TB | 2 | <1s | Test TTT FSM |
| bench_connect4 | TB | 2 | 1-2s | Test C4 win detection |
| bench_autograde | TB | 10 | 1-2s | **Full system test** |
| rtl_top | RTL | 9 | N/A | Synthesis target |
| rtl_* | RTL | 1-2 | N/A | Module checks |

**Recommended:** Start with individual game tests, then run `bench_autograde` for integration verification.

---

## Success Criteria

### For Individual Tests

✅ Simulation completes with "TEST PASSED"  
✅ No errors in transcript  
✅ Waveform file generated (dumpfile.fst)  
✅ All test cases show [PASS]

### For Integration Test

✅ All 4 games tested successfully  
✅ Overall pass rate = 100%  
✅ Status shows "*** ALL TESTS PASSED ***"  
✅ Waveform captures full test sequence

---

## Next Steps

After successful simulation:

1. **Review Waveforms:** Open dumpfile.fst and verify signal behavior
2. **Run Synthesis:** Use `rtl_top` target to synthesize complete system
3. **FPGA Implementation:** Map to target FPGA board
4. **Hardware Testing:** Deploy and test on real hardware

---

## Support

For issues or questions:
- Check testbench output for detailed error messages
- Review waveforms for signal-level debugging
- Consult TESTBENCH_READINESS_REPORT.md for test details
- Verify CONSISTENCY_VERIFICATION_REPORT.md for module connections

---

*Guide generated for Vericade Educational Platform*  
*Compatible with Cognichip simulation environment*
