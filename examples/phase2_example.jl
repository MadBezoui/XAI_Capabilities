"""
Phase 2 Example: Randomized Controlled Experiments

Demonstrates 8 parallel RCTs with Holm-Bonferroni correction.
"""

using XAICapabilities
using Plots
using DataFrames

println("PHASE 2: RANDOMIZED CONTROLLED EXPERIMENTS")
println("="^70)

# Run all 8 experiments
results, data, summary = run_all_experiments(n_per_group=22, seed=456)

# Display summary
println("\nExperimental Results:")
println(summary)

# Count validated mappings
n_validated = sum(summary.Significant)
println("\nValidated Mappings: $n_validated/8")

# Visualize results
p1 = plot_experimental_results(summary)
savefig(p1, "phase2_experimental_validation.png")
println("\n✓ Saved: phase2_experimental_validation.png")

# Compute capability weights for Phase 3
weights = compute_differential_weights(results)
println("\nCapability Weights (for simulation):")
for (i, w) in enumerate(weights)
    println("  Capability $i: $(round(w, digits=2))")
end

# Export data
export_results(summary, "phase2_summary.csv")
export_results(data, "phase2_full_data.csv")

println("\n" * "="^70)
println("Phase 2 Complete!")
println("="^70)
