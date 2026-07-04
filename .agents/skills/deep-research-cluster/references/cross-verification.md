# Cross-Verification Framework

## Confidence Tier Classification

| Tier | Criteria | Presentation in Report |
|------|----------|----------------------|
| **High Confidence** | ≥2 agents confirm from independent sources with consistent evidence | State as facts, no qualification |
| **Medium Confidence** | 1 agent from authoritative source (datasheet, official doc) | State with source attribution |
| **Low Confidence** | Weak sourcing, blog-level, single unverified claim | Flag with caveat or omit |
| **Conflict Zone** | Contradictions between agents, numerical discrepancies, temporal inconsistencies | Present both sides with analysis |

## Conflict Zone Resolution

### Step 1: Identify Conflicts
- Statistical disagreement (different numbers for same metric)
- Interpretive divergence (different conclusions from same data)
- Temporal inconsistency (data from different time periods)
- Specification contradictions (different claims about same product)

### Step 2: Classify Conflict Type
- **Resolvable**: New evidence can determine which claim is correct
- **Partially Resolvable**: One claim can be refined but not fully resolved
- **Genuine Disagreement**: Both claims are valid from different perspectives

### Step 3: Deploy Validation Agent (Phase 5)
For each unresolved Conflict Zone:
- Provide specific conflicting claims and their sources
- Minimum 3 additional targeted searches
- Attempt to find independent evidence resolving the disagreement

### Step 4: Update Classification
- **Resolved**: Reclassify to High/Medium Confidence with new evidence
- **Unresolved**: Document as genuine disagreement in the field
- **Partially Resolved**: State refined claim with remaining uncertainty

## Temporal Consistency Check

Always check: Are agents reporting data from different time periods for the same metric? If so, flag as temporal inconsistency and record which time period each data point belongs to.

## File Naming Convention

| File | Content |
|------|---------|
| `{topic}_dim{NN}.md` | Per-dimension research output |
| `{topic}_cross_verification.md` | Confidence tiers + conflict analysis |
| `{topic}_insight.md` | Cross-dimension insights |
| `{topic}_file_analysis.md` | Route D: file intake analysis |

## Insight Extraction Criteria

An insight must:
1. Derive from ≥2 dimensions (cross-dimension pattern)
2. Not repeat any single-dimension finding
3. Be a higher-level inference (structural relationship, hidden tension, emerging trend)
4. Be supported indirectly by evidence from ≥2 dimensions
5. Include `[^N^]` citations to supporting evidence

Insight format:
```markdown
- **Insight**: [concise statement]
- **Derived From**: [dimension references]
- **Rationale**: [how insight emerges from evidence]
- **Implications**: [potential impact]
- **Confidence**: [high/medium/exploratory]
```

Minimum 5 insights per research cycle.
