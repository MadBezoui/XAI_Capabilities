# XAI-Capabilities: A Julia Package for Capability-Aware Explainable AI

**Authors:** Madani Bezoui, Mickaël Delamare  
**Institution:** LINEACT - CESI, France  
**Version:** 1.0.0

## Overview

This package implements the three-phase validation methodology for integrating professional capability development with explainable AI in industrial optimization, as described in:

> Bezoui, M., & Delamare, M. (2025). Human-Centered Explainable AI for Industrial Optimization: Integrating Capability Theory with Progressive Validation. *Computers & Industrial Engineering*.

## Key Features

- **Phase 1: Expert Consensus Validation** - Modified Delphi study with 32 experts
- **Phase 2: Randomized Controlled Experiments** - 8 parallel RCTs with objective measures
- **Phase 3: Agent-Based Simulation** - 180 virtual operators with psychological realism
- **Comprehensive Ablation Studies** - Isolate capability-mediated mechanisms
- **Statistical Analysis** - Linear Mixed Models, power analysis, sensitivity analysis
- **Rich Visualizations** - Trajectory plots, heatmaps, comparison charts

## Installation

```julia
using Pkg
Pkg.activate("/path/to/XAI_Capabilities_Julia")
Pkg.instantiate()
```

Or install directly:

```julia
using Pkg
Pkg.add(url="https://github.com/MadBezoui/XAI_Capabilities")
```

## Quick Start

```julia
using XAICapabilities

# Phase 1: Run Delphi study
rounds, consensus, W_prog, metadata = run_full_delphi_study(n_experts=32)

# Phase 2: Run experiments
results, data, summary = run_all_experiments(n_per_group=22)

# Phase 3: Run simulation with ablation
params = SimulationParameters()
ablation_results = run_ablation_studies(params; n_replications=100)

# Generate report
generate_summary_report((rounds, consensus, W_prog, metadata),
                       (results, data, summary),
                       ablation_results)
```

## Reproducing Paper Results

To reproduce all results from the paper:

```bash
cd examples/
julia run_full_validation.jl
```

This will:
1. Execute all three validation phases
2. Generate all figures and tables
3. Export results to `output/` directory
4. Create comprehensive validation report

## Package Structure

```
XAI_Capabilities_Julia/
├── Project.toml                 # Package dependencies
├── README.md                    # This file
├── src/
│   ├── XAICapabilities.jl      # Main module
│   ├── types.jl                # Core type definitions
│   ├── phase1_delphi.jl        # Delphi study implementation
│   ├── phase2_experiments.jl   # RCT experiments
│   ├── phase3_simulation.jl    # Agent-based simulation
│   ├── statistical_analysis.jl # Statistical methods
│   ├── visualization.jl        # Plotting functions
│   └── utils.jl                # Utility functions
├── examples/
│   ├── run_full_validation.jl  # Complete validation pipeline
│   ├── phase1_example.jl       # Delphi study standalone
│   ├── phase2_example.jl       # Experiments standalone
│   └── phase3_example.jl       # Simulation standalone
├── test/
│   └── runtests.jl            # Unit tests
└── docs/
    └── methodology.md          # Detailed methodology documentation
```

## Core Types

### Capability Dimensions (Fernagu's Framework)
```julia
@enum Capability begin
    Autonomy
    LearningAgility
    CreativeProblemSolving
    Resilience
    Collaboration
    Adaptability
    CriticalThinking
    Leadership
end
```

### Explanation Types (XAI Taxonomy)
```julia
@enum ExplanationType begin
    Procedural
    Pedagogical
    Counterfactual
    Robustness
    Interactive
    Contextual
    Causal
    Strategic
end
```

### Experimental Conditions
```julia
@enum Condition begin
    Control
    GenericXAI
    XAICapabilities
end
```

## Key Functions

### Phase 1: Delphi Study

```julia
# Run complete 3-round Delphi study
rounds, consensus, W_progression, expert_metadata = run_full_delphi_study(
    n_experts=32,
    n_rounds=3,
    seed=123
)

# Compute Kendall's W concordance
W, χ², p_value = compute_kendall_w(ratings_matrix)

# Analyze consensus levels
consensus_df = analyze_consensus(delphi_round)
```

### Phase 2: Experiments

```julia
# Run single RCT experiment
result, data = run_experiment(
    (Procedural, Autonomy);
    n_per_group=22,
    effect_size=0.89
)

# Run all 8 experiments with correction
results, all_data, summary = run_all_experiments(n_per_group=22)

# Apply Holm-Bonferroni correction
adjusted_p, rejections = holm_bonferroni_correction(p_values)
```

### Phase 3: Simulation

```julia
# Initialize simulation
params = SimulationParameters(
    n_operators=180,
    n_clusters=30,
    n_periods=200,
    growth_rate_xai_cap=0.0030  # 6× differential
)

model = initialize_simulation_model(params)

# Run simulation
perf_trajectories, cap_trajectories = run_simulation!(model, 200)

# Run ablation studies
ablation_results = run_ablation_studies(params; n_replications=500)
```

### Statistical Analysis

