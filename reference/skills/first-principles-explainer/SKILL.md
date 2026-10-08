---
name: first-principles-explainer
description: Break down complex bioinformatics, data engineering, and algorithmic pipelines from first principles. Use when explaining discrepancies, debugging multi-stage workflows, or when the user asks for clear, accessible conceptual clarity.
---

# First-Principles Explainer

Explain complex computational biology and multi-stage pipeline concepts by anchoring in fundamentals rather than internal pipeline jargon.

## Core Rules

1. **Start with the User's Real Goal**:
   - Strip away script names, flag arguments, and intermediate table names in the opening.
   - Anchor in the physical or biological reality: What is the biological question? What input files did the user supply? What is the expected biological output?

2. **Contrast Mental Model vs Machine Reality**:
   - State clearly what the user expected to happen.
   - Contrast with what the data/algorithm actually did.
   - Use concrete 1-to-1 examples (e.g. showing a specific gene like `accD` and its multi-valued KO cell `ko:K01962,ko:K01963`).

3. **Explain the Root Cause of Discrepancies**:
   - Don't just report numbers (e.g. "9 genes vs 156 genes").
   - Explain *why* they differ:
     - Biological reasons (e.g. prokaryotic operons vs eukaryotic nomenclature, isozymes, domain fusions).
     - Database annotations (e.g. eggNOG assigned KO A instead of KO B).
     - Algorithmic heuristics (e.g. first-only selection vs mention-any).

4. **Structured Four-Part Delivery**:
   - **Entity Definition**: What each input/target represents.
   - **Direct Answer to the Question**: Clear, unambiguous answer upfront (e.g. "No, they do not overlap completely").
   - **Concrete Breakdown with Examples**: Specific rows, values, and why edge cases occurred.
   - **The Actionable Next Step**: Clear path forward without code clutter.
