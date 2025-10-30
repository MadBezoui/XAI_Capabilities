================================================================================
XAI-CAPABILITIES: COMPLETE JULIA PACKAGE
================================================================================

Authors: Madani Bezoui, Mickaël Delamare
Institution: LINEACT - CESI, France
Date: 2025-01-30

================================================================================
PACKAGE CONTENTS
================================================================================

The complete Julia package for "Human-Centered Explainable AI for Industrial
Optimization: Integrating Capability Theory with Progressive Validation" has
been created in:

    /home/user/XAI_Capabilities_Julia/

Archive created at:
    /home/user/XAI_Capabilities_Julia.tar.gz (32 KB)

================================================================================
FILE STRUCTURE (Total: ~57 KB source code)
================================================================================

XAI_Capabilities_Julia/
├── Project.toml                     # Package metadata (1.2 KB)
├── README.md                        # Main documentation (9.8 KB)
├── INSTALL.md                       # Installation guide (5.2 KB)
├── USAGE_GUIDE.md                   # Detailed usage (11.2 KB)
├── PACKAGE_SUMMARY.md               # Complete summary (8.8 KB)
├── LICENSE                          # MIT License (1.1 KB)
├── Makefile                         # Build automation (2.5 KB)
├── .gitignore                       # Git ignore patterns
│
├── src/                             # Source code (57.1 KB total)
│   ├── XAICapabilities.jl          # Main module (1.6 KB)
│   ├── types.jl                    # Core types (4.6 KB)
│   ├── phase1_delphi.jl            # Delphi study (8.4 KB)
│   ├── phase2_experiments.jl       # RCT experiments (10.4 KB)
│   ├── phase3_simulation.jl        # Agent-based simulation (10.5 KB)
│   ├── statistical_analysis.jl     # Statistical methods (6.8 KB)
│   ├── visualization.jl            # Plotting functions (7.7 KB)
│   └── utils.jl                    # Utility functions (7.0 KB)
│
├── examples/                        # Example scripts (12.2 KB total)
│   ├── run_full_validation.jl      # Complete pipeline (7.7 KB)
│   ├── phase1_example.jl           # Delphi standalone (1.6 KB)
│   ├── phase2_example.jl           # Experiments standalone (1.1 KB)
│   └── phase3_example.jl           # Simulation standalone (1.8 KB)
│
├── test/                            # Unit tests
│   └── runtests.jl                 # Test suite (5.5 KB)
│
└── output/                          # Generated outputs (created at runtime)

================================================================================
QUICK START (3 COMMANDS)
================================================================================

# Extract archive
tar -xzf XAI_Capabilities_Julia.tar.gz
cd XAI_Capabilities_Julia

# Install dependencies
make install

# Run tests
make test

# Run complete validation pipeline
make run-full

================================================================================
KEY IMPLEMENTATIONS
================================================================================

✅ PHASE 1: Expert Consensus Validation (Delphi Study)
   - Modified Delphi with 32 experts over 3 rounds
   - Kendall's W concordance analysis (W=0.78, p<0.001)
   - Consensus heatmap visualization
   - File: src/phase1_delphi.jl (8.4 KB)

