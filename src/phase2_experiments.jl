"""
Phase 2: Controlled Experimental Validation (RCTs)

Eight parallel randomized controlled experiments testing causal effects
of specific explanation types on targeted capabilities.
"""

"""
    simulate_experimental_data(mapping, n_per_group=22; effect_size=0.75, seed=nothing)

Simulate experimental data for a single explanation-capability mapping.

# Arguments
- `mapping::Tuple{ExplanationType, Capability}`: Explanation-capability pair to test
- `n_per_group::Int`: Sample size per condition (default: 22)
- `effect_size::Float64`: True Cohen's d effect size
- `seed::Union{Int,Nothing}`: Random seed for reproducibility

# Returns
- DataFrame with participant data (control and treatment groups)
"""
function simulate_experimental_data(mapping::Tuple{ExplanationType, Capability}, 
                                   n_per_group=22; 
                                   effect_size=0.75, 
                                   seed=nothing)
    if !isnothing(seed)
        Random.seed!(seed)
    end
    
    # Unpack mapping
    explanation, capability = mapping
    
    # Baseline performance parameters (normalized 0-1 scale)
    control_mean = 0.5
    control_sd = 0.15
    
    # Treatment effect
    treatment_mean = control_mean + effect_size * control_sd
    treatment_sd = control_sd
    
    # Generate control group data
    control_pre = rand(Normal(control_mean - 0.1, control_sd), n_per_group)
    control_post = control_pre .+ rand(Normal(0.05, 0.08), n_per_group)  # Small practice effect
    
    # Generate treatment group data
    treatment_pre = rand(Normal(control_mean - 0.1, control_sd), n_per_group)
    treatment_post = treatment_pre .+ rand(Normal(effect_size * control_sd + 0.05, 0.08), n_per_group)
    
    # Clip to valid range [0, 1]
    control_post = clamp.(control_post, 0.0, 1.0)
    treatment_post = clamp.(treatment_post, 0.0, 1.0)
    
    # Create DataFrame
    df = DataFrame(
        participant_id = 1:(2*n_per_group),
        condition = vcat(repeat(["Control"], n_per_group), repeat(["Treatment"], n_per_group)),
        explanation_type = fill(string(explanation), 2*n_per_group),
        capability = fill(string(capability), 2*n_per_group),
        pre_score = vcat(control_pre, treatment_pre),
        post_score = vcat(control_post, treatment_post),
        gain_score = vcat(control_post .- control_pre, treatment_post .- treatment_pre)
    )
    
    return df
end

"""
    compute_effect_size(control_scores, treatment_scores)

Compute Cohen's d effect size between two groups.

# Arguments
- `control_scores::Vector{Float64}`: Scores from control group
- `treatment_scores::Vector{Float64}`: Scores from treatment group

# Returns
- Cohen's d (positive favors treatment)
- Pooled standard deviation
"""
function compute_effect_size(control_scores::Vector{Float64}, 
                            treatment_scores::Vector{Float64})
    n1 = length(control_scores)
    n2 = length(treatment_scores)
    
    m1 = mean(control_scores)
    m2 = mean(treatment_scores)
    
    s1 = std(control_scores)
    s2 = std(treatment_scores)
    
    # Pooled standard deviation
    sp = sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
    
    # Cohen's d
    d = (m2 - m1) / sp
    
    return d, sp
end

"""
    holm_bonferroni_correction(p_values; alpha=0.05)

Apply Holm-Bonferroni sequential correction for multiple comparisons.

# Arguments
- `p_values::Vector{Float64}`: Uncorrected p-values
- `alpha::Float64`: Family-wise error rate (default: 0.05)

# Returns
- Vector of adjusted p-values
- Vector of rejection decisions (true = reject H0)
"""
function holm_bonferroni_correction(p_values::Vector{Float64}; alpha=0.05)
    n = length(p_values)
    
    # Sort p-values and track original indices
    sorted_indices = sortperm(p_values)
    sorted_p = p_values[sorted_indices]
    
    # Holm-Bonferroni adjusted alpha levels
    adjusted_alphas = alpha ./ (n .- (0:n-1))
    
    # Test sequentially
    reject = fill(false, n)
    adjusted_p = fill(1.0, n)
    
    for i in 1:n
        if sorted_p[i] < adjusted_alphas[i]
            reject[sorted_indices[i]] = true
            adjusted_p[sorted_indices[i]] = min(sorted_p[i] * (n - i + 1), 1.0)
        else
            # Stop at first non-rejection
            break
        end
    end
    
    # For non-rejected hypotheses, set adjusted p to 1.0
    for i in 1:n
        if !reject[sorted_indices[i]]
            adjusted_p[sorted_indices[i]] = 1.0
        end
    end
    
    return adjusted_p, reject
end

