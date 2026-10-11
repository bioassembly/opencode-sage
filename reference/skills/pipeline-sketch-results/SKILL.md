---
name: pipeline-sketch-results
description: Consolidate and organize outputs from custom, multi-step sketch/bash/python pipelines into a clean, numbered, user-facing results/ deliverable directory while strictly withholding proprietary code and internal environments. Use ONLY when manually asked to publish, summarize, or package pipeline results into a client-facing deliverable folder.
---

# Pipeline Sketch Results (`pipeline-sketch-results`)

This skill standardizes the organization of outputs from custom, manually-crafted pipelines (bash scripts, python steps, sketch workflows without Nextflow) into a clean, professional, user-facing `results/` deliverable directory. It ensures that outputs are logically ordered, self-documenting, and free from internal execution clutter.

> **CRITICAL POLICY (TRADE SECRETS & INTELLECTUAL PROPERTY)**:
> Never copy internal execution scripts (`.py`, `.sh`, `command.sh`, `.nf`, Makefiles), environment definitions (`environment.yml`, `requirements.txt`), git tracking directories, or temporary scratch logs into the client-facing deliverable directory. Keep all code in their original step directories, and only copy data matrices, reports, cross-reference tables, and user documentation into `results/`.

---

## Deliverable Architecture (General Pattern)

Always structure the client-facing `results/` folder using sequentially numbered prefixes (`0_` to `N_`) reflecting the analytical progression from inputs to final synthesis:

```
results/
├── README.md                           # Master manifest, directory tree, and column dictionaries
├── 0_curated_inputs/                   # Filter lists, target panels, curated dictionaries, or metadata
├── 1_consolidated_master/              # Unified full-scale feature tables (raw + normalized)
├── 2_broad_profiles/                   # Broad category/sector/taxonomic level abundance matrices
├── 3_target_profiles/                  # Curated/targeted focus subsets (raw/ and normalized/)
├── 4_stratified_associations/          # Cross-linking features (e.g. taxon-to-function, sample mappings)
└── 5_ranked_candidates/                # Final synthesis, prioritized hits, or executive summary reports
```

*(Folder names and total count should adapt naturally to the specific pipeline's domains, keeping the sequential `0_` to `N_` numbering).*

---

## Runbook & Execution Steps

### Step 1: Discover & Map Upstream Outputs
Inspect the sketch pipeline's step directories (e.g. `phase*`, `step*`, `01_*`, `output/`):
1. Identify **user-facing deliverables** (final tables, summary statistics, figures, reports).
2. Identify **contextual metadata** needed by the user (curated input targets, reference lists).
3. Identify **proprietary code to withhold** (python logic, bash scripts, internal configs). Ensure these stay strictly in their source step directories and are NOT selected for copying.

### Step 2: Create the Numbered Deliverable Directory Tree
Create physical directories without symlinks:
```bash
mkdir -p results/{0_curated_inputs,1_master_tables,2_broad_profiles,3_target_profiles,4_stratified_associations,5_ranked_candidates}
```

### Step 3: Populate & Sanitize Outputs
1. **Raw vs. Normalized Separation**: Whenever quantitative features are presented (e.g., read counts, CPM, TPM, FPKM), provide clean `raw/` and `normalized/` subfolders or explicitly distinct file names (`raw_*.tsv` and `normalized_*.tsv`).
2. **Table Schema Sanitization**:
   - Strip redundant embedded strings (e.g., remove duplicate `[EC:...]` within definition fields if an explicit `EC` column is present).
   - Use clean, user-friendly column headers (avoid raw pipeline internal prefixes like `observed_`, `canonical_`, `tmp_`).
3. **Physical Copies Only**: Use `cp -r` or direct file generation for deliverable files. Never create symlinks inside `results/` so the folder can be packaged, zipped, or rsynced across systems without broken references.

### Step 4: Selective Ingestion & Isolation (No Code in Deliverables)
Ensure strict separation of concerns during copying:
- **Do copy**: `.tsv`, `.csv`, `.parquet`, `.html`, `.pdf`, `.png`, `.svg`, `.md` report manifests.
- **Do NOT copy**: Any executable scripts (`*.py`, `*.sh`, `*.nf`, `Makefile`, etc.) or environment manifests (`*.yml`, `requirements.txt`).
- **Safety check**: If an accidental copy occurred, inspect `results/` to confirm no executable scripts are present inside the `results/` deliverable folder:
  ```bash
  # Check for any accidental code files inside results/ only:
  find results/ -type f \( -name "*.py" -o -name "*.sh" -o -name "*.nf" -o -name "*.yml" -o -name "requirements.txt" \)
  ```

### Step 5: Portability & Integrity Verification
```bash
# 1. Assert zero symlinks inside results/
test $(find results/ -type l | wc -l) -eq 0 || echo "ERROR: Symlinks detected!"

# 2. Check for empty files
find results/ -type f -empty
```

### Step 6: Author Master `README.md` Deliverable Manifest
Every deliverable folder must include a top-level `README.md` containing:
- Project title, date, and brief description of the dataset and sample cohorts.
- Visual ASCII tree layout of the numbered directory structure.
- Detailed file descriptions and column dictionaries for all tabular deliverables.
- Guidance for client interpretation (e.g., which table to load for plotting, how normalization was calculated).
