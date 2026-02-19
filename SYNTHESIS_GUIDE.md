# Vericade Synthesis Guide

**Complete guide for synthesizing the Vericade platform using Yosys**

---

## Quick Start

### Option 1: Using Makefile (Recommended)

```bash
# Synthesize complete system
make synth

# View statistics
make stats

# Synthesize individual games
make synth-games

# Compare game sizes
make compare

# Clean outputs
make clean
```

### Option 2: Direct Yosys Commands

```bash
# Synthesize complete system
yosys synth_vericade.ys

# Synthesize individual games
yosys synth_individual_games.ys
```

---

## Prerequisites

### Required Tools

1. **Yosys** - Open-source synthesis tool
   ```bash
   # Ubuntu/Debian
   sudo apt install yosys
   
   # macOS
   brew install yosys
   
   # From source
   git clone https://github.com/YosysHQ/yosys.git
   cd yosys
   make -j$(nproc)
   sudo make install
   ```

### Optional Tools

2. **xdot** - For viewing synthesized netlists graphically
   ```bash
   sudo apt install xdot
   ```

3. **Graphviz** - For generating dot files
   ```bash
   sudo apt install graphviz
   ```

---

## Synthesis Scripts

### 1. synth_vericade.ys ✅

**Purpose:** Synthesize the complete Vericade system

**Includes:**
- All 4 game modules
- Input controller
- Matrix driver
- Game manager
- Top-level integration

**Usage:**
```bash
yosys synth_vericade.ys
```

**Outputs:**
- `vericade_top_synth.v` - Synthesized Verilog netlist
- `vericade_top.json` - JSON netlist (for place & route)
- `synthesis_stats.txt` - Resource utilization report

**Expected Runtime:** 5-15 seconds

---

### 2. synth_individual_games.ys ✅

**Purpose:** Synthesize each game module separately

**Generates:**
- `binary_adder_game_synth.v`
- `maze_game_synth.v`
- `tictactoe_game_synth.v`
- `connect4_game_synth.v`
- `individual_stats.txt` - Per-game statistics

**Usage:**
```bash
yosys synth_individual_games.ys
```

**Use Cases:**
- Compare resource usage across games
- Verify individual modules synthesize correctly
- Educational analysis of complexity progression

---

### 3. synth_fpga.ys ✅

**Purpose:** FPGA-specific synthesis for different targets

**Supported Targets:**
- `ice40` - Lattice iCE40 (HX/LP/UP series)
- `ecp5` - Lattice ECP5
- `xilinx` - Xilinx 7-series and Ultrascale
- `generic` - Generic FPGA (default)

**Usage:**
```bash
# iCE40 synthesis
FPGA_TARGET=ice40 yosys synth_fpga.ys

# ECP5 synthesis
FPGA_TARGET=ecp5 yosys synth_fpga.ys

# Xilinx synthesis
FPGA_TARGET=xilinx yosys synth_fpga.ys

# Generic synthesis
yosys synth_fpga.ys
```

**Outputs:**
- `vericade_fpga.json` - FPGA-specific netlist
- `vericade_fpga.v` - Synthesized Verilog
- `fpga_synthesis.txt` - Statistics

---

## Understanding Synthesis Results

### Reading Statistics

After synthesis, check `synthesis_stats.txt`:

```
=== vericade_top ===

   Number of wires:               2134
   Number of wire bits:           3821
   Number of public wires:          52
   Number of public wire bits:     245
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:               1847
     $_AND_                        421
     $_DFF_P_                      512
     $_MUX_                        284
     $_NAND_                        89
     $_NOR_                         67
     $_NOT_                        143
     $_OR_                         231
     $_XOR_                        100
```

### Key Metrics

| Metric | Description | Vericade Estimate |
|--------|-------------|-------------------|
| **Cells** | Total logic gates | ~1,800-2,000 |
| **DFF_P** | Flip-flops (registers) | ~500-600 |
| **Wires** | Internal connections | ~2,000-2,500 |
| **AND/OR/XOR** | Combinational gates | ~800-1,000 |
| **MUX** | Multiplexers | ~250-300 |

