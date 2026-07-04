---
# Experiment Loop Protocol

The full autonomous loop that the agent executes after setup. This is the "constitution" that goes into `program.md`.

## Phase 0: Setup (Once)

1. **Agree on a run tag** with the user: e.g., `may14-rtl-area`. Branch `autoresearch/may14-rtl-area` must not exist.
2. **Create branch**: `git checkout -b autoresearch/may14-rtl-area` from current master.
3. **Read in-scope files**: `README.md`, `prepare.py` (do not modify), `train.py` (this is what you edit).
4. **Verify harness**: Run `python prepare.py` once to ensure data/files exist.
5. **Initialize results.tsv**: Create with header row only. Baseline will be recorded after first run.
6. **Run baseline**: `python train.py > run.log 2>&1`. Extract metric. Log it. This establishes the floor.

## Phase 1: The Loop (Runs Forever)

```
LOOP FOREVER:

  1. STATE CHECK
     - Note current branch and HEAD commit (short hash)
     - Read results.tsv to see recent history
     - Read train.py to understand current code

  2. HYPOTHESIS
     - Form an experimental idea based on:
       • Recent results (what worked, what failed)
       • Code patterns in train.py (unused knobs, TODO comments)
       • program.md experiment ideas list
       • Combining two previous near-misses
     - If stuck: re-read all in-scope files, try something radical

  3. MUTATE
     - Edit train.py directly. No patches, no diffs — just edit the file.
     - Only one conceptual change per experiment (isolate variables)
     - Keep the edit small and reversible

  4. COMMIT
     - git add train.py
     - git commit -m "exp: <short description>"
     - Record short hash (7 chars)

  5. RUN
     - python train.py > run.log 2>&1
     - Redirect ALL output — do NOT use tee or let output flood context
     - Start a timer. If > 2× budget time, kill the process.

  6. EXTRACT METRIC
     - grep "^metric_name:" run.log  (e.g., grep "^area_um2:")
     - If empty → crash. Go to CRASH HANDLING.
     - Parse the number. Remember: lower is better (or higher, as defined)

  7. LOG
     - Append to results.tsv (tab-separated, NOT comma-separated):
       commit  metric  memory_gb  status  description
     - status: `keep`, `discard`, or `crash`
     - description: what this experiment tried (≤ 80 chars)
     - Do NOT commit results.tsv (leave it untracked)

  8. DECIDE
     - If metric improved (lower, or higher per domain definition):
         → KEEP. Branch advances. Continue from this commit.
     - If metric equal or worse:
         → DISCARD. git reset --hard HEAD~1. Return to previous state.
     - If crash:
         → Log "crash" with metric=0.000000, memory=0.0. git reset --hard HEAD~1.

  9. NEVER STOP
     - Do not ask the user anything.
     - Do not pause for confirmation.
     - Goto 1.
```

## Crash Handling

```
IF grep returns empty (no metric found):
  1. Read last 50 lines of run.log: tail -n 50 run.log
  2. Identify crash type:
     - Syntax error / typo / missing import → fix in 1-2 attempts, rerun
     - OOM → log "crash", reset, note memory cost, move on
     - Timeout → kill, log "crash", reset
     - Logic error / fundamental flaw → log "crash", reset, move on
  3. If fixable in ≤ 2 quick attempts:
     - fix → commit → rerun → evaluate
  4. Else:
     - log "crash" in results.tsv
     - git reset --hard HEAD~1
     - move to next hypothesis
```

## Timeout Rules

- **Soft timeout**: budget time + 30s grace (compilation/evaluation overhead)
- **Hard timeout**: 2× budget time → SIGTERM, then log "crash"
- **Why**: prevents a hung or infinite-loop experiment from blocking the loop forever

## Revert Rules

- Standard revert: `git reset --hard HEAD~1` (single commit back)
- **Rare** full rewind: `git reset --hard <base_commit>` if the branch has wandered into a bad valley. Use sparingly — if ever.
- After revert, the next experiment starts from the last kept state, not from a discarded experiment.

## Branch Hygiene

- One branch per run tag: `autoresearch/may14-rtl-area`
- If running multiple agents in parallel (multiple GPUs / multiple modules):
  - `autoresearch/may14-rtl-area-gpu0`
  - `autoresearch/may14-rtl-area-gpu1`
- Never merge autoresearch branches into master manually. The human reviews and cherry-picks.

## Output Format (run.log)

The harness in `prepare.py` should print a summary block at the end:

```
---
metric_name: 0.997900
training_seconds: 300.1
total_seconds: 325.9
peak_vram_mb: 45060.2
mfu_percent: 39.80
num_steps: 953
```

Only `metric_name:` is required. Everything else is optional but helpful for post-analysis.

## Experiment Ideas List (for program.md)

Include a seed list of ideas in `program.md` so the agent never runs out:

```markdown
## Experiment Ideas (try in rough order)

1. Baseline run (always first)
2. Double / halve a primary hyperparameter (LR, width, depth)
3. Change activation function
4. Add/remove regularization
5. Change optimizer or optimizer hyperparams
6. Architectural tweak (attention pattern, skip connections, etc.)
7. Data / preprocessing tweak
8. Combine two previous near-misses (e.g., idea 3 + idea 5)
9. Radical change: throw out half the code, see what happens
10. Simplification hunt: delete something, see if metric stays the same
```

## The Simplicity Criterion (in program.md)

```markdown
## Simplicity Criterion

All else being equal, simpler is better.

- A small improvement that adds ugly complexity → probably discard
- A small improvement from deleting code → definitely keep
- An improvement of ~0 but much simpler → keep
- A big improvement, ugly but contained → keep with note

When in doubt, prefer the version with fewer lines and fewer special cases.
```

---

*This protocol is the agent's operating manual. Write it into `program.md`, point the agent at it, and let it run.*
