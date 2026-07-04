---
# Domain Mapping — Chip Design & Beyond

How to translate Karpathy's autoresearch triad into different domains. Pick your domain, copy the mapping, write the harness.

## RTL Synthesis Optimization

| Component | Mapping |
|-----------|---------|
| `train.py` | Target RTL file (e.g., `mac_core.v`, `arbiter.v`) |
| `prepare.py` | Fixed synthesis script (Yosys / DC / Genus) + area/timing/power extractor |
| Metric | Composite: `area_um2 * (1 + 10 * max(0, -wns_ns))` (area penalized by timing violation) |
| Budget | 10 minutes (synth + report) |
| Agent mutates | Coding style, resource sharing, pipeline depth, state machine encoding, data width |

### prepare.py sketch

```python
TIME_BUDGET = 600

def run():
    subprocess.run(["yosys", "-p", "read_verilog train.v; synth -top top; abc -liberty liberty.lib; stat"])

def extract(stdout):
    area = parse("Chip area for module '\\top':", stdout)
    # For timing, run OpenSTA separately or use Yosys -liberty
    return area
```

### experiment ideas for program.md

1. Change state machine encoding (binary → one-hot → gray)
2. Add / remove pipeline stage
3. Share multiplier across operations
4. Change adder tree structure (ripple → carry-lookahead → prefix)
5. Widen / narrow internal buses
6. Remove redundant registers
7. Combine with clock gating strategy

---

## Static Timing Analysis (STA) Constraint Tuning

| Component | Mapping |
|-----------|---------|
| `train.py` | SDC constraints file (`constraints.sdc`) |
| `prepare.py` | Fixed STA script (OpenSTA / PrimeTime) + WNS/TNS extractor |
| Metric | `-wns_ps` (lower = better; negative WNS means violation) or composite with TNS |
| Budget | 2 minutes (STA is fast) |
| Agent mutates | `set_input_delay`, `set_output_delay`, `set_clock_uncertainty`, `set_max_transition`, clock groups |

### prepare.py sketch

```python
TIME_BUDGET = 120

def run():
    subprocess.run(["sta", "-exit", "run_sta.tcl"])  # run_sta.tcl reads train.sdc

def extract(stdout):
    wns = parse("wns", stdout)   # e.g., "wns -0.123"
    return -wns  # convert to lower-is-better
```

---

## Physical Design (Floorplan / Placement)

| Component | Mapping |
|-----------|---------|
| `train.py` | Floorplan config / DEF / Tcl script with placement directives |
| `prepare.py` | Fixed PnR flow (Innovus / ICC2) + DRC / wirelength / congestion extractor |
| Metric | Composite: `drc_count * 1000 + total_wirelength_um` (DRC is gate) |
| Budget | 30 minutes (full flow is slow) |
| Agent mutates | Aspect ratio, core utilization, placement density, macro placement, buffer insertion strategy |

### prepare.py sketch

```python
TIME_BUDGET = 1800

def run():
    subprocess.run(["innovus", "-no_gui", "-files", "run_pnr.tcl"])

def extract(stdout):
    drc = parse("Total DRC Violations:", stdout)
    wl = parse("Total Wirelength:", stdout)
    return drc * 1000 + wl
```

---

## Functional Verification (Coverage Maximization)

| Component | Mapping |
|-----------|---------|
| `train.py` | Testbench / UVM sequence / constraint randomization weights |
| `prepare.py` | Fixed compile + sim flow (VCS / Xcelium) + coverage reporter |
| Metric | `func_coverage_pct + toggle_coverage_pct * 0.5` (weighted composite) |
| Budget | 10 minutes (compile + regression run) |
| Agent mutates | Random constraint weights, directed test sequences, coverage targets, cross-coverage bins |

### prepare.py sketch

```python
TIME_BUDGET = 600

def run():
    subprocess.run(["vcs", "-f", "filelist.f", "-o", "simv"])
    subprocess.run(["./simv", "+UVM_VERBOSITY=LOW"])

def extract(stdout):
    func = parse("Functional Coverage:", stdout)
    toggle = parse("Toggle Coverage:", stdout)
    return func + toggle * 0.5
```

---

## Power Optimization (Leakage / Dynamic)

| Component | Mapping |
|-----------|---------|
| `train.py` | Clock gating strategy / power gating controller / DVFS policy module |
| `prepare.py` | Fixed power analysis flow (PrimeTime PX / Joules) + power extractor |
| Metric | `leakage_uW + dynamic_uW * activity_factor` |
| Budget | 15 minutes (power analysis needs SAIF/VCD) |
| Agent mutates | Clock gating granularity, retention cell selection, power domain partitioning |

---

## Formal Verification (Assertion Density)

| Component | Mapping |
|-----------|---------|
| `train.py` | Assertion set / property list (`assertions.sv`) |
| `prepare.py` | Fixed formal tool run (JasperGold / VC Formal) + proof / coverage extractor |
| Metric | `proved_properties / total_properties * 100` (prove rate %) |
| Budget | 20 minutes (formal can be slow) |
| Agent mutates | Add / remove / strengthen assertions, adjust proof bounds, split complex properties |

---

## DFT (Scan Chain / Test Coverage)

| Component | Mapping |
|-----------|---------|
| `train.py` | Scan insertion config / test point insertion script |
| `prepare.py` | Fixed DFT flow (Tessent / TestKompress) + fault coverage extractor |
| Metric | `stuck_at_fault_coverage_pct` |
| Budget | 15 minutes |
| Agent mutates | Scan chain count, test point locations, wrapper cell strategy |

---

## Generic Domain Adaptation Formula

For any new domain, fill this template:

```markdown
## [Domain Name]

| Component | Mapping |
|-----------|---------|
| `train.py` | [single file agent mutates] |
| `prepare.py` | [fixed harness that runs + measures] |
| Metric | [one number, deterministic, lower/higher = better] |
| Budget | [wall-clock time in seconds] |
| Agent mutates | [list of specific things the agent can change] |

### prepare.py sketch
```python
TIME_BUDGET = [N]
def run(): [subprocess or direct call]
def extract(output): [parsing logic]
```

### experiment ideas
1. [idea 1]
2. [idea 2]
3. [idea 3]
```

## Composite Metric Design

When a single metric is insufficient, compose one:

```python
def composite_metric(area, timing_slack, power):
    # Normalize each to ~0-1 range (based on domain knowledge)
    area_norm = area / 10000.0          # e.g., baseline area = 10k um2
    timing_penalty = max(0, -timing_slack) * 100  # heavy penalty for violation
    power_norm = power / 1000.0         # e.g., baseline power = 1mW
    
    return area_norm + timing_penalty + power_norm
```

Rules:
- **One scalar output** — never return a tuple
- **Monotonic with quality** — better design = lower (or higher) metric, always
- **Stable** — same design on same machine = same metric, ±1% noise max
- **Explainable** — the human can decompose the composite to understand tradeoffs

---

*This mapping is a starting point. For each domain, the human's job is to write `prepare.py` that faithfully measures the domain's "quality" in one number. That's the hard part. The loop handles the rest.*
