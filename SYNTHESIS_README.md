# Synthesis Files for Vericade Platform

This directory contains everything needed to synthesize the Vericade educational FPGA platform using Yosys.

---

## 📁 Files Included

### Synthesis Scripts (.ys files)

| File | Purpose | Usage |
|------|---------|-------|
| `synth_vericade.ys` | Complete system synthesis | `yosys synth_vericade.ys` |
| `synth_individual_games.ys` | Individual game synthesis | `yosys synth_individual_games.ys` |
| `synth_fpga.ys` | FPGA-specific synthesis | `FPGA_TARGET=ice40 yosys synth_fpga.ys` |

### Build Automation

| File | Purpose |
|------|---------|
| `Makefile` | Convenient synthesis targets |
| `SYNTHESIS_GUIDE.md` | Complete synthesis documentation |
| `SYNTHESIS_README.md` | This file |

---

## 🚀 Quick Start

### Step 1: Run Synthesis

```bash
# Using Makefile (recommended)
make synth

# Or direct Yosys command
yosys synth_vericade.ys
```

### Step 2: Check Results

```bash
# View statistics
cat synthesis_stats.txt

# Or use Makefile
make stats
```

### Step 3: Analyze (Optional)

```bash
# Compare game complexities
make synth-games
make compare

# Visualize netlist
make view
```

---

## 📊 Expected Results

### Complete System Synthesis

```
✅ Synthesis complete!
Output files:
  - vericade_top_synth.v (Synthesized Verilog)
  - vericade_top.json (JSON netlist)
  - synthesis_stats.txt (Statistics)

📊 Quick Stats:
   Number of cells:               ~1,850
   Number of flip-flops:          ~500
   Number of multiplexers:        ~280
```

### Individual Game Synthesis

```
Binary Adder:    ~150 cells  (simplest)
Maze Game:       ~280 cells
Tic-Tac-Toe:     ~420 cells
Connect Four:    ~650 cells  (most complex)
```

---

## 🛠️ Makefile Targets

### Main Targets

```bash
make synth          # Synthesize complete system
make synth-games    # Synthesize individual games
make synth-all      # Synthesize everything
```

### Analysis Targets

```bash
make stats          # Show detailed statistics
make compare        # Compare game sizes
make view           # Visualize netlist (requires xdot)
```

### Utility Targets

```bash
make clean          # Remove synthesis outputs
make help           # Show all available targets
```

---

## 📖 Documentation

**Read SYNTHESIS_GUIDE.md for:**
- Detailed synthesis instructions
- Troubleshooting guide
- FPGA-specific synthesis
- Advanced optimization techniques
- Next steps for FPGA implementation

---

## ✅ Prerequisites

**Required:**
- Yosys (synthesis tool)

**Optional:**
- xdot (netlist visualization)
- nextpnr (FPGA place & route)
- icestorm/trellis/vivado (FPGA bitstream generation)

### Install Yosys

```bash
# Ubuntu/Debian
sudo apt install yosys

# macOS
brew install yosys

# From source
git clone https://github.com/YosysHQ/yosys.git
cd yosys && make -j$(nproc) && sudo make install
```

---

## 🎯 Synthesis Outputs

### Generated Files

After running `make synth`:

```
vericade_top_synth.v     ← Synthesized Verilog netlist
vericade_top.json        ← JSON netlist (for P&R)
synthesis_stats.txt      ← Resource utilization
synthesis.log            ← Full synthesis log
```

After running `make synth-games`:

```
binary_adder_game_synth.v
maze_game_synth.v
tictactoe_game_synth.v
connect4_game_synth.v
individual_stats.txt
synthesis_games.log
```

---

## 🔍 Verification

### Check Synthesis Success

```bash
# Should show no errors
grep -i "error" synthesis.log

# Should show reasonable cell count
grep "Number of cells:" synthesis_stats.txt

# Should have all output files
ls -lh vericade_top_synth.v vericade_top.json synthesis_stats.txt
```