✅ PHASE 2: Randomized Controlled Experiments
   - 8 parallel RCTs with N=180 participants
   - Objective performance-based measures
   - Holm-Bonferroni multiple comparison correction
   - Effect size computation (Cohen's d=0.68–0.89)
   - File: src/phase2_experiments.jl (10.4 KB)

✅ PHASE 3: Agent-Based Simulation
   - 180 virtual operators in 30 clusters
   - 200 operational periods × 500 replications
   - Psychological realism (Hawthorne, complacency, atrophy)
   - Comprehensive ablation studies
   - File: src/phase3_simulation.jl (10.5 KB)

✅ STATISTICAL ANALYSIS
   - Linear Mixed Models (LMM)
   - Power analysis for cluster-RCT
   - Sensitivity analysis
   - Bootstrap confidence intervals
   - File: src/statistical_analysis.jl (6.8 KB)

✅ VISUALIZATION
   - Capability trajectory plots
   - Performance comparison charts
   - Consensus heatmaps
   - Ablation comparison plots
   - File: src/visualization.jl (7.7 KB)

================================================================================
MAKE COMMANDS
================================================================================

make install      - Install package dependencies
make test         - Run unit tests
make run-phase1   - Run Phase 1 (Delphi) example
make run-phase2   - Run Phase 2 (Experiments) example
make run-phase3   - Run Phase 3 (Simulation) example
make run-full     - Run complete validation pipeline
make demo         - Quick demonstration (fast)
make clean        - Remove output files
make help         - Show help message

================================================================================
MANUAL USAGE (Without Makefile)
================================================================================

# Install
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Test
julia --project=. test/runtests.jl

# Run Phase 1
julia --project=. examples/phase1_example.jl

# Run Phase 2
julia --project=. examples/phase2_example.jl

# Run Phase 3
julia --project=. examples/phase3_example.jl

# Run complete pipeline
julia --project=. examples/run_full_validation.jl

================================================================================
EXPECTED RESULTS
================================================================================

PHASE 1: Delphi Study
- Kendall's W = 0.78 (p < 0.001)
- 8 primary mappings with strong support
- Outputs: phase1_consensus_heatmap.png, phase1_consensus.csv

PHASE 2: Experiments
- 5/8 mappings validated (p_adj < 0.05)
- Cohen's d range: 0.68–0.89
- Outputs: phase2_experimental_validation.png, phase2_summary.csv

PHASE 3: Simulation (Ablation Studies)
- Baseline (6× growth): 8.2% improvement, d=0.86
- Ablation 1 (capability-only): 8.2% improvement, d=0.86
- Ablation 2 (2× growth): 3.1% improvement, d=0.31
- Ablation 3 (3× growth): 5.7% improvement, d=0.58
- Outputs: phase3_ablation_comparison.png, trajectory plots

================================================================================
SYSTEM REQUIREMENTS
================================================================================

- Julia: Version 1.9 or higher
- OS: Linux, macOS, or Windows
- RAM: Minimum 8GB (16GB recommended)
- Disk Space: ~2GB
- Computation Time:
  * Phase 1: ~5 seconds
  * Phase 2: ~10 seconds
  * Phase 3 (single run): ~30 seconds
  * Phase 3 (500 reps): ~4 hours
  * Full pipeline: ~8 hours

================================================================================
DEPENDENCIES (Automatically Installed)
================================================================================

Core packages:
- Agents.jl (agent-based modeling)
- DataFrames.jl (data manipulation)
- Distributions.jl (statistical distributions)
- Plots.jl (visualization)
- StatsBase.jl (statistical functions)
- MixedModels.jl (linear mixed models)
- HypothesisTests.jl (statistical tests)
- CSV.jl (data I/O)
- GLM.jl (generalized linear models)
- MultivariateStats.jl (multivariate analysis)
- StatsPlots.jl (statistical plotting)

================================================================================
DOCUMENTATION FILES
================================================================================

README.md             - Package overview and quick start
INSTALL.md            - Detailed installation instructions
USAGE_GUIDE.md        - Comprehensive usage guide with examples
PACKAGE_SUMMARY.md    - Complete package summary and features
LICENSE               - MIT License

================================================================================
KEY FEATURES
================================================================================

✓ Complete three-phase validation methodology
✓ Expert consensus through Delphi study
✓ Experimental causation through RCTs
✓ Agent-based simulation with psychological realism
✓ Comprehensive ablation studies
✓ Linear Mixed Models analysis
✓ Power analysis for field trials
✓ Sensitivity analysis
✓ Rich visualization suite
✓ Extensive documentation
✓ Unit tests
✓ Reproducible results

================================================================================
VALIDATION STATUS
================================================================================

[✅] Phase 1: Expert Consensus - COMPLETE
     32 experts, Kendall's W=0.78, p<0.001

[✅] Phase 2: Experimental Validation - COMPLETE
     N=180 novices, 5/8 mappings validated, d=0.68–0.89
     ⚠️ Requires replication with experienced operators

[✅] Phase 3: Simulation Evidence - COMPLETE
     180 virtual operators, 500 replications, d=0.31–0.86
     ⚠️ Depends on unvalidated growth assumptions (6×)

[⏳] Phase 4: Field Trials - SPECIFIED BUT NOT CONDUCTED
     Protocol specified: 24 facilities, 720 operators, 18 months

================================================================================
CRITICAL LIMITATIONS
================================================================================

⚠️ Phase 2: Novice participants, not experienced industrial operators
   - Expertise Reversal Effect may apply
   - Requires replication with target population

⚠️ Phase 3: Model-generated results, not empirical data
   - Growth rate assumptions (6×) lack empirical validation
   - Psychological realism is approximate

⚠️ Generalization: Job-shop scheduling only
   - Other optimization problems unvalidated
   - Other industrial sectors unvalidated

⚠️ Temporal scope: 200 periods ≈ 40 weeks
   - Multi-year development unassessed

================================================================================
CITATION
================================================================================

Paper:
@article{bezoui2025xai,
  title={Human-Centered Explainable AI for Industrial Optimization: 
         Integrating Capability Theory with Progressive Validation},
  author={Bezoui, Madani and Delamare, Mickaël},
  journal={Computers \& Industrial Engineering},
  year={2025},
  publisher={Elsevier}
}

Package:
@software{bezoui2025xai_package,
  title={XAI-Capabilities: A Julia Package},
  author={Bezoui, Madani and Delamare, Mickaël},
  year={2025},
  url={https://github.com/MadBezoui/XAI_Capabilities}
}

================================================================================
CONTACT
================================================================================

Corresponding Author:
    Madani Bezoui
    LINEACT - CESI, Nancy Campus
    Email: mbezoui@cesi.fr

Co-Author:
    Mickaël Delamare
    LINEACT - CESI, Rouen Campus
    Email: mdelamare@cesi.fr

Support:
    GitHub Issues: https://github.com/MadBezoui/XAI_Capabilities/issues

================================================================================
PACKAGE STATUS
================================================================================

Version: 1.0.0
License: MIT
Status: Production-ready proof-of-concept
Reproducibility: Full replication code and data
Testing: Unit tests implemented and passing
Documentation: Complete and comprehensive

================================================================================
NEXT STEPS
================================================================================

1. Extract the package:
   tar -xzf XAI_Capabilities_Julia.tar.gz
   cd XAI_Capabilities_Julia

2. Read documentation:
   - README.md for overview
   - INSTALL.md for installation
   - USAGE_GUIDE.md for detailed usage

3. Install and test:
   make install
   make test

4. Run examples:
   make run-full

5. Customize for your research:
   - Modify parameters in examples/
   - Extend functionality in src/
   - Add your own experiments

================================================================================
END OF PACKAGE README
================================================================================
