---
name: fair-data-principles
description: Enforce and audit FAIR data principles (Findable, Accessible, Interoperable, Reusable) across scientific datasets, bioinformatics workflows, metadata dictionaries, and research repositories. Use when structuring datasets, authoring data schemas, releasing computational workflows, or auditing projects for scientific data stewardship.
---

# FAIR Data Principles

Core principle: Scientific data and computational pipelines must be first-class citizens — machine-actionable, uniquely identifiable, formally described with open ontologies, and fully reproducible. Every dataset earns a rich metadata schema; every entity earns a persistent identifier.

---

## What I do

- **Audit & Structure Datasets to FAIR Standards:** Findable (F1–F4), Accessible (A1–A2), Interoperable (I1–I3), and Reusable (R1.1–R1.3).
- **Author Machine-Readable Metadata Schemas:** Frictionless Data Package (`datapackage.json`), GSC MIxS environmental packages, and domain data dictionaries.
- **Enforce Biological & Scientific Ontologies:** GTDB taxonomy, KEGG Orthology, IUBMB Enzyme Commission (EC), Pfam protein domains, NCBI TaxIDs, and GO terms.
- **Ensure Computational Provenance:** Software environment locks (`environment.yml`, `requirements.txt`), deterministic POSIX execution scripts (`set -euo pipefail`), and formal scientific citations (`CITATIONS.md`).

---

## The 4 Pillars & Implementation Protocols

### 1. Findable (F) — Data & Metadata Can Be Discovered
* **F1. Globally Unique & Persistent Identifiers:**
  - Never rely on transient or system-dependent file paths as keys.
  - Implement deterministic, hierarchical naming schemes:
    - *Samples:* Standardized sample codes (e.g., `ST1`, `T1`).
    - *Contigs:* Sample-prefixed identifiers (e.g., `{Sample}_{ContigID}`).
    - *Genes / CDS:* Hierarchical compound keys (e.g., `{Sample}_{ContigID}_{CDS#}`).
    - *Genomes / MAGs:* Deterministic bin accessions (e.g., `{Sample}_bin.{ID}.fa`).
  - Prefix external ontology terms with their standard namespace (`KEGG:K00635`, `EC:2.3.1.20`, `Pfam:PF03007`).
* **F2. Rich Descriptive Metadata:**
  - Provide a dedicated sample metadata table (`metadata/samples_metadata.tsv`) specifying library layout, environmental ontology terms (ENVO/MIxS), sequencing platform, and sequencing yield.
* **F3. Metadata Explicitly Includes Identifiers:**
  - Every row in every tabular matrix must preserve the compound primary key (`sample`, `contig_id`, `query`, `bin_id`).
* **F4. Machine-Readable Registration:**
  - Provide a machine-readable schema (e.g. `metadata/datapackage.json` following the Frictionless Data standard) describing field types, formats, constraints, and descriptions.

---

### 2. Accessible (A) — Data & Metadata Can Be Retrieved
* **A1. Retrievable via Open, Standardized Protocols:**
  - All files, code, and configurations must be accessible via open, non-proprietary protocols (Git, HTTPS, standard POSIX CLI).
* **A1.1 / A1.2. Free & Transparent Access:**
  - Zero proprietary paywalls or closed binary dependencies required to read or process metadata and analysis tables.
* **A2. Independent Metadata Persistence:**
  - High-value metadata matrices, quality metrics, and schema definitions must persist directly in the repository, remaining accessible even if multi-gigabyte raw sequence files (BAM / FASTQ) are archived or moved to cold storage.

---

### 3. Interoperable (I) — Data Can Be Integrated with Other Workflows
* **I1. Formal, Shared, Open Language:**
  - Store tabular data in UTF-8 encoded Tab-Separated Values (`.tsv`) with standard UNIX line endings (`\n`). Avoid opaque binary formats (e.g., proprietary Excel sheets or unexported database dumps) for primary results.