### Expected Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Cells | 1,800-2,000 | ✅ Good |
| Flip-Flops | 500-600 | ✅ Good |
| Latches | 0 | ✅ Required |
| Errors | 0 | ✅ Required |
| Warnings | <10 | ✅ Acceptable |

---

## 🎮 What Gets Synthesized

### Complete System (`synth_vericade.ys`)

- ✅ Full Adder (building block)
- ✅ Input Controller (debouncing)
- ✅ Matrix Driver (8×8 LED)
- ✅ Binary Adder Game
- ✅ LED Maze Game
- ✅ Tic-Tac-Toe Game
- ✅ Connect Four Game
- ✅ Game Manager (multiplexer)
- ✅ Vericade Top (integration)

### Individual Games (`synth_individual_games.ys`)

Each game synthesized separately for comparison:
- Binary Adder only
- Maze Game only
- Tic-Tac-Toe only
- Connect Four only

---

## 🚦 Next Steps

### After Successful Synthesis

1. **Review Statistics**
   ```bash
   make stats
   ```

2. **Compare Game Complexities**
   ```bash
   make compare
   ```

3. **Visualize Design** (optional)
   ```bash
   make view
   ```

4. **FPGA Implementation**
   - For iCE40: Use nextpnr-ice40
   - For ECP5: Use nextpnr-ecp5  
   - For Xilinx: Use Vivado
   - See SYNTHESIS_GUIDE.md for details

---

## 🐛 Troubleshooting

### Common Issues

**Issue:** "yosys: command not found"
```bash
# Install Yosys first
sudo apt install yosys
```

**Issue:** "Module not found"
```bash
# Ensure you're in the correct directory
cd /Users/xxxtentacion/cognichip/
make synth
```

**Issue:** Synthesis errors
```bash
# Check synthesis log
cat synthesis.log | grep -i error

# Verify RTL is lint-clean
make clean
make synth
```

---

## 📈 Resource Estimates

### By FPGA Platform

| FPGA | Family | LUTs | FFs | Util | Fits? |
|------|--------|------|-----|------|-------|
| iCE40-HX8K | Lattice | ~1,900 | ~500 | 24% | ✅ Yes |
| iCE40-UP5K | Lattice | ~1,900 | ~500 | 36% | ✅ Yes |
| ECP5-25K | Lattice | ~1,750 | ~500 | 7% | ✅ Yes |
| Artix-7 35T | Xilinx | ~1,650 | ~500 | 3% | ✅ Yes |
| Cyclone IV | Intel | ~1,800 | ~500 | 8% | ✅ Yes |

**Conclusion:** Design fits comfortably on most FPGAs!

---

## 💡 Tips

### Faster Synthesis

```bash
# Skip individual game synthesis if only need full system
make synth

# Clean before re-synthesizing
make clean && make synth
```

### Better Analysis

```bash
# Synthesize everything for complete analysis
make synth-all

# Then compare results
make stats
make compare
```

### Save Results

```bash
# Save synthesis outputs
mkdir -p results
cp synthesis_stats.txt individual_stats.txt results/
cp *.json results/
```

---

## 📚 Additional Resources

- **SYNTHESIS_GUIDE.md** - Comprehensive synthesis documentation
- **README_VERICADE.md** - Complete platform overview
- **DEPS.yml** - Dependency configuration
- **Yosys Manual** - http://yosyshq.net/yosys/

---

## ✅ Success Checklist

Before proceeding to FPGA implementation:

- [ ] Synthesis completes without errors
- [ ] synthesis_stats.txt shows reasonable resource usage
- [ ] No latches inferred (check for DFF_P only, no DFF_N or latches)
- [ ] All output files generated
- [ ] Visualized netlist looks correct (optional)
- [ ] Individual games synthesize successfully (optional)

---

## 🎓 Educational Value

This synthesis flow demonstrates:
- ✅ RTL-to-gates transformation
- ✅ Resource optimization
- ✅ Technology mapping
- ✅ Design complexity analysis
- ✅ Hierarchical synthesis
- ✅ FPGA targeting

---

**Ready to synthesize? Run `make synth` to get started!**

*Synthesis infrastructure for Vericade Educational Platform*