```julia
# Linear Mixed Model
model, icc = linear_mixed_model_analysis(dataframe)

# Power analysis for cluster-RCT
mde, design_effect, effective_n = power_analysis(
    n_facilities=24,
    n_per_facility=30,
    icc=0.18
)

# Sensitivity analysis
sensitivity_results = sensitivity_analysis(
    params,
    param_name=:growth_rate_ratio,
    param_range=[2.0, 3.0, 4.0, 5.0, 6.0]
)
```

### Visualization

```julia
# Plot capability trajectories
plot_capability_trajectories(cap_trajectories)

# Plot performance comparison
plot_performance_comparison(perf_trajectories)

# Plot consensus matrix
plot_consensus_matrix(consensus_df)

# Plot ablation results
plot_ablation_comparison(ablation_results)
```

## Parameters and Configuration

### Simulation Parameters

```julia
SimulationParameters(
    # Population
    n_operators = 180,
    n_clusters = 30,
    operators_per_cluster = 6,
    
    # Time
    n_periods = 200,
    n_replications = 500,
    
    # Growth rates (CRITICAL ASSUMPTION)
    growth_rate_control = 0.0005,
    growth_rate_generic = 0.0015,
    growth_rate_xai_cap = 0.0030,  # 6× differential (unvalidated)
    
    # Performance model
    base_performance = 500.0,
    capability_coupling = 0.35,  # α in f_capability = 1 - α*c̄
    
    # Psychological realism
    hawthorne_base = 0.08,
    demand_char_boost = 0.12,
    complacency_rate = 0.001,
    atrophy_rate = 0.0002
)
```

## Key Results from Paper

### Phase 1: Expert Consensus
- **N = 32 experts** across 4 domains (XAI, cognitive science, psychology, operations)
- **Kendall's W = 0.78** (p < 0.001) - strong convergence
- **8 primary mappings** identified with strong support

### Phase 2: Experimental Validation
- **N = 180 participants** (novice sample)
- **5/8 mappings validated** after Holm-Bonferroni correction
- **Cohen's d = 0.68–0.89** for validated mappings
- **⚠ Requires replication** with experienced operators

### Phase 3: Simulation Evidence
- **180 virtual operators**, 200 periods, 500 replications
- **Capability-mediated improvements** (ablated):
  - Conservative (2×): 3.1% (d=0.31)
  - Moderate (3×): 5.7% (d=0.58)
  - Optimistic (6×): 8.2% (d=0.86)
- **⚠ Depends on unvalidated** growth rate assumptions

## Critical Limitations

1. **Phase 2 Sample:** Novice participants, not experienced industrial operators
   - Expertise Reversal Effect may apply
   - Requires replication with target population

2. **Simulation Validity:** Model-generated results, not empirical data
   - Growth rate assumptions (6×) lack validation
   - Psychological realism is approximate

3. **Generalization:** Job-shop scheduling only
   - Other optimization problems unvalidated
   - Other industrial sectors unvalidated

4. **Temporal Scope:** 200 periods ≈ 40 weeks
   - Multi-year development unassessed
   - Organizational transformation unmodeled

## Future Work: Phase 4 Field Trials

The package includes specifications for definitive validation:

```julia
# Cluster-randomized trial design
field_trial_design = (
    n_facilities = 24,              # 8 per condition
    n_operators_per_facility = 30,  # Total N=720
    duration_months = 18,
    followup_months = 24,
    population = "Experienced operators (5+ years)",
    context = "Authentic production environments"
)
```

**Objectives:**
- Empirically validate growth rate differentials
- Assess transfer effects across tasks
- Evaluate sustainability after intervention withdrawal
- Measure cost-effectiveness and ROI

## Citation

If you use this package in your research, please cite:

```bibtex
@article{bezoui2025xai,
  title={Human-Centered Explainable AI for Industrial Optimization: 
         Integrating Capability Theory with Progressive Validation},
  author={Bezoui, Madani and Delamare, Micka{\"e}l},
  journal={Computers \& Industrial Engineering},
  year={2025},
  publisher={Elsevier}
}
```

## License

MIT License

Copyright (c) 2025 Madani Bezoui, Mickaël Delamare

## Contact

**Corresponding Author:**  
Madani Bezoui  
LINEACT - CESI, Nancy Campus  
Email: mbezoui@cesi.fr

**Co-Author:**  
Mickaël Delamare  
LINEACT - CESI, Rouen Campus  
Email: mdelamare@cesi.fr

## Acknowledgments

We thank the 32 expert panelists and 180 experimental participants. We also acknowledge the rigorous peer review process that improved this work.

## References

See paper for complete references. Key theoretical foundations:

1. Sen, A. (1999). *Development as Freedom*. Oxford University Press.
2. Fernagu, S. (2012). *Favoriser un environnement « capacitant »*. Éditions de l'ANACT.
3. Arrieta, A. B., et al. (2020). Explainable Artificial Intelligence (XAI): Concepts, taxonomies, opportunities and challenges. *Information Fusion*, 58, 82-115.

---

**Package Status:** Proof-of-concept implementation  
**Validation Status:** Phases 1-3 complete; Phase 4 (field trials) specified but not conducted  
**Reproducibility:** Full replication code and data available
