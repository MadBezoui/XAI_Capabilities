"""
Statistical Analysis Functions

Linear Mixed Models, Power Analysis, Sensitivity Analysis
"""

"""
    linear_mixed_model_analysis(df::DataFrame)

Fit Linear Mixed-Effects Model accounting for nested structure.

Model: Y_ijkr = β0 + β1*Condition + β2*Experience + β3*Time + 
                u_r + v_jk + w_ij + ε_ijkr
"""
function linear_mixed_model_analysis(df::DataFrame)
    # Fit LMM with random effects for replication, cluster, operator
    formula = @formula(performance ~ condition + experience + period + 
                                   (1|replication) + (1|cluster) + (1|operator_id))
    
    model = fit(MixedModel, formula, df)
    
    # Extract variance components
    var_components = VarCorr(model)
    
    # Compute ICC for cluster
    σ²_cluster = var_components[:cluster].σ[1]^2
    σ²_operator = var_components[:operator_id].σ[1]^2
    σ²_residual = varest(model)
    
    icc_cluster = σ²_cluster / (σ²_cluster + σ²_operator + σ²_residual)
    
    println("Linear Mixed Model Results")
    println("="^60)
    println(model)
    println("\nVariance Components:")
    println("  Cluster ICC: $(round(icc_cluster, digits=3))")
    println("  σ²_cluster: $(round(σ²_cluster, digits=2))")
    println("  σ²_operator: $(round(σ²_operator, digits=2))")
    println("  σ²_residual: $(round(σ²_residual, digits=2))")
    
    return model, icc_cluster
end

"""
    power_analysis(; n_facilities=24, n_per_facility=30, 
                    icc=0.18, alpha=0.05, power=0.80)

Compute minimum detectable effect for cluster-randomized trial.

# Arguments
- `n_facilities::Int`: Number of facilities (clusters)
- `n_per_facility::Int`: Operators per facility
- `icc::Float64`: Intraclass correlation coefficient
- `alpha::Float64`: Significance level
- `power::Float64`: Target statistical power

# Returns
- Minimum detectable effect size (Cohen's d)
- Design effect
- Effective sample size
"""
function power_analysis(; n_facilities=24, n_per_facility=30, 
                        icc=0.18, alpha=0.05, power=0.80)
    # Design effect for cluster randomization
    design_effect = 1 + (n_per_facility - 1) * icc
    
    # Effective sample size
    total_n = n_facilities * n_per_facility
    effective_n = total_n / design_effect
    
    # Minimum detectable effect (approximate)
    # Using two-sample t-test formula adjusted for clustering
    z_alpha = quantile(Normal(), 1 - alpha/2)
    z_beta = quantile(Normal(), power)
    
    mde = (z_alpha + z_beta) * sqrt(2 * design_effect / n_facilities)
    
    println("Power Analysis for Cluster-Randomized Trial")
    println("="^60)
    println("Total facilities: $n_facilities")
    println("Operators per facility: $n_per_facility")
    println("ICC: $icc")
    println("Design effect: $(round(design_effect, digits=2))")
    println("Total sample size: $total_n")
    println("Effective sample size: $(round(effective_n, digits=1))")
    println("\nWith α=$alpha, power=$power:")
    println("Minimum detectable effect (Cohen's d): $(round(mde, digits=2))")
    
    return mde, design_effect, effective_n
end

"""
    sensitivity_analysis(base_params::SimulationParameters; 
                        param_name::Symbol, 
                        param_range::Vector)

Perform sensitivity analysis by varying a single parameter.

# Example
```julia
results = sensitivity_analysis(params, :growth_rate_ratio, [2.0, 3.0, 4.0, 5.0, 6.0])
```
"""
function sensitivity_analysis(base_params::SimulationParameters; 
                             param_name::Symbol, 
                             param_range::Vector,
                             n_replications=50)
    println("Sensitivity Analysis: $param_name")
    println("="^60)
    
    results = DataFrame(
        parameter_value = Float64[],
        control_mean = Float64[],
        xai_cap_mean = Float64[],
        improvement_pct = Float64[],
        cohens_d = Float64[]
    )
    
    for param_value in param_range
        # Create modified parameters
        test_params = deepcopy(base_params)
        
        if param_name == :growth_rate_ratio
            test_params.growth_rate_xai_cap = base_params.growth_rate_control * param_value
        elseif param_name == :capability_coupling
            test_params.capability_coupling = param_value
        else
            setfield!(test_params, param_name, param_value)
        end
        
        # Run replications
        control_perfs = Float64[]
        xai_cap_perfs = Float64[]
        
        for rep in 1:n_replications
            model = initialize_simulation_model(test_params; seed=rep)
            perf_traj, _ = run_simulation!(model, base_params.n_periods; 
                                          ablate_condition_factor=true)
            
            push!(control_perfs, perf_traj[Control][end])
            push!(xai_cap_perfs, perf_traj[XAICapabilities][end])
        end
        
        # Compute statistics
        control_mean = mean(control_perfs)
        xai_cap_mean = mean(xai_cap_perfs)
        improvement = (control_mean - xai_cap_mean) / control_mean * 100
        cohens_d = (control_mean - xai_cap_mean) / std(control_perfs)
        
        push!(results, (param_value, control_mean, xai_cap_mean, improvement, cohens_d))
        
        println("$param_name = $param_value:")
        println("  Improvement: $(round(improvement, digits=1))%")
        println("  Cohen's d: $(round(cohens_d, digits=2))")
    end
    
    return results
end

"""
    bootstrap_confidence_intervals(data::Vector{Float64}; n_boot=10000, alpha=0.05)

Compute bootstrap confidence intervals for mean.
"""
function bootstrap_confidence_intervals(data::Vector{Float64}; 
                                       n_boot=10000, 
                                       alpha=0.05)
    n = length(data)
    boot_means = zeros(Float64, n_boot)
    
    for i in 1:n_boot
        boot_sample = sample(data, n; replace=true)
        boot_means[i] = mean(boot_sample)
    end
    
    # Percentile method
    lower = quantile(boot_means, alpha/2)
    upper = quantile(boot_means, 1 - alpha/2)
    
    return lower, upper, boot_means
end

"""
    compute_bayesian_posterior(prior_mean, prior_sd, data_mean, data_sd, n)

Compute Bayesian posterior for normal-normal conjugate model.
"""
function compute_bayesian_posterior(prior_mean::Float64, prior_sd::Float64,
                                   data_mean::Float64, data_sd::Float64, n::Int)
    # Precision (inverse variance)
    prior_prec = 1 / prior_sd^2
    data_prec = n / data_sd^2
    
    # Posterior parameters
    post_prec = prior_prec + data_prec
    post_mean = (prior_prec * prior_mean + data_prec * data_mean) / post_prec
    post_sd = sqrt(1 / post_prec)
    
    return post_mean, post_sd
end
