---
# Benchmark Harness — Writing `prepare.py`

`prepare.py` is the sacred, immutable measurement tool. The agent never edits it. The human writes it once and locks it down.

## Responsibilities

1. **Environment setup** — Ensure data, tools, or inputs exist
2. **Fixed constants** — Time budget, sequence length, seed, etc.
3. **Run the experiment** — Call the target (e.g., synthesize RTL, run simulation)
4. **Measure the metric** — Extract one deterministic number
5. **Print clean output** — One line the agent can `grep`

## Structure Template

```python
#!/usr/bin/env python3
"""
prepare.py — Immutable evaluation harness.
DO NOT MODIFY. This file is read-only for the agent.
"""

import subprocess, json, os, time, sys
from pathlib import Path

# ── Fixed Constants ──────────────────────────────────────────────
TIME_BUDGET_SECONDS = 300      # Wall-clock budget for the experiment
RANDOM_SEED = 1337              # For deterministic runs
TOOL_PATH = os.environ.get("YOSYS", "yosys")

# ── Environment Check ────────────────────────────────────────────
def check_environment():
    """Verify data / tools exist. Fail fast if not."""
    if not Path("train.py").exists():
        print("ERROR: train.py not found", file=sys.stderr)
        sys.exit(1)
    # Add more checks as needed

# ── Run Experiment ───────────────────────────────────────────────
def run_experiment():
    """
    Execute the experiment within the fixed time budget.
    Return raw outputs needed for metric computation.
    """
    start = time.time()
    
    # Example: run synthesis via subprocess
    result = subprocess.run(
        [TOOL_PATH, "-p", "read_verilog train.py; synth -top top; stat"],
        capture_output=True, text=True, timeout=TIME_BUDGET_SECONDS
    )
    
    elapsed = time.time() - start
    return result, elapsed

# ── Extract Metric ───────────────────────────────────────────────
def extract_metric(result):
    """
    Parse the experiment output and return a single float.
    Must be deterministic: same input → same number.
    """
    # Example: parse Yosys "Chip area" line
    for line in result.stdout.splitlines():
        if "Chip area" in line:
            # e.g., "Chip area for module '\top': 1234.56"
            parts = line.split(":")
            if len(parts) >= 2:
                return float(parts[-1].strip().split()[0])
    
    # Fallback: if metric not found, return sentinel
    return float("inf")

# ── Print Summary ────────────────────────────────────────────────
def print_summary(metric, elapsed, peak_mem_mb=0.0):
    """
    Print a block the agent can grep. Format is critical.
    """
    print("---")
    print(f"area_um2: {metric:.6f}")      # <─ agent greps this line
    print(f"training_seconds: {elapsed:.1f}")
    print(f"total_seconds: {elapsed:.1f}")
    print(f"peak_vram_mb: {peak_mem_mb:.1f}")
    print(f"budget_seconds: {TIME_BUDGET_SECONDS}")

# ── Main ─────────────────────────────────────────────────────────
def main():
    check_environment()
    result, elapsed = run_experiment()
    
    if result.returncode != 0:
        print("ERROR: experiment failed", file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        sys.exit(1)
    
    metric = extract_metric(result)
    print_summary(metric, elapsed)

if __name__ == "__main__":
    main()
```

## Key Design Rules

### 1. Determinism

Same seed → same metric. No randomness in the harness itself.

- Set `RANDOM_SEED` and propagate to the experiment
- Pin tool versions (Yosys 0.37, not "latest")
- Fix input files (don't download on every run)

### 2. Time Boxing

The harness enforces the budget, not the agent.

```python
# Python subprocess
timeout=TIME_BUDGET_SECONDS

# Bash wrapper
timeout $TIME_BUDGET_SECONDS yosys -p "..."
```

If the experiment exceeds budget, the harness kills it and returns a sentinel metric (e.g., `inf`).

### 3. Metric Isolation

The metric must reflect only the experiment's quality, not environmental noise.

- **Good**: `area_um2` from a fixed synthesis script
- **Bad**: `wall_clock_time` (varies by machine load)
- **Good**: `coverage_pct` from a fixed testbench
- **Bad**: `number_of_warnings` (may include noise)

### 4. One-Line Grep

The agent extracts the metric with a simple `grep`:

```bash
grep "^area_um2:" run.log
```

Output format must be:
```
area_um2: 1234.567890
```

No extra text, no units in the value, no commas.

### 5. Memory Tracking (Optional but Recommended)

Track peak memory so the agent can reject OOM-prone changes:

```python
import resource
peak_mem_mb = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss / 1024
```

Or use `/usr/bin/time -v` and parse `Maximum resident set size`.

### 6. Fail Fast

If the environment is broken (tool missing, data missing), exit immediately with a clear error. Don't let the agent waste experiments on a broken harness.

### 7. Read-Only Contract

Add a comment at the top:

```python
# ═══════════════════════════════════════════════════════════════
# READ-ONLY FILE — DO NOT EDIT
# This file is the sacred metric harness. The agent must not
# modify it. Changes here break experiment comparability.
# ═══════════════════════════════════════════════════════════════
```

## Domain-Specific Harness Examples

### RTL Synthesis (Yosys)

```python
TIME_BUDGET = 600  # 10 min for synth + stat
def run():
    subprocess.run(["yosys", "-p", "read_verilog train.v; synth -top top; stat -liberty liberty.lib"])
def extract(stdout):
    # Parse "Chip area for module '\\top': 12345.67"
```

### STA (OpenSTA / PrimeTime)

```python
TIME_BUDGET = 120  # 2 min for STA
def run():
    subprocess.run(["sta", "-exit", "run_sta.tcl"])
def extract(stdout):
    # Parse "wns -0.123" → metric = -wns (lower = better slack violation)
```

### Functional Simulation (VCS / Xcelium)

```python
TIME_BUDGET = 300  # 5 min for compile + sim
def run():
    subprocess.run(["vcs", "-f", "filelist.f", "-o", "simv"])
    subprocess.run(["./simv"])
def extract(stdout):
    # Parse "Coverage: 87.34%"
```

### UVM Regression

```python
TIME_BUDGET = 1800  # 30 min for regression suite
def run():
    subprocess.run(["make", "regression"])
def extract(stdout):
    # Parse "TOTAL COVERAGE: 91.2%"
```

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Metric includes environment noise | Metric bounces ±5% on identical runs | Pin seed, pin tool version, use deterministic mode |
| Harness doesn't kill on timeout | Agent stuck for hours | Use `subprocess.timeout` or `timeout` command |
| Metric line not grep-able | Agent reads empty output | Print `metric_name: value` on its own line |
| Harness crashes silently | Agent sees "crash" for every run | Add explicit error messages to stderr |
| Metric not monotonic with quality | Agent keeps bad changes | Double-check metric definition against human judgment |

---

*`prepare.py` is the oracle. If it's wrong, every experiment is wasted effort. Invest time in getting it right.*
