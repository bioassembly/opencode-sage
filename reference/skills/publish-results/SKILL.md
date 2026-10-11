---
name: publish-results
description: Consolidate and organize pipeline execution outputs into a clean, numbered, user-facing results/ deliverable directory while strictly withholding proprietary code and internal environments. Use when asked to summarize or publish pipeline results, create a clean deliverable folder, or structure Nextflow-style publishDir outputs.
---

# Publish Pipeline Results (`publish-results`)

This skill standardizes the organization of scientific and data pipeline outputs into a clean, user-facing `results/` deliverable directory, adhering to FAIR principles and Nextflow-style `publishDir` conventions.

> **CRITICAL POLICY (TRADE SECRETS & INTELLECTUAL PROPERTY)**:
> Never copy internal execution scripts (`.py`, `.sh`, `command.sh`, `nextflow.config`, `.nf`), conda/pip environment manifests (`environment.yml`, `requirements.txt`), or intermediate scratch caches into the user-facing deliverable directory. Only publish clean, sanitized data matrices, reports, cross-reference tables, and user manifests.

---

## Standard Deliverable Architecture

Structure the destination `results/` folder using numbered prefixes (`0_` to `N_`) to provide clear sequential navigation:

```
results/
├── README.md                           # Comprehensive manifest, column dictionary, and user guide
├── 0_curated_targets/                  # Curated target panels, reference mappings & expansions
│   └── curated_target_ko_expansion.tsv # Clean cross-reference tables (no redundant columns or prefixes)
├── 1_master_tables/                    # Consolidated master tables (e.g. raw and normalized CPM)
│   ├── raw_master_table.tsv
│   └── normalized_CPM_master_table.tsv
├── 2_category_profiles/                # Broad category/sector level tables (e.g., COG_C, COG_G, etc.)
│   ├── <CATEGORY_A>/ (raw/ and normalized/)
│   └── <CATEGORY_B>/ (raw/ and normalized/)
├── 3_target_profiles/                  # Curated target metabolic profiles
│   ├── raw/                            # Raw count/depth wide abundance matrices
│   └── normalized/                     # Normalized (CPM/TPM) wide abundance matrices
├── 4_taxonomic_linkage/                # Contig/MAG linkage & taxon-stratified abundance tables
│   ├── mag_mapping/                    # Contig-to-genome mappings
│   └── stratified_abundance/           # Rank-deconvoluted profiles (Phylum down to Species)
└── 5_candidate_bins/                   # Filtered & ranked top candidate genomes/strains
    ├── candidate_bins_screening.tsv    # Quantitative multi-criteria ranking matrix
    └── candidate_summary_report.md     # Executive summary report
```

---

## Execution Protocol

### Step 1: Create the Directory Tree
Create all target directories without using symlinks:
```bash
mkdir -p results/{0_curated_targets,1_master_tables,2_category_profiles,3_target_profiles,4_taxonomic_linkage,5_candidate_bins}
```

### Step 2: Populate Deliverables
Copy outputs from upstream analysis phases:
1. **Target Panels & Mapping (`0_curated_targets/`)**:
   - Provide curated target definitions, gene symbols, EC numbers, and pathway associations.
   - Clean column names: avoid redundant prefix tokens (e.g., use `definition`, `genes`, `EC`, `pathways` instead of `canonical_...` or `observed_...`).
   - Strip duplicate text (e.g., remove `[EC:...]` inside definition strings if an explicit `EC` column exists).
2. **Master Datasets (`1_master_tables/`)**:
   - Deliver both raw quantification (e.g., read count or mean depth) and normalized metrics (e.g., CPM).
3. **Stratified Abundance & Targets (`2_` & `3_`)**:
   - Ensure clean `raw/` and `normalized/` subfolder separation.
4. **Taxonomy & Candidate Genomes (`4_` & `5_`)**:
   - Include genome quality rankings (CheckM/CheckM2 completeness, contamination) alongside functional repertoire metrics.

### Step 3: Sanitize Intellectual Property & Trade Secrets
Verify that no proprietary code slipped into `results/`:
```bash
find results/ -type f \( -name "*.py" -o -name "*.sh" -o -name "*.nf" -o -name "*.yml" -o -name "*.yaml" -o -name "requirements.txt" \) -delete
```

### Step 4: Verify Zero Symlinks & File Integrity
Ensure full portability across filesystems:
```bash
# Verify no symlinks exist
find results/ -type l

# Validate non-empty deliverable files
find results/ -type f -empty
```

### Step 5: Write `README.md` Deliverable Manifest
Every `results/` folder must include a top-level `README.md` containing:
- High-level project summary and sample cohort definitions.
- Visual ASCII tree layout of the numbered directory structure.
- Column dictionaries for complex matrices and summary tables.
- Clear guidance on how to interpret key target profiles (e.g., normalized CPM tables, taxonomic origins, candidate strains).
