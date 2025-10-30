"""
    XAICapabilities

A Julia package for Capability-Aware Explainable AI in Industrial Optimization.

This package implements the three-phase validation methodology:
- Phase 1: Expert Consensus (Delphi Study)
- Phase 2: Randomized Controlled Experiments
- Phase 3: Agent-Based Simulation with Ablation Studies

Authors: Madani Bezoui, Mickaël Delamare
Institution: LINEACT - CESI, France
"""
module XAICapabilities

using Agents
using CSV
using DataFrames
using Distributions
using GLM
using HypothesisTests
using LinearAlgebra
using MixedModels
using MultivariateStats
using Plots
using Random
using Statistics
using StatsBase
using StatsPlots

# Core types
export Capability, ExplanationType, Condition
export Operator, Cluster, OperatorProperties

# Phase 1: Delphi Study
export DelphiStudy, run_delphi_round, analyze_consensus, compute_kendall_w

# Phase 2: RCT Experiments
export RCTExperiment, run_experiment, compute_effect_size, holm_bonferroni_correction

# Phase 3: Agent-Based Simulation
export SimulationModel, initialize_model, run_simulation!, run_ablation_studies
export compute_performance_metrics, analyze_capability_growth

# Statistical Analysis
export linear_mixed_model_analysis, power_analysis, sensitivity_analysis

# Visualization
export plot_capability_trajectories, plot_performance_comparison, plot_consensus_matrix

# Include source files
include("types.jl")
include("phase1_delphi.jl")
include("phase2_experiments.jl")
include("phase3_simulation.jl")
include("statistical_analysis.jl")
include("visualization.jl")
include("utils.jl")

end # module
