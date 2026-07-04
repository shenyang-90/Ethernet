---
name: deep-research-cluster
description: >
  Multi-Agent Deep Research Cluster for comprehensive technical analysis, competitive intelligence,
  and protocol/architecture evaluation. Orchestrates 10+ parallel research agents, cross-verification,
  insight extraction, and structured report generation. Use when tasks require:
  - Multi-dimensional technical comparison or competitive analysis (3+ entities)
  - Protocol conformance analysis (PICS extraction, standard compliance)
  - Architecture deep-dive across multiple platforms/vendors
  - File-based research (PDF standards, datasheets) combined with external verification
  - Research requiring epistemic robustness: cross-verification, confidence tiers, conflict detection
  Trigger terms: deep analysis, protocol analysis, PICS, architecture comparison, competitive analysis,
  multi-vendor evaluation, conformance statement, standards analysis, research report.
---

# Deep Research Cluster

Orchestrate multi-agent parallel research: 10+ dimension agents, cross-verification engine, insight extraction, and structured report generation.

## Workflow Overview

```
User Query
  |
  v
Phase 0: Route Classification (A/B/D) → Select strategy
  |
  v
Phase 1: Landscape Scan (coarse-to-fine, 5 searches)
  |
  v
Phase 2: Dimension Decomposition (≥10 dimensions)
  |
  v
Phase 3: Parallel Deep Dive (≥10 agents × ≥20 searches each)
  |
  v
Phase 4: Cross-Verification (confidence tiers, conflict detection)
  |
  v
Phase 5: Targeted Validation (resolve conflicts, conditional)
  |
  v
Phase 6: Insight Extraction (cross-dimension patterns)
  |
  v
Phase 7: Structured Report Assembly
```

## Phase 0: Route Classification

| Route | Trigger | Strategy |
|-------|---------|----------|
| **A — Wide Search** | Broad/exploratory, no clear dimensions | Phase 1W: 5-8 wide agents → Phase 3: 10+ deep agents |
| **B — Focused Search** | Specific question, clear dimensions | Phase 1: Landscape → Phase 2: Decompose → Phase 3: Parallel deep dive |
| **D — File-Augmented** | User uploads files as reference | Phase F: File analysis → Phase 1: Targeted landscape → Phase 3: File+external research |

**Default**: Route B for most technical comparisons. Route D when user provides PDFs/datasheets.

## Phase 1: Landscape Scan

Perform 5 broad searches following coarse-to-fine progression:
- **Level 1 (Searches 1-2)**: Macro overview, industry reports
- **Level 2 (Searches 3-4)**: Structural mapping, major actors
- **Level 3 (Search 5)**: Emerging issues, conflicting narratives

After each search, record: key findings, dominant narratives, controversies, gaps.

## Phase 2: Dimension Decomposition

Decompose into ≥10 research dimensions. Each dimension must:
1. Cover current state with inline `[^N^]` citations
2. Include key evidence and data points
3. Address tensions and counter-arguments

Organize by: analytical angle, stakeholder viewpoint, geography, time horizon, or file-derived theme.

## Phase 3: Parallel Deep Dive

**Deploy ≥10 sub-agents simultaneously**, one per dimension. Each agent must:
- Perform ≥20 independent searches (no keyword recycling)
- Prioritize authoritative sources (datasheets, standards, official docs)
- Trace claims to original publications
- Identify and document counter-arguments
- Save output to `/mnt/agents/output/research/{topic}_dim{NN}.md`

**Agent creation**: Read `references/agent-templates.md` for the Research Agent system prompt template.

**Search budget**:
- Route A: ≥250 total searches
- Route B: ≥200 total searches
- Route D: ≥150 total searches

## Phase 4: Cross-Verification

Read all dimension files, classify findings into 4 tiers:

| Tier | Criteria | Action |
|------|----------|--------|
| **High Confidence** | ≥2 agents confirm from independent sources | Use as facts |
| **Medium Confidence** | 1 agent from authoritative source | Use with caveats |
| **Low Confidence** | Weak sourcing, single unverified claim | Flag for validation |
| **Conflict Zone** | Contradictions between agents | Phase 5 resolution |

Save results to `/mnt/agents/output/research/{topic}_cross_verification.md`.

## Phase 5: Targeted Validation (Conditional)

Execute only if Phase 4 found Conflict Zones or critical Low Confidence items.
- Deploy focused agents with specific conflicting claims
- Minimum 3 additional searches per conflict
- Update cross-verification file with resolutions

## Phase 6: Insight Extraction

Identify non-obvious insights from cross-dimension analysis. Each insight must:
- Derive from ≥2 dimensions (not repeat single-dimension findings)
- Be a higher-level inference (structural relationships, hidden tensions, emerging trends)
- Include: Insight statement, derived-from dimensions, rationale, implications, confidence

Save to `/mnt/agents/output/research/{topic}_insight.md`. Minimum 5 insights.

## Phase 7: Report Assembly

**Prerequisite**: All research artifacts exist:
- `{topic}_dim{NN}.md` — dimension files (≥10)
- `{topic}_cross_verification.md` — verification results
- `{topic}_insight.md` — cross-dimension insights

**Handoff to report-writing skill**:
1. Provide explicit file paths for all artifacts
2. State deep research is complete — no additional research needed
3. Ensure Phase 6 insights are incorporated into final report

## Output Rules

- All research files under `/mnt/agents/output/research/`
- Citations use `[^N^]` format
- Insights from Phase 6 must appear in final report
- Distinguish verified findings, conflict zones, and derived insights
- Search language: match user's query language

## Reference Files

| File | When to Read | Content |
|------|-------------|---------|
| `references/agent-templates.md` | Before Phase 3 | Research agent system prompt template, task prompt template |
| `references/routing-guide.md` | When Route ambiguous | Detailed route selection criteria and phase variants |
| `references/cross-verification.md` | Before Phase 4 | Verification framework, tier criteria, conflict resolution |
