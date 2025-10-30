"""
Phase 1: Expert Consensus Validation (Delphi Study)

Modified Delphi methodology with 32 experts across 4 domains over 3 rounds.
"""

"""
    initialize_delphi_study(n_experts=32, n_pairs=64)

Initialize Delphi study with expert panel rating explanation-capability pairs.

# Arguments
- `n_experts::Int`: Number of expert panelists (default: 32)
- `n_pairs::Int`: Number of explanation-capability pairs (default: 64 = 8×8)

# Returns
- Initial ratings matrix and expert metadata
"""
function initialize_delphi_study(n_experts=32, n_pairs=64)
    # Expert demographics (4 domains × 8 experts each)
    domains = repeat(["XAI_Research", "Cognitive_Science", "Industrial_Psych", "Manufacturing"], inner=8)
    years_exp = rand(Normal(12.4, 6.2), n_experts) .|> abs .|> floor
    
    expert_metadata = DataFrame(
        expert_id = 1:n_experts,
        domain = domains,
        years_experience = years_exp,
        type = rand(["Academic", "Industry"], n_experts)
    )
    
    return expert_metadata
end

"""
    generate_initial_ratings(n_experts=32, n_explanation=8, n_capability=8; seed=123)

Generate initial ratings for Round 1 of Delphi study.

Simulates expert ratings based on theoretical mappings with noise.
"""
function generate_initial_ratings(n_experts=32, n_explanation=8, n_capability=8; seed=123)
    Random.seed!(seed)
    
    # Primary mappings (diagonal-like structure with strongest support)
    primary_mappings = [
        (1, 1), # Procedural → Autonomy
        (2, 2), # Pedagogical → Learning Agility
        (3, 3), # Counterfactual → Creativity
        (4, 4), # Robustness → Resilience
        (5, 5), # Interactive → Collaboration
        (6, 6), # Contextual → Adaptability
        (7, 7), # Causal → Critical Thinking
        (8, 8)  # Strategic → Leadership
    ]
    
    # Initialize ratings matrix (experts × explanation-capability pairs)
    ratings = zeros(Float64, n_experts, n_explanation * n_capability)
    
    pair_idx = 1
    for exp in 1:n_explanation
        for cap in 1:n_capability
            if (exp, cap) in primary_mappings
                # Strong support for primary mappings: mean 6.0, sd 0.8
                ratings[:, pair_idx] = rand(Normal(6.0, 0.8), n_experts)
            elseif abs(exp - cap) <= 1
                # Moderate support for adjacent pairs: mean 4.5, sd 1.0
                ratings[:, pair_idx] = rand(Normal(4.5, 1.0), n_experts)
            else
                # Weak support for distant pairs: mean 3.0, sd 1.2
                ratings[:, pair_idx] = rand(Normal(3.0, 1.2), n_experts)
            end
            
            # Clip to valid range [1, 7]
            ratings[:, pair_idx] = clamp.(ratings[:, pair_idx], 1.0, 7.0)
            pair_idx += 1
        end
    end
    
    return ratings
end

"""
    run_delphi_round(prev_ratings, round_number; convergence_threshold=1.5)

Execute a single Delphi round with controlled feedback.

# Arguments
- `prev_ratings::Matrix`: Ratings from previous round (experts × pairs)
- `round_number::Int`: Current round number (1, 2, or 3)
- `convergence_threshold::Float64`: IQR threshold for convergence

# Returns
- `DelphiRound` object with updated ratings and statistics
"""
function run_delphi_round(prev_ratings::Matrix{Float64}, round_number::Int; 
                          convergence_threshold=1.5)
    n_experts, n_pairs = size(prev_ratings)
    
    # Compute group statistics for feedback
    medians = median(prev_ratings, dims=1)[:]
    iqrs = [iqr(prev_ratings[:, i]) for i in 1:n_pairs]
    
    # Update ratings with feedback influence
    new_ratings = copy(prev_ratings)
    
    for pair in 1:n_pairs
        for expert in 1:n_experts
            # Feedback influence: pull toward median
            feedback_weight = round_number == 2 ? 0.3 : 0.5
            current_rating = prev_ratings[expert, pair]
            group_median = medians[pair]
            
            # Weighted update with random noise
            updated = current_rating * (1 - feedback_weight) + 
                     group_median * feedback_weight +
                     rand(Normal(0, 0.3))
            
            new_ratings[expert, pair] = clamp(updated, 1.0, 7.0)
        end
    end
    
    # Generate justifications for extreme ratings
    justifications = Dict{Tuple{Int,Int}, String}()
    for pair in 1:n_pairs
        extreme_experts = findall(x -> x >= 6.5 || x <= 2.0, new_ratings[:, pair])
        for exp in extreme_experts
            justifications[(exp, pair)] = "Theoretical justification for rating $(round(new_ratings[exp, pair], digits=1))"
        end
    end
    
    # Expert confidence (increases with rounds)
    confidence = rand(Uniform(3 + round_number * 0.5, 5.0), n_experts)
    
    return DelphiRound(round_number, new_ratings, justifications, confidence)
