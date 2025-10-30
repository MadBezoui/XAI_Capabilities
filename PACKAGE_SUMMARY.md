# XAI-Capabilities Julia Package: Complete Summary

## 📦 Package Overview

**Full Package for Capability-Aware Explainable AI in Industrial Optimization**

This comprehensive Julia implementation reproduces the complete three-phase validation methodology from:

> Bezoui, M., & Delamare, M. (2025). Human-Centered Explainable AI for Industrial Optimization: Integrating Capability Theory with Progressive Validation. *Computers & Industrial Engineering*.

## 📁 Complete File Structure

```
XAI_Capabilities_Julia/
├── Project.toml                     # Package metadata and dependencies
├── Manifest.toml                    # Locked dependency versions (generated)
├── README.md                        # Main documentation
├── INSTALL.md                       # Installation instructions
├── USAGE_GUIDE.md                   # Detailed usage guide
├── LICENSE                          # MIT License
├── Makefile                         # Build automation
├── .gitignore                       # Git ignore patterns
│
├── src/                             # Source code
│   ├── XAICapabilities.jl          # Main module (1.6 KB)
│   ├── types.jl                    # Type definitions (4.6 KB)
│   ├── phase1_delphi.jl            # Delphi study (8.4 KB)
│   ├── phase2_experiments.jl       # RCT experiments (10.4 KB)
│   ├── phase3_simulation.jl        # Agent-based simulation (10.5 KB)
│   ├── statistical_analysis.jl     # Statistical methods (6.8 KB)
│   ├── visualization.jl            # Plotting functions (7.7 KB)
│   └── utils.jl                    # Utility functions (7.0 KB)
│
├── examples/                        # Example scripts
│   ├── run_full_validation.jl      # Complete pipeline (7.7 KB)
│   ├── phase1_example.jl           # Delphi standalone (1.6 KB)
│   ├── phase2_example.jl           # Experiments standalone (1.1 KB)
│   └── phase3_example.jl           # Simulation standalone (1.8 KB)
│
├── test/                            # Unit tests
│   └── runtests.jl                 # Test suite (5.5 KB)
│
├── output/                          # Generated outputs (created at runtime)
│   ├── *.png                       # Figures
│   ├── *.csv                       # Data tables
│   └── *.txt                       # Reports
│
└── docs/                            # Documentation (optional)
    └── methodology.md              # Detailed methodology

**Total: ~57 KB of source code**
```

## 🎯 Key Features

### Phase 1: Expert Consensus Validation
- ✅ Modified Delphi study with 32 experts
- ✅ 3 rounds with controlled feedback
- ✅ Kendall's W concordance analysis
- ✅ Consensus heatmap visualization

