---
# Core Principles — The 7 Non-Negotiable Rules

These are the design choices that make autoresearch work. Violate any one and the loop collapses.

## 1. Single File to Modify

The agent touches **exactly one file** (`train.py`). Everything else is read-only.

- Keeps diffs reviewable
- Prevents scope creep
- Makes `git reset --hard HEAD~1` a safe, atomic revert
- If the agent needs to change two files, split into two separate autoresearch instances

## 2. Fixed Time Budget

Every experiment runs for the **same wall-clock time**, regardless of what changed.

- Makes experiments directly comparable (small model vs large model, same budget)
- Prevents the agent from "cheating" by training longer
- In ML: 5 minutes. In RTL synthesis: 10 minutes (synth + report). In STA: 2 minutes.
- The budget is a human-defined constant in `prepare.py`, never modified by the agent

## 3. Single Hard Metric

One number decides keep vs discard. Not two. Not "it looks better." One number.

- Lower-is-better: `val_bpb`, `area_um2`, `power_mW`, `drc_count`
- Higher-is-better: `coverage_pct`, `wns_ps`, `win_rate`
- The metric must be deterministic (same input → same number, within noise tolerance)
- Print it on a line starting with the metric name: `val_bpb: 0.9979` so `grep` can extract it

## 4. Simplicity Criterion

All else equal, simpler is better.

| Scenario | Verdict |
|----------|---------|
| +0.001 improvement, +20 lines of hacky code | Discard |
| +0.001 improvement, deleted 20 lines | Keep |
| ~0 improvement, much simpler code | Keep |
| Big improvement, ugly but contained | Keep (with note) |

The agent must weigh complexity cost against improvement magnitude. This prevents the codebase from rotting into a pile of micro-optimizations.

## 5. Git as State Machine

Git is not just version control — it **is** the experiment state machine.

- `git commit` → experiment registered
- Metric improved → branch advances (commit stays)
- Metric worse → `git reset --hard HEAD~1` (clean revert)
- Crash → log "crash", reset, move on
- Branch name: `autoresearch/<tag>` or `autoresearch/<tag>-gpu<N>`

No external database needed. Git log + results.tsv is the full experiment ledger.

## 6. Crash Tolerance

The loop must survive crashes without human intervention.

- Timeout: >2× budget time → kill, log "crash", reset
- OOM: catch exception, log "crash", reset
- Syntax error: if trivial fix in 1-2 attempts, fix and rerun; else log "crash", move on
- Never pause to ask the human. The human is not there.

## 7. NEVER STOP

Once the loop begins, the agent does not pause.

- Do not ask "should I continue?"
- Do not ask "is this a good stopping point?"
- Do not ask "what should I try next?"
- If out of ideas: re-read `train.py` and `program.md`, combine previous near-misses, try radical changes, read referenced papers
- The loop runs until manually interrupted. Period.

> The user might leave you running while they sleep. If each experiment takes ~5 minutes, that's ~12/hour, ~100 over a sleep cycle. The user wakes up to a log of experiments and (hopefully) a better result.

---

*These 7 rules are the distilled essence of Karpathy's original design. Forks and domain adaptations should not violate them — they should only translate the "how" (what the metric is, what the file is, what the harness does).*