end

"""
    compute_kendall_w(ratings::Matrix)

Compute Kendall's W coefficient of concordance.

Measures agreement among raters across multiple items.

# Arguments
- `ratings::Matrix`: Ratings matrix (raters × items)

# Returns
- Kendall's W coefficient (0 to 1, higher = more agreement)
- Chi-square test statistic
- p-value
"""
function compute_kendall_w(ratings::Matrix{Float64})
    n_raters, n_items = size(ratings)
    
    # Rank transform within each rater
    ranked = zeros(Float64, n_raters, n_items)
    for rater in 1:n_raters
        ranked[rater, :] = ordinalrank(ratings[rater, :])
    end
    
    # Sum of ranks for each item
    R = sum(ranked, dims=1)[:]
    R_mean = mean(R)
    
    # Sum of squared deviations
    S = sum((R .- R_mean).^2)
    
    # Kendall's W
    W = (12 * S) / (n_raters^2 * (n_items^3 - n_items))
    
    # Chi-square test
    χ² = n_raters * (n_items - 1) * W
    df = n_items - 1
    p_value = 1 - cdf(Chisq(df), χ²)
    
    return W, χ², p_value
end

"""
    analyze_consensus(delphi_round::DelphiRound)

Analyze consensus from a Delphi round.

# Returns
DataFrame with consensus statistics for each explanation-capability pair
"""
function analyze_consensus(delphi_round::DelphiRound)
    ratings = delphi_round.ratings
    n_experts, n_pairs = size(ratings)
    n_exp = 8
    n_cap = 8
    
    results = DataFrame(
        explanation_type = Int[],
        capability = Int[],
        median = Float64[],
        iqr = Float64[],
        consensus_level = String[]
    )
    
    pair_idx = 1
    for exp in 1:n_exp
        for cap in 1:n_cap
            med = median(ratings[:, pair_idx])
            iqr_val = iqr(ratings[:, pair_idx])
            
            # Classify consensus level
            if med >= 5.5 && iqr_val <= 1.5
                level = "Strong"
            elseif med >= 4.0 && med < 5.5
                level = "Moderate"
            elseif med >= 2.5 && med < 4.0
                level = "Weak"
            else
                level = "None"
            end
            
            push!(results, (exp, cap, med, iqr_val, level))
            pair_idx += 1
        end
    end
    
    return results
end

"""
    run_full_delphi_study(; n_experts=32, n_rounds=3, seed=123)

Execute complete 3-round Delphi study.

# Returns
- Vector of DelphiRound objects (one per round)
- Final consensus analysis DataFrame
- Kendall's W progression
"""
function run_full_delphi_study(; n_experts=32, n_rounds=3, seed=123)
    Random.seed!(seed)
    
    # Initialize
    expert_metadata = initialize_delphi_study(n_experts)
    initial_ratings = generate_initial_ratings(n_experts; seed=seed)
    
    # Run rounds
    rounds = DelphiRound[]
    current_ratings = initial_ratings
    W_progression = Float64[]
    
    for round in 1:n_rounds
        delphi_round = run_delphi_round(current_ratings, round)
        push!(rounds, delphi_round)
        
        # Compute Kendall's W
        W, χ², p = compute_kendall_w(delphi_round.ratings)
        push!(W_progression, W)
        
        println("Round $round: Kendall's W = $(round(W, digits=3)), p < $(round(p, digits=4))")
        
        current_ratings = delphi_round.ratings
    end
    
    # Final consensus analysis
    final_consensus = analyze_consensus(rounds[end])
    
    # Display primary mappings
    primary_mappings = filter(row -> row.explanation_type == row.capability, final_consensus)
    println("\nPrimary Mappings (Strong Support):")
    println(primary_mappings)
    
    return rounds, final_consensus, W_progression, expert_metadata
end
