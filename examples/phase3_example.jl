"""
Phase 3 Example: Agent-Based Simulation with Ablation Studies

Demonstrates simulation with 180 virtual operators and comprehensive ablations.
"""

using XAICapabilities
using Plots

println("PHASE 3: AGENT-BASED SIMULATION")
println("="^70)

# Initialize parameters
params = SimulationParameters(
    n_operators=180,
    n_clusters=30,
    n_periods=200,
    growth_rate_control=0.0005,
    growth_rate_xai_cap=0.0030  # 6× differential
)

println("\nSimulation Parameters:")
println("  Operators: $(params.n_operators) ($(params.n_clusters) clusters)")
println("  Periods: $(params.n_periods)")
println("  Growth rate ratio: 6×")

# Run single demonstration
println("\nRunning demonstration (1 replication)...")
model = initialize_simulation_model(params; seed=789)
perf_traj, cap_traj = run_simulation!(model, params.n_periods)

# Visualize single replication
p1 = plot_performance_comparison(perf_traj)
savefig(p1, "phase3_performance_trajectory.png")

p2 = plot_capability_trajectories(cap_traj)
savefig(p2, "phase3_capability_trajectories.png")

println("✓ Saved trajectory plots")

# Run comprehensive ablation studies
println("\nRunning ablation studies (100 replications)...")
ablation_results = run_ablation_studies(params; n_replications=100)

# Visualize ablation comparison
p3 = plot_ablation_comparison(ablation_results)
savefig(p3, "phase3_ablation_comparison.png")

println("✓ Saved ablation comparison")

# Display key results
println("\nKey Results (Ablated):")
for (name, result) in ablation_results
    if contains(name, "Ablation")
        println("  $(result.scenario.description):")
        println("    Improvement: $(round(result.improvement_pct, digits=1))%")
        println("    Cohen's d: $(round(result.cohens_d, digits=2))")
    end
end

println("\n" * "="^70)
println("Phase 3 Complete!")
println("="^70)
