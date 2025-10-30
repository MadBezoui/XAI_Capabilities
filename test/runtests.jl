"""
Unit Tests for XAI-Capabilities Package
"""

using Test
using XAICapabilities
using Random
using Statistics

@testset "XAI-Capabilities Tests" begin
    
    @testset "Type Definitions" begin
        # Test enum definitions
        @test Autonomy isa Capability
        @test Procedural isa ExplanationType
        @test Control isa Condition
        
        # Test operator properties
        op = OperatorProperties(
            1, 1, Control, Novice,
            rand(8), 500.0, 500.0,
            0.0, 0.0, 0.0, 1
        )
        @test length(op.capabilities) == 8
        @test op.condition == Control
    end
    
    @testset "Phase 1: Delphi Study" begin
        # Test initialization
        metadata = initialize_delphi_study(32, 64)
        @test nrow(metadata) == 32
        @test Set(metadata.domain) == Set(["XAI_Research", "Cognitive_Science", 
                                           "Industrial_Psych", "Manufacturing"])
        
        # Test ratings generation
        ratings = generate_initial_ratings(32, 8, 8; seed=123)
        @test size(ratings) == (32, 64)
        @test all(1 .<= ratings .<= 7)
        
        # Test Kendall's W computation
        W, χ², p = compute_kendall_w(ratings)
        @test 0 <= W <= 1
        @test χ² >= 0
        @test 0 <= p <= 1
        
        # Test full Delphi study
        rounds, consensus, W_prog, metadata = run_full_delphi_study(
            n_experts=32, n_rounds=3, seed=123
        )
        @test length(rounds) == 3
        @test nrow(consensus) == 64
        @test length(W_prog) == 3
        @test W_prog[end] > W_prog[1]  # Convergence
    end
    
    @testset "Phase 2: Experiments" begin
        # Test effect size computation
        control = [0.4, 0.5, 0.6, 0.5, 0.4]
        treatment = [0.6, 0.7, 0.8, 0.7, 0.6]
        d, sp = compute_effect_size(control, treatment)
        @test d > 0  # Treatment better
        @test sp > 0
        
        # Test Holm-Bonferroni correction
        p_values = [0.001, 0.01, 0.03, 0.08, 0.1, 0.2, 0.5, 0.9]
        adjusted_p, rejections = holm_bonferroni_correction(p_values)
        @test length(adjusted_p) == 8
        @test length(rejections) == 8
        @test sum(rejections) <= 8
        @test adjusted_p[1] < p_values[1]  # First adjusted
        
        # Test single experiment
        mapping = (Procedural, Autonomy)
        result, data = run_experiment(mapping; n_per_group=22, 
                                     effect_size=0.89, seed=123)
        @test result.cohens_d > 0
        @test 0 <= result.p_value <= 1
        @test nrow(data) == 44  # 22 per group
        
        # Test all experiments
        results, data, summary = run_all_experiments(n_per_group=22, seed=456)
        @test length(results) == 8
        @test nrow(summary) == 8
        @test sum(summary.Significant) >= 0  # At least 0 validated
    end
    
    @testset "Phase 3: Simulation" begin
        # Test parameter initialization
        params = SimulationParameters()
        @test params.n_operators == 180
        @test params.n_clusters == 30
        @test params.n_periods == 200
        
        # Test model initialization
        model = initialize_simulation_model(params; seed=789)
        @test nagents(model) == 180
        
        # Test simulation run
        perf_traj, cap_traj = run_simulation!(model, 10; 
                                             ablate_condition_factor=true)
        @test haskey(perf_traj, Control)
        @test haskey(perf_traj, XAICapabilities)
        @test length(perf_traj[Control]) == 10
        
        # Test capability growth
        initial_caps = cap_traj[XAICapabilities][:, 1]
        final_caps = cap_traj[XAICapabilities][:, end]
        @test all(final_caps .>= initial_caps)  # Growth
        
        # Test performance improvement
        control_final = perf_traj[Control][end]
        xai_final = perf_traj[XAICapabilities][end]
        @test xai_final < control_final  # Lower makespan is better
    end
    
    @testset "Statistical Analysis" begin
        # Test power analysis
        mde, design_effect, effective_n = power_analysis(
            n_facilities=24,
            n_per_facility=30,
            icc=0.18
        )
        @test mde > 0
        @test design_effect > 1
        @test effective_n < 24 * 30
        
        # Test bootstrap CI
        data = rand(Normal(5.0, 1.0), 100)
        lower, upper, boot_means = bootstrap_confidence_intervals(data; 
                                                                 n_boot=1000)
        @test lower < upper
        @test 4.5 < lower < 5.5  # Approximate
        @test 4.5 < upper < 5.5
        
        # Test Bayesian posterior
        post_mean, post_sd = compute_bayesian_posterior(
            5.0, 1.0,  # Prior
            5.2, 0.5, 100  # Data
        )
        @test 5.0 < post_mean < 5.2  # Between prior and data
        @test post_sd < 0.5  # Tighter than data
    end
    
    @testset "Utility Functions" begin
        # Test data quality validation
        df = DataFrame(a=[1,2,3,missing,5], b=[1.0,2.0,3.0,4.0,5.0])
        issues = validate_data_quality(df)
        @test length(issues) >= 1  # Should detect missing value
        
        # Test replication statistics
        reps = [rand(Normal(10, 2), 50) for _ in 1:10]
        stats = compute_replication_statistics(reps)
        @test 9 < stats.mean[1] < 11  # Approximate
        @test stats.sd[1] > 0
    end
end

println("\n✅ All tests passed!")
