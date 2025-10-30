"""
Phase 3: Agent-Based Simulation with Ablation Studies

180 virtual operators, 30 clusters, 200 periods, 500 replications.
"""

using Agents

"""
Initialize operator agent with capabilities and properties.
"""
@agent struct Operator(GridAgent{2})
    cluster_id::Int
    condition::Condition
    experience::ExperienceLevel
    capabilities::Vector{Float64}  # 8 dimensions
    base_performance::Float64
    hawthorne_effect::Float64
    demand_characteristic::Float64
    complacency_level::Float64
end

"""
    initialize_simulation_model(params::SimulationParameters; seed=123)

Create agent-based model with 180 operators in 30 clusters.
"""
function initialize_simulation_model(params::SimulationParameters; seed=123)
    Random.seed!(seed)
    
    space = GridSpaceSingle((30, 6); periodic=false)
    model = ABM(Operator, space; properties=Dict(:params => params, :period => 0), rng=MersenneTwister(seed))
    
    # Create 30 clusters (10 per condition)
    clusters_per_condition = params.n_clusters ÷ 3
    
    for cluster_id in 1:params.n_clusters
        # Assign condition
        if cluster_id <= clusters_per_condition
            cond = Control
        elseif cluster_id <= 2 * clusters_per_condition
            cond = GenericXAI
        else
            cond = XAICapabilities
        end
        
        # Create 6 operators per cluster
        for op_in_cluster in 1:params.operators_per_cluster
            # Assign experience level (33% each)
            if op_in_cluster <= 2
                exp_level = Novice
                exp_mod = params.novice_modifier
            elseif op_in_cluster <= 4
                exp_level = Intermediate
                exp_mod = params.intermediate_modifier
            else
                exp_level = Expert
                exp_mod = params.expert_modifier
            end
            
            # Initialize capabilities (random 0.2-0.4 range)
            init_caps = rand(Uniform(0.2, 0.4), 8)
            
            # Psychological factors
            hawthorne = cond != Control ? params.hawthorne_base : 0.0
            demand = cond == XAICapabilities ? params.demand_char_boost : 0.0
            
            # Add operator to model
            add_agent!(
                (cluster_id, op_in_cluster),
                model,
                cluster_id,
                cond,
                exp_level,
                init_caps,
                params.base_performance,
                hawthorne,
                demand,
                0.0  # initial complacency
            )
        end
    end
    
    return model
end

"""
    agent_step!(operator, model)

Update operator capabilities and performance for one period.
"""
function agent_step!(operator::Operator, model)
    params = model.params
    period = model.period
    
    # Capability growth
    growth_rate = get_growth_rate(operator.condition, params)
    experience_mod = get_experience_modifier(operator.experience, params)
    
    for i in 1:8
        # Growth with saturation
        growth = growth_rate * experience_mod * (1 - operator.capabilities[i])
        noise = rand(Normal(0, params.measurement_noise_sd))
        operator.capabilities[i] = clamp(operator.capabilities[i] + growth + noise, 0.0, 1.0)
    end
    
    # Update complacency (increases over time)
    if operator.condition != Control
        operator.complacency_level += params.complacency_rate
    end
    
    # Capability atrophy if complacent
    if operator.complacency_level > 0.5
        for i in 1:8
            operator.capabilities[i] -= params.atrophy_rate
            operator.capabilities[i] = max(0.0, operator.capabilities[i])
        end
    end
end

"""
    model_step!(model)

Global model update for one period.
"""
function model_step!(model)
    model.period += 1
end

"""
    compute_operator_performance(operator, params; ablate_condition_factor=false)

Compute operator performance based on capabilities and condition.
"""
function compute_operator_performance(operator::Operator, params::SimulationParameters; 
                                     ablate_condition_factor=false)
    # Base performance
    perf = params.base_performance
    
    # Condition factor (can be ablated)
    if !ablate_condition_factor
        if operator.condition == Control
            perf *= params.fcond_control
        elseif operator.condition == GenericXAI
            perf *= params.fcond_generic
        else
            perf *= params.fcond_xai_cap
        end
    end
    
    # Capability coupling: fcapability = 1 - α * mean(capabilities)
    mean_cap = mean(operator.capabilities)
    capability_factor = 1 - params.capability_coupling * mean_cap
    perf *= capability_factor
    
    # Noise
    perf *= rand(Normal(1.0, params.performance_noise_sd))
    
    return max(perf, 100.0)  # Minimum makespan
end

"""
    get_growth_rate(condition, params)

Get capability growth rate for condition.
"""
function get_growth_rate(condition::Condition, params::SimulationParameters)
    if condition == Control
        return params.growth_rate_control
    elseif condition == GenericXAI
        return params.growth_rate_generic
    else
        return params.growth_rate_xai_cap
    end
end

