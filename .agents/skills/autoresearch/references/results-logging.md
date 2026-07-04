---
# Results Logging — TSV + Git Branch Management

The experiment ledger is two things: a `results.tsv` file and Git history. Together they provide full traceability.

## TSV Format

Tab-separated, NOT comma-separated. Commas break in descriptions.

### Header

```
commit	metric	memory_gb	status	description
```

### Columns

| Column | Type | Description |
|--------|------|-------------|
| `commit` | string (7 chars) | Short git hash of the experiment commit |
| `metric` | float (6 dp) | The metric value. 0.000000 for crashes |
| `memory_gb` | float (1 dp) | Peak memory in GB. 0.0 for crashes |
| `status` | string | `keep` / `discard` / `crash` |
| `description` | string | Short text (≤ 80 chars) describing the change |

### Example rows

```
commit	metric	memory_gb	status	description
a1b2c3d	0.997900	44.0	keep	baseline
d4e5f6g	0.993200	44.2	keep	increase LR to 0.04
e5f6g7h	1.005000	44.0	discard	switch to GeLU activation
f6g7h8i	0.000000	0.0	crash	double model width (OOM)
g7h8i9j	0.992500	44.1	keep	GeLU + doubled LR (combo)
```

## Logging Rules

1. **Append only** — Never overwrite rows. Each experiment adds one line.
2. **Untracked by git** — `results.tsv` is in `.gitignore`. It is experiment metadata, not code.
3. **One row per experiment** — Even crashes get a row.
4. **Description format** — Keep it short. Use symbols for common ops:
   - `↑ LR 0.04` = increased learning rate
   - `↓ depth 4→6` = changed depth from 4 to 6
   - `+ dropout 0.1` = added dropout
   - `- bias term` = removed bias
   - `combo: X + Y` = combined two previous ideas

## Git Branch Conventions

### Naming

```
autoresearch/<tag>
autoresearch/<tag>-<resource>
```

Examples:
- `autoresearch/may14-rtl-area`
- `autoresearch/may14-rtl-area-gpu0`
- `autoresearch/jun1-macc-v2`

### Branch Lifecycle

```
master
  └── autoresearch/may14-rtl-area  (created from master)
        ├── a1b2c3d  baseline (keep)
        ├── d4e5f6g  ↑LR (keep)
        ├── e5f6g7h  GeLU (discard → reset)
        ├── d4e5f6g  [back to last keep]
        └── g7h8i9j  combo (keep)
```

- **Discard**: `git reset --hard HEAD~1` — rewinds to last keep
- **Keep**: branch advances, next experiment builds on this commit
- **Crash**: same as discard, but log "crash"

### Never Merge Automatically

Autoresearch branches are experiment sandboxes. The human reviews the best commit and cherry-picks into master. Do not `git merge`.

## Morning-After Analysis

After an overnight run, the human (or agent) analyzes results:

### 1. Best Commit

```bash
# Find best metric (lower = better)
sort -t$'\t' -k2 -n results.tsv | head -5

# Or higher = better
sort -t$'\t' -k2 -nr results.tsv | head -5
```

### 2. Progress Chart

Generate a simple PNG with matplotlib:

```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("results.tsv", sep="\t")
kept = df[df.status == "keep"].reset_index(drop=True)

plt.figure(figsize=(10, 4))
plt.plot(kept.index, kept.metric, marker="o")
plt.xlabel("Keep Count")
plt.ylabel("Metric (lower = better)")
plt.title("Autoresearch Progress")
plt.savefig("progress.png")
```

### 3. What Worked / What Didn't

```bash
# All keeps
awk -F'\t' '$4=="keep" {print}' results.tsv

# All crashes
awk -F'\t' '$4=="crash" {print}' results.tsv

# Trend: improvement per experiment
grep "keep" results.tsv | awk -F'\t' '{print NR, $2}'
```

### 4. Cherry-Pick the Winner

```bash
# Find best keep commit
BEST=$(awk -F'\t' '$4=="keep" {print $1, $2}' results.tsv | sort -k2 -n | head -1 | awk '{print $1}')

# Cherry-pick to master
git checkout master
git cherry-pick $BEST
```

## Log File Hygiene

### `run.log`

- One per experiment, overwritten each cycle
- Full stdout + stderr of `python train.py`
- Kept for crash debugging, not committed

### `logs/` directory (optional)

For long runs, archive per-experiment logs:

```bash
mkdir -p logs
cp run.log logs/<commit>.log
```

### `.gitignore`

```
results.tsv
run.log
logs/
*.png
__pycache__/
```

## Summary Statistics

After a run, report:

```
Total experiments: 100
Keeps: 23
Discards: 71
Crashes: 6
Best metric: 0.9925 (commit g7h8i9j)
Baseline: 0.9979
Improvement: -0.54%
```

---

*The TSV is the experiment ledger. Git is the state machine. Together they make the loop auditable and reproducible.*
