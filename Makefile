# =============================================================================
# Vericade Platform - Synthesis Makefile
# =============================================================================
# Provides convenient targets for synthesizing the Verilog design with Yosys.
#
# Targets:
#   make synth         - Synthesize complete system
#   make synth-games   - Synthesize individual games
#   make synth-all     - Synthesize everything
#   make clean         - Remove synthesis outputs
#   make view          - View synthesized netlist (requires xdot)
#
# Requirements:
#   - yosys (synthesis)
#   - xdot (optional, for visualization)
# =============================================================================

# Tools
YOSYS = yosys
XDOT = xdot

# Output directories
SYNTH_DIR = synthesis_output
BUILD_DIR = build

# Synthesis scripts
SCRIPT_FULL = synth_vericade.ys
SCRIPT_GAMES = synth_individual_games.ys

# Target names
TOP_MODULE = vericade_top
GAMES = binary_adder_game maze_game tictactoe_game connect4_game

# =============================================================================
# Main Targets
# =============================================================================

.PHONY: all synth synth-games synth-all clean view help

# Default target
all: synth

# Synthesize complete system
synth:
	@echo "=========================================="
	@echo "Synthesizing Complete Vericade System"
	@echo "=========================================="
	@$(YOSYS) $(SCRIPT_FULL) | tee synthesis.log
	@echo ""
	@echo "✅ Synthesis complete!"
	@echo "Output files:"
	@ls -lh vericade_top_synth.v vericade_top.json synthesis_stats.txt 2>/dev/null || true
	@echo ""
	@echo "📊 Quick Stats:"
	@if [ -f synthesis_stats.txt ]; then grep "Number of cells:" synthesis_stats.txt || true; fi

# Synthesize individual games
synth-games:
	@echo "=========================================="
	@echo "Synthesizing Individual Game Modules"
	@echo "=========================================="
	@$(YOSYS) $(SCRIPT_GAMES) | tee synthesis_games.log
	@echo ""
	@echo "✅ Individual games synthesized!"
	@echo "Output files:"
	@ls -lh *_game_synth.v 2>/dev/null || true

# Synthesize everything
synth-all: synth synth-games
	@echo ""
	@echo "✅ All synthesis complete!"

# =============================================================================
# Visualization Targets
# =============================================================================

# View the synthesized netlist graphically
view: vericade_top.json
	@echo "Generating graphical view of synthesized design..."
	@$(YOSYS) -p "read_json vericade_top.json; show -format dot -prefix vericade_top"
	@if command -v $(XDOT) >/dev/null 2>&1; then \
		$(XDOT) vericade_top.dot & \
		echo "✅ Opened in xdot"; \
	else \
		echo "⚠️  xdot not found. Install with: sudo apt install xdot"; \
		echo "Graphical file saved as: vericade_top.dot"; \
	fi

# =============================================================================
# Analysis Targets
# =============================================================================

# Show detailed statistics
stats: synthesis_stats.txt
	@echo "=========================================="
	@echo "Synthesis Statistics"
	@echo "=========================================="
	@cat synthesis_stats.txt

# Compare game sizes
compare: individual_stats.txt
	@echo "=========================================="
	@echo "Game Module Comparison"
	@echo "=========================================="
	@echo "Extracting cell counts..."
	@grep -A 20 "binary_adder_game" individual_stats.txt | grep "Number of cells:" || echo "Binary Adder: (run synth-games first)"
	@grep -A 20 "maze_game" individual_stats.txt | grep "Number of cells:" || echo "Maze Game: (run synth-games first)"
	@grep -A 20 "tictactoe_game" individual_stats.txt | grep "Number of cells:" || echo "Tic-Tac-Toe: (run synth-games first)"
	@grep -A 20 "connect4_game" individual_stats.txt | grep "Number of cells:" || echo "Connect Four: (run synth-games first)"

# =============================================================================
# Utility Targets
# =============================================================================

# Clean synthesis outputs
clean:
	@echo "Cleaning synthesis outputs..."
	@rm -f *.json
	@rm -f *_synth.v
	@rm -f synthesis_stats.txt
	@rm -f individual_stats.txt
	@rm -f synthesis.log
	@rm -f synthesis_games.log
	@rm -f *.dot
	@echo "✅ Clean complete"

# Show help
help:
	@echo "Vericade Synthesis Makefile"
	@echo "============================"
	@echo ""
	@echo "Targets:"
	@echo "  make synth         - Synthesize complete Vericade system"
	@echo "  make synth-games   - Synthesize individual game modules"
	@echo "  make synth-all     - Synthesize everything"
	@echo "  make view          - View synthesized netlist graphically"
	@echo "  make stats         - Show detailed synthesis statistics"
	@echo "  make compare       - Compare sizes of game modules"
	@echo "  make clean         - Remove all synthesis outputs"
	@echo "  make help          - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - yosys (synthesis tool)"
	@echo "  - xdot (optional, for visualization)"
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make synth          # Synthesize the design"
	@echo "  2. make stats          # View statistics"
	@echo "  3. make view           # Visualize (optional)"

# =============================================================================
# Dependencies
# =============================================================================

vericade_top.json: $(SCRIPT_FULL) *.sv
	@$(MAKE) synth

synthesis_stats.txt: vericade_top.json

individual_stats.txt: $(SCRIPT_GAMES) *.sv
	@$(MAKE) synth-games
