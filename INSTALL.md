# Installation Guide

## System Requirements

- **Julia**: Version 1.9 or higher
- **OS**: Linux, macOS, or Windows
- **RAM**: Minimum 8GB (16GB recommended for full simulations)
- **Disk Space**: ~2GB for package and dependencies

## Quick Installation

### Step 1: Install Julia

Download and install Julia from [https://julialang.org/downloads/](https://julialang.org/downloads/)

Verify installation:
```bash
julia --version
```

### Step 2: Clone Repository

```bash
git clone https://github.com/MadBezoui/XAI_Capabilities.git
cd XAI_Capabilities_Julia
```

### Step 3: Install Dependencies

#### Option A: Using Makefile (Recommended)

```bash
make install
```

#### Option B: Manual Installation

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

### Step 4: Run Tests

```bash
make test
```

Or manually:

```bash
julia --project=. test/runtests.jl
```

## Verification

Run quick demo to verify installation:

```bash
make demo
```

Expected output:
```
✓ Delphi study complete
✓ Experiments complete
✓ Simulation complete
✓ Demo complete
```

## Detailed Installation Steps

### Installing Individual Dependencies

If automatic installation fails, install dependencies manually:

```julia
using Pkg
Pkg.add("Agents")
Pkg.add("DataFrames")
Pkg.add("Distributions")
Pkg.add("Plots")
Pkg.add("StatsBase")
Pkg.add("MixedModels")
Pkg.add("HypothesisTests")
Pkg.add("CSV")
Pkg.add("GLM")
Pkg.add("MultivariateStats")
Pkg.add("StatsPlots")
```

### Setting Up Julia Environment

```bash
# Add Julia to PATH (Linux/macOS)
export PATH="$PATH:/path/to/julia/bin"

# Add Julia to PATH (Windows)
# Add C:\path\to\julia\bin to System Environment Variables
```

### Configuring Julia

Create `.juliarc.jl` in home directory for custom configurations:

```julia
# ~/.julia/config/startup.jl
ENV["JULIA_NUM_THREADS"] = "auto"  # Use all available cores
```

## Running Examples

### Phase 1: Delphi Study

```bash
make run-phase1
```

Output: `output/phase1_*.{png,csv}`

### Phase 2: Experiments

```bash
make run-phase2
```

Output: `output/phase2_*.{png,csv}`

### Phase 3: Simulation

```bash
make run-phase3
```

Output: `output/phase3_*.{png,csv}`

### Complete Pipeline

```bash
make run-full
```

Output: All results in `output/` directory

## Troubleshooting

### Issue: Julia not found

**Solution:**
```bash
which julia  # Check if Julia is in PATH
export PATH="$PATH:/path/to/julia/bin"
```

### Issue: Package installation hangs

**Solution:**
```julia
# Update package registry
using Pkg
Pkg.Registry.update()
Pkg.update()
```

### Issue: Out of memory

**Solution:**
Reduce simulation parameters in examples:

```julia
params = SimulationParameters(
    n_replications=50,  # Instead of 500
    n_periods=100       # Instead of 200
)
```

### Issue: Plots not displaying

**Solution:**
Install GR backend manually:

```julia
using Pkg
Pkg.add("GR")
Pkg.build("GR")
```

### Issue: Permission denied

**Solution (Linux/macOS):**
```bash
chmod +x examples/*.jl
```

### Issue: Missing LaTeX for plots

**Solution:**
Install LaTeX distribution or use different plot backend:

```julia
# In Julia REPL
ENV["GKSwstype"] = "100"  # Use headless mode
```

## Platform-Specific Notes

### Linux

```bash
# Install required system libraries
sudo apt-get install build-essential libatomic1 python3 gfortran perl wget m4 cmake pkg-config
```

### macOS

```bash
# Install Xcode Command Line Tools
xcode-select --install
```

### Windows

- Install Visual Studio Build Tools or MinGW
- Ensure Julia is added to PATH during installation

## Docker Installation (Alternative)

```dockerfile
# Dockerfile
FROM julia:1.9

WORKDIR /app
COPY . .

RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

CMD ["julia", "--project=.", "examples/run_full_validation.jl"]
```

Build and run:
```bash
docker build -t xai-capabilities .
docker run -v $(pwd)/output:/app/output xai-capabilities
```

## Performance Optimization

### Multi-Threading

Enable Julia threading:

```bash
export JULIA_NUM_THREADS=8  # Use 8 cores
julia --project=. examples/run_full_validation.jl
```

### Memory Management

For large simulations:

```julia
# Explicit garbage collection
GC.gc()

# Reduce memory footprint
params = SimulationParameters(
    n_replications=100,  # Fewer replications
    measurement_noise_sd=0.05  # Less data storage
)
```

## Uninstallation

```bash
# Remove package directory
rm -rf XAI_Capabilities_Julia

# Remove Julia packages (optional)
julia -e 'using Pkg; Pkg.rm("XAICapabilities")'
```

## Getting Help

- **Documentation**: See [USAGE_GUIDE.md](USAGE_GUIDE.md)
- **Issues**: https://github.com/MadBezoui/XAI_Capabilities/issues
- **Email**: mbezoui@cesi.fr

## Next Steps

After successful installation:

1. Read [README.md](README.md) for overview
2. Follow [USAGE_GUIDE.md](USAGE_GUIDE.md) for detailed usage
3. Run examples in `examples/` directory
4. Explore source code in `src/` directory
5. Customize parameters for your research

## Citation

If you use this package, please cite:

```bibtex
@article{bezoui2025xai,
  title={Human-Centered Explainable AI for Industrial Optimization},
  author={Bezoui, Madani and Delamare, Mickaël},
  journal={Computers \& Industrial Engineering},
  year={2025}
}
```