### Phase 2: Randomized Controlled Experiments
- ✅ 8 parallel RCTs (N=180 total)
- ✅ Objective performance-based measures
- ✅ Holm-Bonferroni multiple comparison correction
- ✅ Effect size computation (Cohen's d)

### Phase 3: Agent-Based Simulation
- ✅ 180 virtual operators in 30 clusters
- ✅ 200 periods × 500 replications
- ✅ Psychological realism (Hawthorne, complacency, atrophy)
- ✅ Comprehensive ablation studies

### Statistical Analysis
- ✅ Linear Mixed Models (LMM)
- ✅ Power analysis for cluster-RCT
- ✅ Sensitivity analysis
- ✅ Bootstrap confidence intervals

### Visualization
- ✅ Capability trajectory plots
- ✅ Performance comparison charts
- ✅ Consensus heatmaps
- ✅ Ablation comparison plots

## 🚀 Quick Start (3 commands)

```bash
# 1. Install
make install

# 2. Test
make test

# 3. Run
make run-full
```

## 📊 Expected Results

### Phase 1: Delphi Study
- Final Kendall's W = 0.78 (p < 0.001)
- 8 primary mappings with strong support
- Output: `phase1_consensus_heatmap.png`, `phase1_consensus.csv`

### Phase 2: Experiments
- 5/8 mappings validated (p_adj < 0.05)
- Cohen's d range: 0.68–0.89
- Output: `phase2_experimental_validation.png`, `phase2_summary.csv`

### Phase 3: Simulation
- **Baseline (6× growth)**: 8.2% improvement, d=0.86
- **Ablation 1 (capability-only)**: 8.2% improvement, d=0.86
- **Ablation 2 (2× growth)**: 3.1% improvement, d=0.31
- **Ablation 3 (3× growth)**: 5.7% improvement, d=0.58
- Output: `phase3_ablation_comparison.png`, multiple trajectory plots

## 🔧 Customization Points

### 1. Adjust Sample Sizes

```julia
# Phase 2: Larger sample for more power
results, data, summary = run_all_experiments(n_per_group=30)

# Phase 3: More replications for precision
params = SimulationParameters(n_replications=1000)
```

### 2. Modify Growth Assumptions

```julia
# Conservative scenario
params = SimulationParameters(
    growth_rate_control=0.0005,
    growth_rate_xai_cap=0.0010  # 2× instead of 6×
)

# Optimistic scenario
params = SimulationParameters(
    growth_rate_xai_cap=0.0050  # 10×
)
```

### 3. Adjust Capability Coupling

```julia
# Weaker coupling
params = SimulationParameters(capability_coupling=0.20)

# Stronger coupling
params = SimulationParameters(capability_coupling=0.50)
```

### 4. Custom Psychological Factors

```julia
params = SimulationParameters(
    hawthorne_base=0.10,
    demand_char_boost=0.15,
    complacency_rate=0.002,
    atrophy_rate=0.0005
)
```

## 📈 Performance Notes

### Computational Requirements

- **Phase 1 (Delphi)**: ~5 seconds
- **Phase 2 (Experiments)**: ~10 seconds
- **Phase 3 (Single run)**: ~30 seconds
- **Phase 3 (500 replications)**: ~4 hours
- **Full pipeline (with ablations)**: ~8 hours

### Optimization Tips

```julia
# Use multi-threading
ENV["JULIA_NUM_THREADS"] = "8"

# Reduce replications for testing
params = SimulationParameters(n_replications=50)

# Shorter simulation periods
params = SimulationParameters(n_periods=100)
```

## 🔬 Validation Status

| Phase | Status | Sample | Key Metric |
|-------|--------|--------|------------|
| Phase 1 | ✅ Complete | 32 experts | W=0.78*** |
| Phase 2 | ✅ Complete | N=180 novices | 5/8 validated |
| Phase 3 | ✅ Complete | 180 virtual | d=0.31–0.86 |
| Phase 4 | ⏳ Specified | 720 operators | MDE=0.37 |

**⚠ Critical Limitations:**
- Phase 2: Novice participants (not experienced operators)
- Phase 3: Model-generated (not empirical data)
- Growth assumptions (6×) unvalidated
- Phase 4 field trials not yet conducted

## 📚 Dependencies

Core packages (automatically installed):
- `Agents.jl` - Agent-based modeling
- `DataFrames.jl` - Data manipulation
- `Distributions.jl` - Statistical distributions
- `Plots.jl` - Visualization
- `StatsBase.jl` - Statistical functions
- `MixedModels.jl` - Linear mixed models
- `HypothesisTests.jl` - Statistical tests
- `CSV.jl` - Data I/O
- `GLM.jl` - Generalized linear models
- `MultivariateStats.jl` - Multivariate analysis
- `StatsPlots.jl` - Statistical plotting

## 🐛 Known Issues

1. **Memory usage**: Large simulations (500 reps) require ~8GB RAM
2. **Plot backend**: GR backend may require manual installation on some systems
3. **Long computation**: Full ablation studies take several hours

## 🔄 Version History

- **v1.0.0** (2025): Initial release
  - Complete three-phase implementation
  - Comprehensive ablation studies
  - Full documentation and examples

## 📞 Support

- **Documentation**: See README.md, INSTALL.md, USAGE_GUIDE.md
- **Issues**: GitHub Issues (https://github.com/MadBezoui/XAI_Capabilities/issues)
- **Email**: mbezoui@cesi.fr
- **Institution**: LINEACT - CESI, France

## 📖 Citation

```bibtex
@article{bezoui2025xai,
  title={Human-Centered Explainable AI for Industrial Optimization: 
         Integrating Capability Theory with Progressive Validation},
  author={Bezoui, Madani and Delamare, Mickaël},
  journal={Computers \& Industrial Engineering},
  year={2025},
  publisher={Elsevier}
}

@software{bezoui2025xai_package,
  title={XAI-Capabilities: A Julia Package},
  author={Bezoui, Madani and Delamare, Mickaël},
  year={2025},
  url={https://github.com/MadBezoui/XAI_Capabilities}
}
```

## ✅ Reproducibility Checklist

- [x] All source code provided
- [x] Dependencies specified (Project.toml)
- [x] Random seeds documented
- [x] Example scripts included
- [x] Unit tests implemented
- [x] Documentation complete
- [x] Installation verified
- [x] Results reproducible

## 🎓 Educational Use

This package is suitable for:
- Graduate-level courses in AI, operations research, human factors
- Research methods training (Delphi, RCT, simulation, statistics)
- Industrial optimization case studies
- Capability theory applications

## 🔮 Future Directions

1. **Phase 4 Field Trials**: Definitive validation with industrial operators
2. **Extended Domains**: Other optimization problems beyond job-shop scheduling
3. **Real-Time XAI**: Integration with live production systems
4. **Multi-Language**: Python/R bindings for broader accessibility
5. **GUI Interface**: User-friendly configuration and visualization

---

**Package Status**: Production-ready proof-of-concept  
**License**: MIT  
**Maintainers**: Madani Bezoui, Mickaël Delamare  
**Last Updated**: 2025-01-30
