# Routing Guide

## Route Selection Decision Tree

```
User Query
  |
  +-- Files uploaded? --+-- "only based on files" → Route C (file-only)
  |                     +-- "refer to / combine" → Route D (file-augmented)
  |                     +-- no explicit restriction → Route D (default)
  |
  +-- No files? --+-- broad/exploratory → Route A (wide search)
                  +-- specific/clear dimensions → Route B (focused search)
                  +-- ambiguous → Route A (safer default)
```

## Route A — Wide Search

**When**: "Research industry X", "landscape of Y", "comprehensive comparison of A vs B vs C"

**Pipeline**:
1. Phase 1: Quick landscape (3-5 searches)
2. Phase 1W: Multi-agent wide exploration (5-8 agents, ≥10 searches each)
3. Phase 2: Decompose (informed by rich landscape)
4. Phase 3: Parallel deep dive (≥10 agents, ≥20 searches each)
5. Phase 4-7: Standard

**Total search budget**: ≥250 searches

## Route B — Focused Search

**When**: "Compare X and Y on dimension Z", "protocol analysis of P", "architecture of A"

**Pipeline**:
1. Phase 1: Full landscape scan (5 searches, coarse-to-fine)
2. Phase 2: Dimension decomposition
3. Phase 3: Parallel deep dive
4. Phase 4-7: Standard

**Total search budget**: ≥200 searches

## Route D — File-Augmented Research

**When**: User uploads PDFs, datasheets, standards, technical docs

**Pipeline**:
1. Phase F: File intake and deep analysis (per-file extraction, cross-file mapping)
2. Phase 1: Targeted landscape (guided by file gap analysis)
3. Phase 2: Decompose (merging file themes + external landscape)
4. Phase 3: Parallel deep dive (file context + external search)
5. Phase 4-7: Standard

**Total search budget**: ≥150 searches (reduced because files provide base evidence)

## Route C — File-Only Research

**When**: User explicitly says "only based on files", "no external search"

**Pipeline**:
1. Phase F: File intake and analysis
2. Phase 2: Decompose from file themes
3. Phase 3: Multi-agent file deep dive (NO external search)
4. Phase 4: Cross-verify across file analyses
5. Phase 6-7: Standard

**Total search budget**: 0 external searches

## Dimension Decomposition Strategies

### By Analytical Angle
- Technical architecture
- Performance benchmarks
- Security features
- Cost/BOM analysis
- Ecosystem/toolchain
- Regulatory compliance

### By Stakeholder
- Hardware designer
- Software developer
- System integrator
- Safety/security engineer
- Procurement

### By File Theme (Route D)
Map each major file theme to one or more dimensions. Reference specific file sections in dimension scope.

### Overlap Rule
≥30% conceptual overlap between related dimensions for cross-verification pressure.
