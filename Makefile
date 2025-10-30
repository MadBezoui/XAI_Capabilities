# Makefile for XAI-Capabilities Julia Package

.PHONY: all install test run-phase1 run-phase2 run-phase3 run-full clean docs

all: install test

# Install dependencies
install:
	@echo "Installing XAI-Capabilities package..."
	julia --project=. -e 'using Pkg; Pkg.instantiate()'
	@echo "✓ Installation complete"

# Run tests
test:
	@echo "Running unit tests..."
	julia --project=. test/runtests.jl
	@echo "✓ Tests complete"

# Run Phase 1 example
run-phase1:
	@echo "Running Phase 1: Delphi Study..."
	mkdir -p output
	julia --project=. examples/phase1_example.jl
	@echo "✓ Phase 1 complete"

# Run Phase 2 example
run-phase2:
	@echo "Running Phase 2: RCT Experiments..."
	mkdir -p output
	julia --project=. examples/phase2_example.jl
	@echo "✓ Phase 2 complete"

# Run Phase 3 example
run-phase3:
	@echo "Running Phase 3: Simulation..."
	mkdir -p output
	julia --project=. examples/phase3_example.jl
	@echo "✓ Phase 3 complete"

# Run full validation pipeline
run-full:
	@echo "Running complete validation pipeline..."
	mkdir -p output
	julia --project=. examples/run_full_validation.jl
	@echo "✓ Full validation complete"

# Clean output files
clean:
	@echo "Cleaning output files..."
	rm -rf output/*.png output/*.csv output/*.txt
	@echo "✓ Clean complete"

# Generate documentation
docs:
	@echo "Generating documentation..."
	julia --project=. -e 'using Documenter; include("docs/make.jl")'
	@echo "✓ Documentation generated"

# Quick demo (fast version for testing)
demo:
	@echo "Running quick demonstration..."
	mkdir -p output
	julia --project=. -e 'using XAICapabilities; \
		rounds, cons, W, meta = run_full_delphi_study(n_experts=16, n_rounds=2); \
		results, data, summary = run_all_experiments(n_per_group=10); \
		params = SimulationParameters(n_periods=50); \
		model = initialize_simulation_model(params); \
		perf, cap = run_simulation!(model, 50); \
		println("✓ Demo complete")'

# Help
help:
	@echo "XAI-Capabilities Makefile Commands:"
	@echo ""
	@echo "  make install      - Install package dependencies"
	@echo "  make test         - Run unit tests"
	@echo "  make run-phase1   - Run Phase 1 example (Delphi)"
	@echo "  make run-phase2   - Run Phase 2 example (Experiments)"
	@echo "  make run-phase3   - Run Phase 3 example (Simulation)"
	@echo "  make run-full     - Run complete validation pipeline"
	@echo "  make demo         - Quick demonstration (fast)"
	@echo "  make clean        - Remove output files"
	@echo "  make docs         - Generate documentation"
	@echo "  make help         - Show this help message"
