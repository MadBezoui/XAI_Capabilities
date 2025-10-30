"""
Visualization Functions

Plots for capability trajectories, performance comparisons, consensus matrices, etc.
"""

"""
    plot_capability_trajectories(capability_trajectories, condition_names)

Plot capability development over time for all conditions.
"""
function plot_capability_trajectories(capability_trajectories::Dict, 
                                     capability_names::Vector{String}=["Autonomy", "Learning Agility", 
                                     "Creativity", "Resilience", "Collaboration", "Adaptability", 
                                     "Critical Thinking", "Leadership"])
    n_caps = length(capability_names)
    plots_array = []
    
    for (i, cap_name) in enumerate(capability_names)
        p = plot(title=cap_name, xlabel="Period", ylabel="Capability Level",
                legend=:bottomright, ylims=(0, 1))
        
        for (cond, traj) in capability_trajectories
            plot!(p, 1:size(traj, 2), traj[i, :], 
                 label=string(cond), linewidth=2, alpha=0.8)
        end
        
        push!(plots_array, p)
    end
    
    plot(plots_array..., layout=(4, 2), size=(1200, 1600))
end

"""
    plot_performance_comparison(performance_by_condition; title="Performance Comparison")

Plot performance trajectories for all conditions.
"""
function plot_performance_comparison(performance_by_condition::Dict; 
                                    title="Performance Comparison")
    p = plot(title=title, xlabel="Period", ylabel="Makespan (minutes)",
            legend=:topright, size=(800, 500))
    
    colors = Dict(Control => :red, GenericXAI => :blue, XAICapabilities => :green)
    
    for (cond, perf_traj) in performance_by_condition
        plot!(p, 1:length(perf_traj), perf_traj, 
             label=string(cond), 
             color=colors[cond], 
             linewidth=2.5, 
             alpha=0.8)
    end
    
    # Add improvement annotation
    if haskey(performance_by_condition, Control) && 
       haskey(performance_by_condition, XAICapabilities)
        final_control = performance_by_condition[Control][end]
        final_xai = performance_by_condition[XAICapabilities][end]
        improvement = (final_control - final_xai) / final_control * 100
        
        annotate!(p, length(performance_by_condition[Control]) * 0.7, 
                 final_control * 1.05, 
                 text("Improvement: $(round(improvement, digits=1))%", 10, :left))
    end
    
    return p
end

"""
    plot_consensus_matrix(consensus_df::DataFrame)

Visualize Delphi consensus as heatmap.
"""
function plot_consensus_matrix(consensus_df::DataFrame)
    # Reshape to 8×8 matrix
    matrix = zeros(Float64, 8, 8)
    
    for row in eachrow(consensus_df)
        matrix[row.explanation_type, row.capability] = row.median
    end
    
    explanation_names = ["Procedural", "Pedagogical", "Counterfactual", "Robustness", 
                        "Interactive", "Contextual", "Causal", "Strategic"]
    capability_names = ["Autonomy", "Learning", "Creativity", "Resilience", 
                       "Collaboration", "Adaptability", "Critical", "Leadership"]
    
    heatmap(explanation_names, capability_names, matrix,
           title="Expert Consensus: Explanation-Capability Mappings",
           xlabel="Explanation Type",
           ylabel="Capability Dimension",
           color=:viridis,
           clims=(1, 7),
           size=(800, 700),
           margin=5Plots.mm)
end

"""
    plot_ablation_comparison(results_by_scenario)

Compare results across ablation scenarios.
"""
function plot_ablation_comparison(results_by_scenario::Dict)
    scenario_names = collect(keys(results_by_scenario))
    improvements = [results_by_scenario[name].improvement_pct for name in scenario_names]
    cohens_ds = [results_by_scenario[name].cohens_d for name in scenario_names]
    
    p1 = bar(scenario_names, improvements, 
            title="Performance Improvement by Scenario",
            ylabel="Improvement (%)",
            legend=false,
            xrotation=15,
            color=:steelblue)
    
    p2 = bar(scenario_names, cohens_ds,
            title="Effect Size by Scenario",
            ylabel="Cohen's d",
            legend=false,
            xrotation=15,
            color=:coral)
    
    plot(p1, p2, layout=(2, 1), size=(1000, 800))
end

"""
    plot_experimental_results(summary::DataFrame)

Visualize experimental validation results.
"""
function plot_experimental_results(summary::DataFrame)
    # Effect sizes with confidence
    p1 = scatter(1:nrow(summary), summary.Cohens_d,
                yerror=0.2,  # Approximate SE
                xlabel="Experiment",
                ylabel="Cohen's d",
                title="Effect Sizes Across 8 Experiments",
                legend=false,
                color=[s == "Validated" ? :green : :gray for s in summary.Status],
                markersize=8)
    hline!([0.2, 0.5, 0.8], linestyle=:dash, color=[:blue, :orange, :red], 
          label=["Small", "Medium", "Large"])
    
    # P-values with significance threshold
    p2 = scatter(1:nrow(summary), summary.p_adjusted,
                xlabel="Experiment",
                ylabel="Adjusted p-value",
                title="Statistical Significance (Holm-Bonferroni)",
                legend=false,
                color=[p < 0.05 ? :green : :red for p in summary.p_adjusted],
                markersize=8,
                yscale=:log10)
    hline!([0.05], linestyle=:dash, color=:red, linewidth=2, label="α=0.05")
    
    plot(p1, p2, layout=(2, 1), size=(800, 800))
end

"""
    plot_sensitivity_analysis(sensitivity_results::DataFrame, param_name::String)

Plot sensitivity analysis results.
"""
function plot_sensitivity_analysis(sensitivity_results::DataFrame, param_name::String)
    p1 = plot(sensitivity_results.parameter_value, 
             sensitivity_results.improvement_pct,
             xlabel=param_name,
             ylabel="Improvement (%)",
             title="Sensitivity to $param_name",
             linewidth=2,
             marker=:circle,
             markersize=6,
             color=:steelblue,
             legend=false)
    
    p2 = plot(sensitivity_results.parameter_value,
             sensitivity_results.cohens_d,
             xlabel=param_name,
             ylabel="Cohen's d",
             title="Effect Size vs $param_name",
             linewidth=2,
             marker=:circle,
             markersize=6,
             color=:coral,
             legend=false)
    hline!([0.2, 0.5, 0.8], linestyle=:dash, color=:gray, alpha=0.5)
    
    plot(p1, p2, layout=(2, 1), size=(800, 800))
end

"""
    plot_kendall_w_progression(W_values::Vector{Float64})

Plot Kendall's W convergence across Delphi rounds.
"""
function plot_kendall_w_progression(W_values::Vector{Float64})
    plot(1:length(W_values), W_values,
        xlabel="Delphi Round",
        ylabel="Kendall's W",
        title="Consensus Convergence Across Rounds",
        linewidth=3,
        marker=:circle,
        markersize=10,
        color=:purple,
        legend=false,
        ylims=(0, 1),
        xticks=1:length(W_values))
    hline!([0.7], linestyle=:dash, color=:green, linewidth=2, label="Strong Agreement")
end

"""
    plot_cluster_effects(model)

Visualize cluster-level random effects.
"""
function plot_cluster_effects(cluster_effects::Vector{Float64})
    histogram(cluster_effects,
             xlabel="Cluster Random Effect",
             ylabel="Frequency",
             title="Distribution of Cluster Effects",
             bins=20,
             color=:steelblue,
             alpha=0.7,
             legend=false)
    vline!([0], linestyle=:dash, color=:red, linewidth=2)
end