"""
    get_experience_modifier(experience, params)

Get experience-based modifier for capability growth.
"""
function get_experience_modifier(experience::ExperienceLevel, params::SimulationParameters)
    if experience == Novice
        return params.novice_modifier
    elseif experience == Intermediate
        return params.intermediate_modifier
    else
        return params.expert_modifier
    end
end

"""
    run_simulation!(model, n_periods; ablate_condition_factor=false)

Run simulation for specified number of periods.

Returns performance and capability trajectories.
"""
function run_simulation!(model, n_periods::Int; ablate_condition_factor=false)
    params = model.params
    
    # Initialize tracking
    performance_by_condition = Dict(
        Control => Float64[],
        GenericXAI => Float64[],
        XAICapabilities => Float64[]
    )
    
    capability_trajectories = Dict(
        Control => zeros(Float64, 8, n_periods),
        GenericXAI => zeros(Float64, 8, n_periods),
        XAICapabilities => zeros(Float64, 8, n_periods)
    )
    
    # Run simulation
    for period in 1:n_periods
        step!(model, agent_step!, model_step!)
        
        # Compute performance by condition
        for cond in instances(Condition)
            agents_cond = filter(a -> a.condition == cond, allagents(model))
            if !isempty(agents_cond)
                perfs = [compute_operator_performance(a, params; 
                        ablate_condition_factor=ablate_condition_factor) 
                        for a in agents_cond]
                push!(performance_by_condition[cond], mean(perfs))
                
                # Track capabilities
                for i in 1:8
                    capability_trajectories[cond][i, period] = mean([a.capabilities[i] for a in agents_cond])
                end
            end
        end
    end
    
    return performance_by_condition, capability_trajectories
end

"""
    run_ablation_studies(params; n_replications=100)

Run comprehensive ablation studies isolating capability-mediated mechanisms.
"""
function run_ablation_studies(params::SimulationParameters; n_replications=100)
    println("Running Ablation Studies...")
    println("="^80)
    
    ablation_scenarios = [
        AblationScenario(
            name="Baseline (Full Model)",
            remove_condition_factor=false,
            growth_rate_ratio=6.0,
            capability_coupling_alpha=0.35,
            description="Full model with all factors"
        ),
        AblationScenario(
            name="Ablation 1: Remove Condition Factor",
            remove_condition_factor=true,
            growth_rate_ratio=6.0,
            capability_coupling_alpha=0.35,
            description="Pure capability-mediated effects"
        ),
        AblationScenario(
            name="Ablation 2: Conservative Growth (2×)",
            remove_condition_factor=true,
            growth_rate_ratio=2.0,
            capability_coupling_alpha=0.35,
            description="Conservative assumption test"
        ),
        AblationScenario(
            name="Ablation 3: Moderate Growth (3×)",
            remove_condition_factor=true,
            growth_rate_ratio=3.0,
            capability_coupling_alpha=0.35,
            description="Moderate assumption test"
        )
    ]
    
    results_by_scenario = Dict()
    
    for scenario in ablation_scenarios
        println("\n$(scenario.name)")
        println("  $(scenario.description)")
        
        # Adjust parameters
        scenario_params = deepcopy(params)
        scenario_params.growth_rate_xai_cap = params.growth_rate_control * scenario.growth_rate_ratio
        scenario_params.capability_coupling = scenario.capability_coupling_alpha
        
        # Run replications
        final_perfs = Dict(Control => Float64[], GenericXAI => Float64[], XAICapabilities => Float64[])
        
        for rep in 1:n_replications
            model = initialize_simulation_model(scenario_params; seed=rep)
            perf_traj, cap_traj = run_simulation!(model, params.n_periods; 
                                                 ablate_condition_factor=scenario.remove_condition_factor)
            
            for cond in instances(Condition)
                push!(final_perfs[cond], perf_traj[cond][end])
            end
        end
        
        # Compute statistics
        control_mean = mean(final_perfs[Control])
        xai_cap_mean = mean(final_perfs[XAICapabilities])
        improvement = (control_mean - xai_cap_mean) / control_mean * 100
        cohens_d = (control_mean - xai_cap_mean) / std(final_perfs[Control])
        
        println("  Control: M=$(round(control_mean, digits=1)), SD=$(round(std(final_perfs[Control]), digits=1))")
        println("  XAI-Cap: M=$(round(xai_cap_mean, digits=1)), SD=$(round(std(final_perfs[XAICapabilities]), digits=1))")
        println("  Improvement: $(round(improvement, digits=1))%")
        println("  Cohen's d: $(round(cohens_d, digits=2))")
        
        results_by_scenario[scenario.name] = (
            scenario=scenario,
            final_performances=final_perfs,
            improvement_pct=improvement,
            cohens_d=cohens_d
        )
    end
    
    return results_by_scenario
end