"""
    run_experiment(mapping; n_per_group=22, effect_size=0.75, seed=nothing)

Run a single RCT experiment for one explanation-capability mapping.

# Returns
- ExperimentResult object with statistical analysis
"""
function run_experiment(mapping::Tuple{ExplanationType, Capability}; 
                       n_per_group=22, 
                       effect_size=0.75, 
                       seed=nothing)
    # Generate data
    df = simulate_experimental_data(mapping, n_per_group; 
                                   effect_size=effect_size, 
                                   seed=seed)
    
    # Extract groups
    control = filter(row -> row.condition == "Control", df)
    treatment = filter(row -> row.condition == "Treatment", df)
    
    control_scores = control.post_score
    treatment_scores = treatment.post_score
    
    # Statistical tests
    t_test = EqualVarianceTTest(treatment_scores, control_scores)
    p_value = pvalue(t_test)
    
    # Effect size
    cohens_d, sp = compute_effect_size(control_scores, treatment_scores)
    
    # Summary statistics
    result = ExperimentResult(
        mapping,
        n_per_group,
        n_per_group,
        mean(control_scores),
        std(control_scores),
        mean(treatment_scores),
        std(treatment_scores),
        cohens_d,
        p_value,
        1.0  # Will be updated after correction
    )
    
    return result, df
end

"""
    run_all_experiments(; n_per_group=22, seed=123)

Execute all 8 parallel RCT experiments with multiple comparison correction.

# Returns
- Vector of ExperimentResult objects
- DataFrame with all participant data
- Summary statistics
"""
function run_all_experiments(; n_per_group=22, seed=123)
    Random.seed!(seed)
    
    # Define 8 primary mappings from Delphi study
    mappings = [
        (Procedural, Autonomy),
        (Pedagogical, LearningAgility),
        (Counterfactual, CreativeProblemSolving),
        (Robustness, Resilience),
        (Interactive, Collaboration),
        (Contextual, Adaptability),
        (Causal, CriticalThinking),
        (Strategic, Leadership)
    ]
    
    # Simulated effect sizes based on paper results
    # 5 validated, 3 weak/non-significant
    true_effect_sizes = [0.89, 0.76, 0.68, 0.42, 0.18, 0.81, 0.72, 0.21]
    
    # Run experiments
    results = ExperimentResult[]
    all_data = DataFrame[]
    
    println("Running 8 parallel RCT experiments...\n")
    
    for (i, (mapping, effect)) in enumerate(zip(mappings, true_effect_sizes))
        exp_result, exp_data = run_experiment(mapping; 
                                             n_per_group=n_per_group, 
                                             effect_size=effect,
                                             seed=seed+i)
        push!(results, exp_result)
        push!(all_data, exp_data)
        
        exp_str, cap_str = string(mapping[1]), string(mapping[2])
        println("Experiment $i: $exp_str → $cap_str")
        println("  Cohen's d = $(round(exp_result.cohens_d, digits=2))")
        println("  p-value = $(round(exp_result.p_value, digits=4))")
    end
    
    # Apply Holm-Bonferroni correction
    p_values = [r.p_value for r in results]
    adjusted_p, rejections = holm_bonferroni_correction(p_values)
    
    # Update results with adjusted p-values
    corrected_results = ExperimentResult[]
    for (i, result) in enumerate(results)
        corrected = ExperimentResult(
            result.mapping,
            result.n_control,
            result.n_treatment,
            result.control_mean,
            result.control_sd,
            result.treatment_mean,
            result.treatment_sd,
            result.cohens_d,
            result.p_value,
            adjusted_p[i]
        )
        push!(corrected_results, corrected)
    end
    
    # Create summary table
    summary = DataFrame(
        Mapping = [string(r.mapping[1]) * " → " * string(r.mapping[2]) for r in corrected_results],
        N = [r.n_control + r.n_treatment for r in corrected_results],
        Control_M = [round(r.control_mean, digits=2) for r in corrected_results],
        Control_SD = [round(r.control_sd, digits=2) for r in corrected_results],
        Treatment_M = [round(r.treatment_mean, digits=2) for r in corrected_results],
        Treatment_SD = [round(r.treatment_sd, digits=2) for r in corrected_results],
        Cohens_d = [round(r.cohens_d, digits=2) for r in corrected_results],
        p_value = [round(r.p_value, digits=4) for r in corrected_results],
        p_adjusted = [round(r.p_adjusted, digits=4) for r in corrected_results],
        Significant = rejections,
        Status = [r.p_adjusted < 0.05 ? "Validated" : 
                 (r.cohens_d > 0.4 ? "Moderate" : "Weak") for r in corrected_results]
    )
    
    println("\n" * "="^80)
    println("Multiple Comparison Correction (Holm-Bonferroni)")
    println("="^80)
    println(summary)
    println("\nValidated mappings: $(sum(rejections))/8")
    
    return corrected_results, vcat(all_data...), summary
end

"""
    compute_differential_weights(results::Vector{ExperimentResult})

Compute capability weights based on experimental validation strength.

Returns weights for use in Phase 3 simulation:
- 1.0 for validated mappings (p_adj < 0.05, d > 0.65)
- 0.6 for moderate evidence (0.4 < d < 0.65)
- 0.3 for weak evidence (d < 0.4)
"""
function compute_differential_weights(results::Vector{ExperimentResult})
    weights = Float64[]
    
    for result in results
        if result.p_adjusted < 0.05 && result.cohens_d >= 0.65
            # Validated: full weight
            push!(weights, 1.0)
        elseif result.cohens_d >= 0.4
            # Moderate evidence
            push!(weights, 0.6)
        else
            # Weak evidence
            push!(weights, 0.3)
        end
    end
    
    return weights
end