---

## Makefile Targets

### Synthesis Targets

```bash
make synth         # Synthesize complete system
make synth-games   # Synthesize individual games
make synth-all     # Synthesize everything
```

### Analysis Targets

```bash
make stats         # Show detailed statistics
make compare       # Compare game module sizes
make view          # Visualize netlist (requires xdot)
```

### Utility Targets

```bash
make clean         # Remove synthesis outputs
make help          # Show help message
```

---

## Example Workflows

### Workflow 1: Basic Synthesis

```bash
# 1. Synthesize the design
make synth

# 2. Check the output
cat synthesis_stats.txt

# 3. View the synthesized Verilog (optional)
less vericade_top_synth.v
```

**Expected Output:**
```
==========================================
Synthesizing Complete Vericade System
==========================================
[... synthesis messages ...]
✅ Synthesis complete!
Output files:
-rw-r--r-- 1 user user  45K vericade_top_synth.v
-rw-r--r-- 1 user user  89K vericade_top.json
-rw-r--r-- 1 user user 2.1K synthesis_stats.txt

📊 Quick Stats:
   Number of cells:               1847
```

---

### Workflow 2: Compare Game Complexities

```bash
# 1. Synthesize individual games
make synth-games

# 2. Compare resource usage
make compare
```

**Expected Output:**
```
Binary Adder:    Number of cells:  152
Maze Game:       Number of cells:  287
Tic-Tac-Toe:     Number of cells:  423
Connect Four:    Number of cells:  651
```

**Analysis:**
- Binary Adder (simplest) → ~150 cells
- Connect Four (most complex) → ~650 cells
- Shows 4.3x complexity increase from Game 1 to Game 4

---

### Workflow 3: FPGA-Specific Synthesis

```bash
# For Lattice iCE40 FPGA
FPGA_TARGET=ice40 yosys synth_fpga.ys

# Check results
cat fpga_synthesis.txt
```

---

### Workflow 4: Visualize Design

```bash
# Generate and view graphical netlist
make view
```

This opens an interactive graph showing:
- Module hierarchy
- Signal connections
- Cell types
- Data flow

---

## Synthesis Optimization

### Optimization Levels

The scripts use these optimization passes:

1. **synth** - Generic synthesis
2. **opt -full** - Full optimization (dead code removal, constant propagation)
3. **abc** - Advanced logic optimization
4. **clean** - Remove unused cells/wires

### Custom Optimization

To add more aggressive optimization, edit the `.ys` file:

```tcl
# Add after synth command:
opt -full
opt_clean -purge
opt_reduce
opt_merge
```

---

## Troubleshooting

### Issue: "Module not found"

