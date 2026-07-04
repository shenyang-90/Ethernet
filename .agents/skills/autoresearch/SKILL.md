---
name: autoresearch
description: Autonomous experiment-and-iterate skill based on Karpathy's autoresearch pattern. Use when the user wants to (1) set up a self-running optimization loop where an AI agent modifies a single target file, measures a hard metric, and keeps or discards the change, (2) create a prepare.py / train.py / program.md triad for any domain, (3) run overnight autonomous experiments on RTL, EDA, verification, or any code/parameter space, (4) bootstrap a "never stop" agent that commits, runs, evaluates, and reverts in a loop. Triggers on: "autoresearch", "自主实验", "自动优化", "overnight experiment", "self-running loop", "让agent自己跑实验".
---

# autoresearch

Karpathy's autoresearch distilled into a reusable, domain-agnostic skill.

## Core Idea (One Sentence)

**Modify one file. Run. Measure one number. Keep or revert. Repeat forever.**

## When to Use This Skill

- You have a single file (RTL, script, config) that an agent can mutate.
- You have a fixed evaluation harness that returns a hard metric (area, timing, coverage, loss, etc.).
- You want the agent to run unattended — overnight, during a meeting, while you sleep.
- You want Git to act as the state machine: advance on win, reset on loss.

## The Triad

Every autoresearch instance is exactly three files:

| File | Role | Who Writes | Who Edits | Immutable? |
|------|------|-----------|-----------|------------|
| `prepare.py` | Harness + Metric | Human (once) | **Never** | ✅ Yes |
| `train.py` | Experiment Target | Human (seed) | **AI Agent only** | ❌ No |
| `program.md` | Agent Constitution | Human (iterates) | Human only | N/A |

> **Rule of thumb**: If the agent needs to touch more than one file, the scope is too broad. Narrow it.

## Workflow

### Phase 1: Bootstrap (Human)

1. **Pick a target** — What single file will the agent mutate? (`train.py` equivalent)
2. **Pick a metric** — What single number decides keep vs discard? Lower = better or higher = better, pick one.
3. **Write `prepare.py`** — Fixed harness that runs the experiment and prints the metric. See [references/benchmark-harness.md](references/benchmark-harness.md).
4. **Write a seed `train.py`** — Baseline implementation that compiles / runs / passes.
5. **Write `program.md`** — Agent instructions: loop rules, what can/cannot change, timeout, simplicity criterion, logging format. See [references/experiment-loop.md](references/experiment-loop.md).
6. **Run baseline** — `python prepare.py` + `python train.py`. Verify metric prints cleanly.
7. **Initialize results.tsv** — Header only: `commit\tmetric\tmemory_gb\tstatus\tdescription`

### Phase 2: Autonomous Loop (Agent)

Once kicked off, the agent enters the loop and does NOT ask for permission:

```
1. Read current git state (branch, HEAD)
2. Read train.py + program.md for context
3. Form a hypothesis; mutate train.py directly
4. git commit
5. Run experiment: python train.py > run.log 2>&1
6. Parse metric from run.log
7. Log to results.tsv (commit, metric, status, description)
8. Metric improved? → keep (branch advances)
   Metric worse?   → git reset --hard HEAD~1
   Crash?          → log "crash", reset, move on
9. Goto 1. NEVER STOP.
```

> **The human may be asleep.** The agent does not pause, does not ask "should I continue?", and does not wait for confirmation. It runs until manually interrupted.

## Skill Resources

Load these references as needed during execution:

- **[references/core-principles.md](references/core-principles.md)** — The 7 non-negotiable design rules (single file, fixed budget, hard metric, simplicity, git state machine, never stop, crash tolerance).
- **[references/experiment-loop.md](references/experiment-loop.md)** — Full agent loop protocol with pseudocode, timeout handling, crash recovery, and branch management.
- **[references/benchmark-harness.md](references/benchmark-harness.md)** — How to write a robust `prepare.py`: metric isolation, deterministic seeds, time boxing, memory tracking.
- **[references/results-logging.md](references/results-logging.md)** — TSV schema, Git branch naming conventions, morning-after analysis.
- **[references/domain-mapping.md](references/domain-mapping.md)** — Metric mappings for RTL synthesis, STA, physical design, verification, and other chip-design domains.

## Quick-Start Checklist

Before handing control to the agent, verify:

- [ ] `prepare.py` runs standalone and prints a single number metric
- [ ] `train.py` baseline runs without crashing and produces a metric
- [ ] Git repo initialized; agent will create a dedicated branch
- [ ] `program.md` written; agent has read it
- [ ] `results.tsv` header created (untracked by git)
- [ ] Timeout and kill strategy defined (e.g., >10 min → SIGTERM)
- [ ] Simplicity criterion stated in program.md

## Common Anti-Patterns

| Anti-Pattern | Why It Kills the Loop |
|--------------|----------------------|
| Agent edits multiple files | Diff explosion; no clean rollback |
| Metric is "vibes" or subjective | Agent cannot decide keep/discard |
| No time budget | Experiments become incomparable |
| No baseline run | Cannot measure improvement |
| Agent asks human mid-loop | Breaks unattended execution |
| Complex revert logic | Git reset --hard HEAD~1 is enough |

## Example Invocation

User: *"对 mac_core.v 做 autoresearch，目标是面积最小化。"*

Skill triggers → reads [references/domain-mapping.md](references/domain-mapping.md) → picks metric `area_um2` → writes `prepare.py` (Yosys synth script) → seeds `train.py` (mac_core.v baseline) → writes `program.md` → kicks off loop.
