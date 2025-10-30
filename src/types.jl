"""
Core type definitions for XAI-Capabilities framework.
"""

# Capability dimensions from Fernagu's framework
@enum Capability begin
    Autonomy = 1
    LearningAgility = 2
    CreativeProblemSolving = 3
    Resilience = 4
    Collaboration = 5
    Adaptability = 6
    CriticalThinking = 7
    Leadership = 8
end

# Explanation types from XAI taxonomy
@enum ExplanationType begin
    Procedural = 1
    Pedagogical = 2
    Counterfactual = 3
    Robustness = 4
    Interactive = 5
    Contextual = 6
    Causal = 7
    Strategic = 8
end

# Experimental conditions
@enum Condition begin
    Control = 1
    GenericXAI = 2
    XAICapabilities = 3
end

# Experience levels
@enum ExperienceLevel begin
    Novice = 1
    Intermediate = 2
    Expert = 3
end

"""
    OperatorProperties

Properties of a single operator in the simulation.
"""
mutable struct OperatorProperties
    id::Int64
    cluster_id::Int64
    condition::Condition
    experience::ExperienceLevel
    
    # Capability levels (0.0 to 1.0 for each of 8 dimensions)
    capabilities::Vector{Float64}
    
    # Performance metrics
    base_performance::Float64
    current_performance::Float64
    
    # Psychological factors
    hawthorne_effect::Float64
    demand_characteristic::Float64
    complacency_level::Float64
    
    # Time tracking
    period::Int64
end

"""
    Cluster

Represents a cluster of operators in the simulation.
"""
struct Cluster
    id::Int64
    condition::Condition
    operators::Vector{OperatorProperties}
    cluster_effect::Float64  # Random effect for this cluster
end

"""
    DelphiRound

Data structure for a single Delphi round.
"""
struct DelphiRound
    round_number::Int64
    ratings::Matrix{Float64}  # 32 experts × 64 explanation-capability pairs
    justifications::Dict{Tuple{Int,Int}, String}
    confidence::Vector{Float64}  # Expert confidence levels
end

"""
    ExperimentResult

Results from a single RCT experiment.
"""
struct ExperimentResult
    mapping::Tuple{ExplanationType, Capability}
    n_control::Int64
    n_treatment::Int64
    control_mean::Float64
    control_sd::Float64
    treatment_mean::Float64
    treatment_sd::Float64
    cohens_d::Float64
    p_value::Float64
    p_adjusted::Float64
end

"""
    SimulationParameters

Parameters for agent-based simulation.
"""
@with_kw struct SimulationParameters
    # Population structure
    n_operators::Int64 = 180
    n_clusters::Int64 = 30
    operators_per_cluster::Int64 = 6
    
    # Temporal structure
    n_periods::Int64 = 200
    n_replications::Int64 = 500
    
    # Capability growth rates
    growth_rate_control::Float64 = 0.0005
    growth_rate_generic::Float64 = 0.0015
    growth_rate_xai_cap::Float64 = 0.0030  # 6× differential (base assumption)
    
    # Experience modifiers
    novice_modifier::Float64 = 1.2
    intermediate_modifier::Float64 = 1.0
    expert_modifier::Float64 = 0.8
    
    # Performance model parameters
    base_performance::Float64 = 500.0  # Baseline makespan
    capability_coupling::Float64 = 0.35  # α in fcapability = 1 - α * c_bar
    
    # Condition factors (for non-ablated model)
    fcond_control::Float64 = 1.0
    fcond_generic::Float64 = 0.95
    fcond_xai_cap::Float64 = 0.90
    
    # Psychological realism
    hawthorne_base::Float64 = 0.08
    demand_char_boost::Float64 = 0.12
    complacency_rate::Float64 = 0.001
    atrophy_rate::Float64 = 0.0002
    
    # Noise parameters
    measurement_noise_sd::Float64 = 0.025
    performance_noise_sd::Float64 = 0.05
    
    # Capability weights (from experimental validation)
    capability_weights::Vector{Float64} = [1.0, 1.0, 1.0, 0.6, 0.3, 1.0, 1.0, 0.3]
end

"""
    SimulationResult

Aggregated results from simulation runs.
"""
struct SimulationResult
    condition::Condition
    replication::Int64
    
    # Performance metrics by period
    performance_trajectory::Vector{Float64}
    
    # Capability trajectories (8 dimensions × n_periods)
    capability_trajectories::Matrix{Float64}
    
    # Final period statistics
    final_performance_mean::Float64
    final_performance_sd::Float64
    final_capability_mean::Vector{Float64}
    final_capability_sd::Vector{Float64}
    
    # Comparative metrics
    improvement_vs_control::Float64
    cohens_d_vs_control::Float64
end

"""
    AblationScenario

Configuration for ablation studies.
"""
@with_kw struct AblationScenario
    name::String
    remove_condition_factor::Bool = false
    growth_rate_ratio::Float64 = 6.0  # Multiple of control growth rate
    capability_coupling_alpha::Float64 = 0.35
    description::String = ""
end