**Symptom:**
```
ERROR: Module `binary_adder_game' not found!
```

**Solution:**
- Ensure all `.sv` files are in the same directory as the script
- Check file names match exactly (case-sensitive)
- Verify files are read in dependency order

---

### Issue: "Can't open file"

**Symptom:**
```
ERROR: Can't open input file `full_adder.sv'
```

**Solution:**
```bash
# Run from the directory containing .sv files
cd /Users/xxxtentacion/cognichip/
yosys synth_vericade.ys
```

---

### Issue: Synthesis takes too long

**Symptom:** Synthesis hangs or takes >30 seconds

**Solutions:**
1. Check for combinational loops
2. Reduce optimization level
3. Synthesize individual modules first to isolate issues

---

### Issue: Large synthesized netlist

**Symptom:** Output file >1MB

**Cause:** Unoptimized synthesis or incorrect hierarchy

**Solution:**
```bash
# Re-run with aggressive optimization
yosys -p "read_verilog *.sv; synth -top vericade_top; opt -full; clean; write_verilog output.v"
```

---

## Next Steps After Synthesis

### For FPGA Implementation

#### 1. Lattice iCE40
```bash
# After synthesis:
nextpnr-ice40 --hx8k --json vericade_fpga.json --pcf pins.pcf --asc vericade.asc
icepack vericade.asc vericade.bin
iceprog vericade.bin
```

#### 2. Lattice ECP5
```bash
# After synthesis:
nextpnr-ecp5 --25k --json vericade_fpga.json --lpf pins.lpf --textcfg vericade.config
ecppack vericade.config vericade.bit
openocd -f program.cfg
```

#### 3. Xilinx
```bash
# After synthesis, use Vivado:
vivado -mode batch -source vivado_pnr.tcl
```

### For ASIC Implementation

1. **Technology Mapping:**
   ```bash
   # Map to standard cell library
   yosys -p "read_liberty mycells.lib; read_verilog vericade_top_synth.v; dfflibmap -liberty mycells.lib; abc -liberty mycells.lib; write_verilog mapped.v"
   ```

2. **Timing Analysis:**
   - Use OpenSTA or commercial tools
   - Target: 50 MHz (20ns period)

3. **Place & Route:**
   - Use OpenROAD or commercial tools

---

## Expected Resource Usage

### Complete System

| Resource | Generic | iCE40 HX8K | ECP5-25K | Xilinx 7-series |
|----------|---------|------------|----------|-----------------|
| **LUTs** | ~1,800 | ~1,900 | ~1,750 | ~1,650 |
| **FFs** | ~500 | ~500 | ~500 | ~500 |
| **BRAM** | 0 | 0 | 0 | 0 |
| **DSP** | 0 | 0 | 0 | 0 |
| **Utilization** | N/A | ~24% | ~7% | ~3% |

### Individual Games

| Module | Cells | FFs | Relative |
|--------|-------|-----|----------|
| Binary Adder | ~150 | ~20 | 1x |
| Maze Game | ~280 | ~55 | 1.9x |
| Tic-Tac-Toe | ~420 | ~105 | 2.8x |
| Connect Four | ~650 | ~155 | 4.3x |

---

## Files Generated

### After `make synth`:
```
vericade_top_synth.v     # Synthesized Verilog
vericade_top.json        # JSON netlist
synthesis_stats.txt      # Statistics
synthesis.log            # Full synthesis log
```

### After `make synth-games`:
```
binary_adder_game_synth.v
maze_game_synth.v
tictactoe_game_synth.v
connect4_game_synth.v
individual_stats.txt
synthesis_games.log
```

### After `make view`:
```
vericade_top.dot         # Graphical netlist (Graphviz format)
```

---

## Advanced Usage

### Custom Synthesis Parameters

```bash
# High-effort optimization
yosys -p "read_verilog *.sv; synth -top vericade_top -flatten; opt -full; opt -full; clean; write_verilog output.v"

# Area-optimized
yosys -p "read_verilog *.sv; synth -top vericade_top -noabc; write_verilog output.v"

# Speed-optimized  
yosys -p "read_verilog *.sv; synth -top vericade_top; abc -g AND,OR -fast; write_verilog output.v"
```

### Extracting Specific Statistics

```bash
# Count flip-flops
grep "DFF_P" synthesis_stats.txt

# Count multiplexers
grep "MUX" synthesis_stats.txt

# Count total cells
grep "Number of cells:" synthesis_stats.txt
```

---

## Summary

### Quick Reference

| Task | Command |
|------|---------|
| Synthesize system | `make synth` |
| Synthesize games | `make synth-games` |
| View stats | `make stats` |
| Compare games | `make compare` |
| Visualize | `make view` |
| Clean up | `make clean` |
| Get help | `make help` |

### Success Criteria

✅ Synthesis completes without errors  
✅ Cell count: 1,800-2,000 cells  
✅ Flip-flop count: 500-600 FFs  
✅ No latches inferred  
✅ No combinational loops  
✅ Output files generated correctly

---

## Support

For issues or questions:
- Check synthesis.log for detailed error messages
- Verify all RTL files are lint-clean before synthesis
- Review synthesis_stats.txt for unexpected resource usage
- Try individual game synthesis to isolate problematic modules

---

*Synthesis guide for Vericade Educational Platform*  
*Compatible with Yosys open-source synthesis tool*
