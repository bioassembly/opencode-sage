---
name: statistical-data-visualization
description: Verify statistical data visualization correctness, bias detection, interpretability for bioinformatics reports
---

## What I do
- Audit data visualizations for statistical correctness (no misleading scales, proper % calculations)
- Detect selection bias in top-N chart choices (e.g., top-20 cherry-picking)
- Verify heatmap color scales are appropriate for the data distribution
- Check that mid_point thresholds don't artificially inflate/deflate visual impact
- Cross-check % calculations: denominator must match the question being asked
- Verify that excluded data (null, "-", empty) is documented, not hidden
- Ensure tooltips contain sufficient context (raw counts alongside percentages)
- Check that chart dimensions don't distort perception (aspect ratio, truncation)
- Verify that aggregation methods (sum, mean, max, nunique) match the biological question

## Patterns
### Percentage Calculation Audit
- **Per-sample %**: count / total_for_that_sample * 100 — use when comparing relative importance within a sample
- **Overall %**: count / grand_total * 100 — use when showing absolute contribution
- **Never**: count / len(all_rows) * 100 when each row can belong to multiple categories (double-counting)
- **Always show raw counts in tooltips** — percentages without N are meaningless

### Top-N Selection Bias Detection
- **Top-20 bar chart**: always show the "long tail" context — what's the 21st value? What % of total does top-20 represent?
- **Top-4 filtering**: justify why 4, not 5 or 10. Show remaining categories in a separate table or note.
- **Always report**: "Top 20 of 377 pathways represent X% of total assignments"

### Heatmap Color Scale Verification
- **Diverging scales** (mid_point): only use when data has a natural midpoint (e.g., fold-change). For coverage/counts, use sequential.
- **Sequential scales** (blues, viridis): use for counts, percentages, coverage — no midpoint
- **Mid_point = max/2**: this is a heuristic, not statistically meaningful. Document it as such.
- **Text coloring at mid_point**: white text on dark blue, black on light blue — ensures readability

### Exclusion Documentation
- **Never silently exclude**: if you filter out "-", "Unknown", or null values, document WHY
- **Null/empty values**: keep in tables, exclude from heatmaps only (no label to map)
- **Filtering rationale**: "Excluded '-' (no pathway assigned) as it represents technical absence, not biological signal"

### Chart Interpretability Checklist
1. **Tooltip**: contains raw count (N), not just percentage
2. **Axis labels**: clear units (bp, %, genes, coverage)
3. **Title**: describes what's shown, not just "Chart 1"
4. **Legend**: color mapping is unambiguous
5. **Scale**: y-axis starts at 0 for bar charts (unless justified)
6. **Sorting**: descending by meaningful metric, not alphabetical
7. **Sample size**: N stated somewhere (in title, caption, or tooltip)

### Bioinformatics-Specific Checks
- **COG categories**: % of proteins assigned to each category — denominator = total proteins per sample
- **KEGG pathways**: % of pathway assignments — denominator = total pathway assignments per sample (NOT total proteins)
- **Heatmap coverage**: sum of coverage per sample×taxon — not average (sum preserves total signal)
- **MAG quality**: completeness ≥ 90% = HQ, ≥ 50% = MQ — verify thresholds match MIMAG standards
- **GTDB taxonomy**: species = empty means genus-level only (ANI below species threshold)

## When to use me
- Before presenting any statistical chart in a report
- After modifying % calculations or data filtering logic
- When a chart shows "top-N" selection (bar chart, heatmap)
- When using heatmaps with mid_point coloring
- When excluding or filtering data (null, "-", empty)
- Before finalizing any visualization chapter
- When stakeholders question the numbers shown in charts
