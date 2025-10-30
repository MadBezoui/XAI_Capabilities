# XAI-Capabilities: Usage Guide

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Phase 1: Delphi Study](#phase-1-delphi-study)
4. [Phase 2: RCT Experiments](#phase-2-rct-experiments)
5. [Phase 3: Simulation](#phase-3-simulation)
6. [Statistical Analysis](#statistical-analysis)
7. [Visualization](#visualization)
8. [Advanced Usage](#advanced-usage)
9. [Troubleshooting](#troubleshooting)

## Installation

### Option 1: Using Makefile (Recommended)

```bash
cd XAI_Capabilities_Julia
make install
make test
```

### Option 2: Manual Installation

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

### Option 3: From GitHub

```julia
using Pkg
Pkg.add(url="https://github.com/MadBezoui/XAI_Capabilities")
```

## Quick Start

### Running the Complete Pipeline

```bash
make run-full
```

Or manually:

```julia
using XAICapabilities

# Phase 1
rounds, consensus, W, metadata = run_full_delphi_study()

# Phase 2
results, data, summary = run_all_experiments()

# Phase 3
params = SimulationParameters()
ablation_results = run_ablation_studies(params)
```

### Quick Demo (Fast Version)

```bash
make demo
```

## Phase 1: Delphi Study

### Basic Usage

```julia
using XAICapabilities

# Run 3-round Delphi with 32 experts
rounds, consensus, W_progression, expert_metadata = run_full_delphi_study(
    n_experts=32,
    n_rounds=3,
    seed=123
)

# Check convergence
println("Final Kendall's W: $(W_progression[end])")

# Extract primary mappings
primary = filter(row -> row.consensus_level == "Strong", consensus)
println(primary)
```

### Customizing the Delphi Study

```julia
# Custom number of experts
rounds, consensus, W, metadata = run_full_delphi_study(
    n_experts=48,  # 12 per domain
    n_rounds=4,
    seed=456
)

# Analyze specific round
round2_consensus = analyze_consensus(rounds[2])

# Compute Kendall's W manually
W, χ², p = compute_kendall_w(rounds[3].ratings)
```

### Visualization

```julia
using Plots

# Consensus heatmap
p1 = plot_consensus_matrix(consensus)
savefig(p1, "consensus_heatmap.png")

# Convergence plot
p2 = plot_kendall_w_progression(W_progression)
savefig(p2, "kendall_w_convergence.png")
```

## Phase 2: RCT Experiments

### Running All Experiments

```julia
# Standard configuration (N=180, n≈22 per experiment)
results, data, summary = run_all_experiments(
    n_per_group=22,
    seed=456
)

# Display results
println(summary)

# Count validated mappings
n_validated = sum(summary.Significant)
println("Validated: $n_validated/8")
```

### Running Individual Experiments

```julia
# Test single mapping
mapping = (Procedural, Autonomy)

result, data = run_experiment(
    mapping;
    n_per_group=22,
    effect_size=0.89,  # True effect size
    seed=123
)

println("Cohen's d: $(result.cohens_d)")
println("p-value: $(result.p_value)")
```

### Custom Effect Sizes

```julia
# Simulate different scenarios
mappings = [
    (Procedural, Autonomy),
    (Pedagogical, LearningAgility),
    (Counterfactual, CreativeProblemSolving)
]

effect_sizes = [0.9, 0.8, 0.7]  # Large, large, medium-large

for (mapping, effect) in zip(mappings, effect_sizes)
    result, _ = run_experiment(mapping; effect_size=effect)
    println("$(mapping): d=$(round(result.cohens_d, digits=2))")
end
```

### Multiple Comparison Correction

```julia
# Manual Holm-Bonferroni
p_values = [0.001, 0.01, 0.03, 0.08, 0.1, 0.2, 0.5, 0.9]
adjusted_p, rejections = holm_bonferroni_correction(p_values; alpha=0.05)

for (i, (p, p_adj, reject)) in enumerate(zip(p_values, adjusted_p, rejections))
    status = reject ? "✓ Reject H0" : "✗ Fail to reject"
    println("Test $i: p=$p, p_adj=$p_adj → $status")
end
```

### Computing Capability Weights

```julia
# For use in Phase 3 simulation
weights = compute_differential_weights(results)

# Update simulation parameters
params = SimulationParameters(capability_weights=weights)
```

## Phase 3: Simulation

### Basic Simulation

```julia
# Initialize with default parameters
params = SimulationParameters()
model = initialize_simulation_model(params; seed=789)

# Run for 200 periods
perf_trajectories, cap_trajectories = run_simulation!(
    model,
    params.n_periods;
    ablate_condition_factor=false
)

# Check final performance
control_final = perf_trajectories[Control][end]
xai_cap_final = perf_trajectories[XAICapabilities][end]
improvement = (control_final - xai_cap_final) / control_final * 100

println("Improvement: $(round(improvement, digits=1))%")
```

### Ablation Studies

```julia
# Run comprehensive ablations
ablation_results = run_ablation_studies(
    params;
    n_replications=500  # Paper uses 500
)

# Extract specific scenario
baseline = ablation_results["Baseline (Full Model)"]
ablation1 = ablation_results["Ablation 1: Remove Condition Factor"]

println("Baseline: $(round(baseline.improvement_pct, digits=1))%")
println("Ablated: $(round(ablation1.improvement_pct, digits=1))%")
```

### Custom Simulation Parameters

```julia
# Conservative growth assumptions (2×)
conservative_params = SimulationParameters(
    growth_rate_control=0.0005,
    growth_rate_xai_cap=0.0010,  # 2× instead of 6×
    n_replications=100
)

# Moderate growth assumptions (3×)
moderate_params = SimulationParameters(
    growth_rate_xai_cap=0.0015,  # 3×
    n_replications=100
)

# Run both scenarios
conservative_model = initialize_simulation_model(conservative_params)
perf_cons, _ = run_simulation!(conservative_model, 200; ablate_condition_factor=true)

moderate_model = initialize_simulation_model(moderate_params)
perf_mod, _ = run_simulation!(moderate_model, 200; ablate_condition_factor=true)
```

### Varying Capability Coupling

```julia
# Test different α values in f_capability = 1 - α*c̄
alpha_values = [0.20, 0.30, 0.40, 0.50]
results_by_alpha = Dict()

for α in alpha_values
    params_alpha = SimulationParameters(capability_coupling=α)
    model = initialize_simulation_model(params_alpha)
    perf, _ = run_simulation!(model, 200; ablate_condition_factor=true)
    
    control = perf[Control][end]
    xai_cap = perf[XAICapabilities][end]
    improvement = (control - xai_cap) / control * 100
    
    results_by_alpha[α] = improvement
    println("α=$α: $(round(improvement, digits=1))%")
end
```

## Statistical Analysis

### Linear Mixed Models

```julia
using DataFrames

# Prepare data from simulation
df = DataFrame(
    performance = Float64[],
    condition = String[],
    experience = String[],
    period = Int[],
    replication = Int[],
    cluster = Int[],
    operator_id = Int[]
)

# ... populate from simulation results ...

# Fit LMM
model, icc = linear_mixed_model_analysis(df)

println("ICC (cluster): $(round(icc, digits=3))")
```

### Power Analysis

```julia
# For Phase 4 cluster-RCT
mde, design_effect, effective_n = power_analysis(
    n_facilities=24,
    n_per_facility=30,
    icc=0.18,
    alpha=0.05,
    power=0.80
)

println("Minimum Detectable Effect: d=$(round(mde, digits=2))")
println("Design Effect: $(round(design_effect, digits=2))")
println("Effective N: $(round(effective_n, digits=0))")
```

### Sensitivity Analysis

```julia
# Growth rate sensitivity
sensitivity_growth = sensitivity_analysis(
    params,
    param_name=:growth_rate_ratio,
    param_range=[2.0, 3.0, 4.0, 5.0, 6.0],
    n_replications=50
)

println(sensitivity_growth)

# Capability coupling sensitivity
sensitivity_coupling = sensitivity_analysis(
    params,
    param_name=:capability_coupling,
    param_range=[0.20, 0.25, 0.30, 0.35, 0.40],
    n_replications=50
)
```

### Bootstrap Confidence Intervals

```julia
# For any metric
data = rand(Normal(5.0, 1.0), 100)
lower, upper, boot_means = bootstrap_confidence_intervals(
    data;
    n_boot=10000,
    alpha=0.05
)

println("95% CI: [$(round(lower, digits=2)), $(round(upper, digits=2))]")
```

## Visualization

### Capability Trajectories

```julia
# Plot all 8 capabilities over time
capability_names = [
    "Autonomy", "Learning Agility", "Creativity", "Resilience",
    "Collaboration", "Adaptability", "Critical Thinking", "Leadership"
]

p = plot_capability_trajectories(cap_trajectories, capability_names)
savefig(p, "capability_evolution.png")
```

### Performance Comparison

```julia
p = plot_performance_comparison(
    perf_trajectories;
    title="Makespan Over 200 Periods"
)
savefig(p, "performance_comparison.png")
```

### Ablation Comparison

```julia
p = plot_ablation_comparison(ablation_results)
savefig(p, "ablation_results.png")
```

### Experimental Results

```julia
p = plot_experimental_results(summary)
savefig(p, "experimental_validation.png")
```

## Advanced Usage

### Custom Psychological Realism

```julia
params_custom = SimulationParameters(
    hawthorne_base=0.10,      # Stronger Hawthorne effect
    demand_char_boost=0.15,   # Stronger demand characteristics
    complacency_rate=0.002,   # Faster complacency onset
    atrophy_rate=0.0005       # Faster capability atrophy
)
```

### Multi-Replication Analysis

```julia
n_reps = 100
all_improvements = Float64[]

for rep in 1:n_reps
    model = initialize_simulation_model(params; seed=rep)
    perf, _ = run_simulation!(model, 200; ablate_condition_factor=true)
    
    control = perf[Control][end]
    xai = perf[XAICapabilities][end]
    improvement = (control - xai) / control * 100
    
    push!(all_improvements, improvement)
end

# Statistics across replications
println("Mean improvement: $(round(mean(all_improvements), digits=1))%")
println("SD: $(round(std(all_improvements), digits=1))%")
println("95% CI: [$(round(quantile(all_improvements, 0.025), digits=1)), "*
        "$(round(quantile(all_improvements, 0.975), digits=1))]")
```

### Exporting Results

```julia
# Export consensus
export_results(consensus, "results/phase1_consensus.csv")

# Export experimental summary
export_results(summary, "results/phase2_summary.csv")

# Generate comprehensive report
generate_summary_report(
    (rounds, consensus, W_progression, metadata),
    (results, data, summary),
    ablation_results,
    output_file="results/full_report.txt"
)
```

## Troubleshooting

### Common Issues

**Issue: Package installation fails**
```julia
# Try manual installation
using Pkg
Pkg.activate(".")
Pkg.update()
Pkg.instantiate()
```

**Issue: Out of memory during simulation**
```julia
# Reduce replications
params = SimulationParameters(n_replications=100)  # Instead of 500
```

**Issue: Slow convergence in Delphi**
```julia
# Increase feedback influence
# Modify phase1_delphi.jl, run_delphi_round function
feedback_weight = 0.5  # Instead of 0.3
```

**Issue: Non-significant experimental results**
```julia
# Check effect sizes
# Increase sample size if power is insufficient
results, data, summary = run_all_experiments(n_per_group=30)  # Instead of 22
```

### Getting Help

- Check documentation: `?function_name` in Julia REPL
- GitHub Issues: https://github.com/MadBezoui/XAI_Capabilities/issues
- Contact: mbezoui@cesi.fr

## Citation

```bibtex
@software{bezoui2025xai_package,
  title={XAI-Capabilities: A Julia Package for Capability-Aware Explainable AI},
  author={Bezoui, Madani and Delamare, Mickaël},
  year={2025},
  url={https://github.com/MadBezoui/XAI_Capabilities}
}
```