* **I2. Standardized Community Ontologies:**
  - Integrate authoritative, versioned ontologies:
    - **Taxonomy:** Genome Taxonomy Database ([GTDB](https://gtdb.ecogenomic.org/)) 7-rank prefix format (`d__`, `p__`, `c__`, `o__`, `f__`, `g__`, `s__`).
    - **Enzymes:** IUBMB Enzyme Commission numbers (`EC:x.x.x.x`).
    - **Functional Orthology:** KEGG Orthology (`ko:Kxxxxx`), Modules (`Mxxxxx`), Pathways (`ko00061`).
    - **Protein Domains:** EMBL-EBI Pfam accessions (`PFxxxxx`).
    - **Functional Categories:** NCBI COG single-letter categories.
* **I3. Qualified Cross-References:**
  - Create traceable semantic linkages: physical coordinates $\rightarrow$ gene annotation $\rightarrow$ sequencing depth $\rightarrow$ MAG bin $\rightarrow$ taxonomic classification.

---

### 4. Reusable (R) — Data & Methods Can Be Replicated and Built Upon
* **R1. Rich Scientific Attributes:**
  - Provide comprehensive metrics (e.g., per-base mean depth, fractional pathway completeness, CheckM2 completeness and contamination, MIMAG draft quality tiers).
* **R1.1. Clear Open-Source License:**
  - The repository must include an explicit, permissive open-source license file (`LICENSE`), such as MIT or Apache-2.0 for code, and CC-BY 4.0 for data.
* **R1.2. Detailed Provenance & Reproducibility:**
  - Document all underlying tools, algorithm versions, and reference database dates in [`CITATIONS.md`](CITATIONS.md).
  - Provide locked environment specifications: Conda/Mamba [`environment.yml`](environment.yml) and Python [`requirements.txt`](requirements.txt).
  - Provide executable bash scripts (`command.sh`) with strict error flags (`set -euo pipefail`).
* **R1.3. Domain-Relevant Standards Compliance:**
  - **Genomics & MAGs:** Follow the **MIMAG standards** ([Bowers et al., 2017 *Nat. Biotechnol.*](https://doi.org/10.1038/nbt.3893)) for reporting High-Quality (HQ), Medium-Quality (MQ), and Low-Quality (LQ) MAGs.
  - **Environmental Sampling:** Follow the **GSC MIxS standards** (water, sediment, soil, host-associated packages).

---

## Bioinformatics & Metagenomics Overlay

1. **MIMAG Genome Quality Reporting:**
   - Always report `Completeness`, `Contamination`, `Heterogeneity`, and `Marker Lineage`.
   - Classify MAGs explicitly:
     - **HQ:** Completeness $\ge 90\%$, Contamination $< 5\%$.
     - **MQ:** Completeness $\ge 50\%$, Contamination $< 10\%$.
     - **LQ:** Completeness $< 50\%$ or Contamination $\ge 10\%$.
2. **Abundance Normalization & Verification:**
   - Clearly state depth units (raw per-base mean depth from `mosdepth`, TPM, or SCG copies-per-cell).
   - Enforce depth conservation assertions: $\sum \text{stratified depths} = \text{unstratified total depth}$.
3. **Compound Primary Keys:**
   - Metagenomic assemblies across multiple samples can duplicate contig IDs (e.g., `contig_1`). Always join tables on compound keys `(sample, contig_id)`.

---

## Anti-Patterns

- **Ad-hoc column names:** `col_1`, `val`, `res` without units or definitions.
- **Local absolute paths in primary keys:** Keys tied to a specific workstation directory.
- **Proprietary binary storage:** Trapping primary analytical tables in closed formats.
- **Unversioned taxonomy:** Free-text taxonomic names without GTDB or NCBI taxonomy version anchors.
- **Missing LICENSE file:** Leaving reuse rights ambiguous.
- **Unpinned software environments:** Omitting tool versions or relying on `@latest`.

---

## When to use me

- Structuring new bioinformatics or metagenomics project repositories.
- Preparing analytical tables and metadata for publication or public deposition.
- Creating machine-readable data dictionaries (`datapackage.json`).
- Auditing existing codebases and data packages for FAIR compliance.
