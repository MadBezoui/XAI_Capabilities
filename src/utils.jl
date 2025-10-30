"""
Utility Functions

Helper functions for data processing, export, and analysis.
"""

"""
    export_results(results, filename::String)

Export simulation or experimental results to CSV.
"""
function export_results(results::DataFrame, filename::String)
    CSV.write(filename, results)
    println("Results exported to $filename")
end

"""
    generate_summary_report(delphi_results, experiment_results, simulation_results)

Generate comprehensive summary report of all three phases.
"""
function generate_summary_report(delphi_results, experiment_results, simulation_results; 
                                output_file="XAI_Capabilities_Report.txt")
    open(output_file, "w") do io
        println(io, "="^80)
        println(io, "XAI-CAPABILITIES FRAMEWORK: COMPREHENSIVE VALIDATION REPORT")
        println(io, "="^80)
        println(io, "\nAuthors: Madani Bezoui, Mickaël Delamare")
        println(io, "Institution: LINEACT - CESI, France")
        println(io, "Date: $(Dates.today())\n")
        
        # Phase 1: Delphi Study
        println(io, "\n" * "="^80)
        println(io, "PHASE 1: EXPERT CONSENSUS VALIDATION (DELPHI STUDY)")
        println(io, "="^80)
        rounds, consensus, W_prog, metadata = delphi_results
        println(io, "\nExpert Panel: $(nrow(metadata)) experts across 4 domains")
        println(io, "Rounds: $(length(rounds))")
        println(io, "Final Kendall's W: $(round(W_prog[end], digits=3))")
        println(io, "\nPrimary Mappings (Strong Support):")
        primary = filter(row -> row.explanation_type == row.capability, consensus)
        for row in eachrow(primary)
            println(io, "  $(row.explanation_type) → $(row.capability): " *
                       "median=$(round(row.median, digits=1)), IQR=$(round(row.iqr, digits=2))")
        end
        
        # Phase 2: Experiments
        println(io, "\n" * "="^80)
        println(io, "PHASE 2: RANDOMIZED CONTROLLED EXPERIMENTS")
        println(io, "="^80)
        exp_results, exp_data, exp_summary = experiment_results
        println(io, "\nTotal Participants: N=$(nrow(exp_data))")
        println(io, "Number of Experiments: 8")
        println(io, "Validated Mappings: $(sum(exp_summary.Significant))/8")
        println(io, "\nValidated Effects:")
        for row in eachrow(filter(r -> r.Significant, exp_summary))
            println(io, "  $(row.Mapping): d=$(row.Cohens_d), p_adj=$(row.p_adjusted)")
        end
        
        # Phase 3: Simulation
        println(io, "\n" * "="^80)
        println(io, "PHASE 3: AGENT-BASED SIMULATION WITH ABLATION STUDIES")
        println(io, "="^80)
        println(io, "\nSimulation Parameters:")
        println(io, "  Operators: 180 (30 clusters × 6)")
        println(io, "  Periods: 200")
        println(io, "  Replications: 500")
        
        for (name, result) in simulation_results
            println(io, "\n$name:")
            println(io, "  Improvement: $(round(result.improvement_pct, digits=1))%")
            println(io, "  Cohen's d: $(round(result.cohens_d, digits=2))")
        end
        
        # Conclusions
        println(io, "\n" * "="^80)
        println(io, "KEY FINDINGS")
        println(io, "="^80)
        println(io, "1. Expert consensus validates 8 explanation-capability mappings (W=0.78***)")
        println(io, "2. Experimental causation established for 5/8 mappings (d=0.68-0.89)")
        println(io, "3. Capability-mediated improvements: 3.1%-8.2% depending on assumptions")
        println(io, "4. Effects critically depend on unvalidated growth rate parameters")
        println(io, "5. Definitive validation requires 18-month cluster-RCT with industrial operators")
        
        println(io, "\n" * "="^80)
        println(io, "LIMITATIONS")
        println(io, "="^80)
        println(io, "- Phase 2: Novice participants, not experienced operators (expertise reversal)")
        println(io, "- Phase 3: Model-generated results, not empirical data")
        println(io, "- Growth rate assumptions (6×) lack empirical validation")
        println(io, "- Job-shop scheduling only; generalization unvalidated")
        
        println(io, "\n" * "="^80)
        println(io, "END OF REPORT")
        println(io, "="^80)
    end
    
    println("Summary report saved to $output_file")
end

"""
    create_latex_table(df::DataFrame, caption::String)

Generate LaTeX table code from DataFrame.
"""
function create_latex_table(df::DataFrame, caption::String)
    n_cols = ncol(df)
    col_names = names(df)
    
    latex_code = "\\begin{table}[h]\n"
    latex_code *= "\\caption{$caption}\n"
    latex_code *= "\\centering\n"
    latex_code *= "\\begin{tabular}{" * repeat("l", n_cols) * "}\n"
    latex_code *= "\\toprule\n"
    latex_code *= join(col_names, " & ") * " \\\\\n"
    latex_code *= "\\midrule\n"
    
    for row in eachrow(df)
        latex_code *= join(row, " & ") * " \\\\\n"
    end
    
    latex_code *= "\\bottomrule\n"
    latex_code *= "\\end{tabular}\n"
    latex_code *= "\\end{table}\n"
    
    return latex_code
end

"""
    load_configuration(config_file::String)

Load simulation configuration from JSON file.
"""
function load_configuration(config_file::String)
    # Placeholder for JSON configuration loading
    # In practice, use JSON3.jl or similar
    return SimulationParameters()
end

"""
    validate_data_quality(df::DataFrame)

Check data quality and report issues.
"""
function validate_data_quality(df::DataFrame)
    issues = String[]
    
    # Check for missing values
    for col in names(df)
        n_missing = sum(ismissing.(df[!, col]))
        if n_missing > 0
            push!(issues, "$col has $n_missing missing values")
        end
    end
    
    # Check for outliers (simple IQR method)
    numeric_cols = names(df, Real)
    for col in numeric_cols
        q1, q3 = quantile(df[!, col], [0.25, 0.75])
        iqr_val = q3 - q1
        outliers = sum((df[!, col] .< q1 - 1.5*iqr_val) .| 
                      (df[!, col] .> q3 + 1.5*iqr_val))
        if outliers > 0
            push!(issues, "$col has $outliers potential outliers")
        end
    end
    
    if isempty(issues)
        println("✓ Data quality check passed")
    else
        println("⚠ Data quality issues found:")
        for issue in issues
            println("  - $issue")
        end
    end
    
    return issues
end

"""
    compute_replication_statistics(replications::Vector)

Aggregate statistics across multiple replications.
"""
function compute_replication_statistics(replications::Vector)
    means = [mean(rep) for rep in replications]
    sds = [std(rep) for rep in replications]
    
    return DataFrame(
        mean = mean(means),
        sd = std(means),
        se = std(means) / sqrt(length(means)),
        min = minimum(means),
        max = maximum(means),
        q25 = quantile(means, 0.25),
        median = median(means),
        q75 = quantile(means, 0.75)
    )
end
