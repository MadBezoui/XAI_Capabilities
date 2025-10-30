"""
Phase 1 Example: Expert Consensus Validation (Delphi Study)

Demonstrates modified Delphi methodology with 32 experts over 3 rounds.
"""

using XAICapabilities
using Plots
using DataFrames

println("PHASE 1: EXPERT CONSENSUS VALIDATION (DELPHI STUDY)")
println("="^70)

# Run complete Delphi study
rounds, consensus, W_progression, expert_metadata = run_full_delphi_study(
    n_experts=32,
    n_rounds=3,
    seed=123
)

# Display expert metadata
println("\nExpert Panel Composition:")
println(combine(groupby(expert_metadata, :domain), nrow => :count))

# Display Kendall's W progression
println("\nKendall's W Convergence:")
for (i, W) in enumerate(W_progression)
    println("  Round $i: W = $(round(W, digits=3))")
end

# Extract primary mappings (strong support)
primary_mappings = filter(row -> row.explanation_type == row.capability && 
                                row.consensus_level == "Strong", 
                        consensus)

println("\nPrimary Mappings (Strong Support):")
println(primary_mappings[:, [:explanation_type, :capability, :median, :iqr]])

# Visualize consensus matrix
p1 = plot_consensus_matrix(consensus)
savefig(p1, "phase1_consensus_heatmap.png")
println("\n✓ Saved: phase1_consensus_heatmap.png")

# Visualize convergence
p2 = plot_kendall_w_progression(W_progression)
savefig(p2, "phase1_kendall_w_convergence.png")
println("✓ Saved: phase1_kendall_w_convergence.png")

# Export detailed results
export_results(consensus, "phase1_consensus_detailed.csv")
export_results(expert_metadata, "phase1_expert_metadata.csv")

println("\n" * "="^70)
println("Phase 1 Complete!")
println("="^70)
