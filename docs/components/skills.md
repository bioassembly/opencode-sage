# Agent Skills

Skills are modular, on-demand procedure guides that instruct the agent on how to execute specialized multi-step workflows. They are loaded dynamically when relevant, protecting the context window from token bloat.

All skills live in [`reference/skills/`](../../reference/skills/) and are installed into `~/.config/opencode/skills/` via `scripts/activate.sh`.

## Catalog (20 Skills)

### 1. Core Software Engineering & Discipline
- **`agentic-coding`**: Working agreements for coding loops: plan-then-edit, minimal diffs, verify each step.
- **`test-driven-development`** *(superpowers, 296k ⭐)*: The iron law of TDD: no production code without a failing test first. Kills premature completions.
- **`systematic-debugging`** *(superpowers)*: 4-phase root-cause loop (reproduce → hypothesize → test minimally → fix cause). Max 3 attempts before escalating.
- **`verification-before-completion`** *(superpowers)*: Evidence gate: completion claims require executed test/lint/build output.
- **`using-git-worktrees`** *(superpowers, 296k ⭐)*: Workspace and branch isolation for invasive changes.
- **`github-repo-best-practices`**: Top-1% standard for repo layout, README, CI/CD, and release metadata.
- **`security-audit`**: Static OWASP Top-10 audit for web applications (SQLi, XSS, CSRF, IDOR).
- **`webapp-testing`** *(anthropics/skills, 180k ⭐)*: Playwright-based testing and server lifecycle management for web applications.
- **`mcp-builder`** *(anthropics/skills, 180k ⭐)*: Comprehensive guide for designing and developing Model Context Protocol servers.

### 2. Bioinformatics & Genomics Stack
- **`nextflow`** *(K-Dense-AI, 47.9k ⭐)*: Nextflow DSL2 pipelines, nf-core conventions, samplesheets, process/channel flow, and SLURM HPC deployment.
- **`pysam`** *(K-Dense-AI, 47.9k ⭐)*: Low-level streaming access and manipulation for SAM/BAM/CRAM, VCF/BCF, and FASTA/FASTQ.
- **`biopython`** *(K-Dense-AI, 47.9k ⭐)*: Sequence manipulation, structure parsing (PDB), phylogenetic trees, and programmatic NCBI Entrez queries.
- **`statistical-data-visualization`**: Verification of statistical plots, bias detection, and interpretability for scientific reports.
- **`tool-installation`**: Clean conda/bioconda environment installation guidelines, preventing pip failures on Python 3.14.

### 3. Context Discipline & Utility
- **`token-efficiency`**: Context budget management for local models on limited VRAM.
- **`skill-acquisition`**: Search trust ladder, vet (stars, maintenance, security scan), synthesize, and register new skills.
- **`skill-evaluation`**: Quantitative benchmarking and A/B comparison for prompts and skill changes.
- **`skill-maker`**: Red-Green-Refactor authoring loop for agent skills.
- **`web-scraping`**: Structured data extraction from static and client-rendered web pages.
- **`pdf-inplace-editing`**: Pixel-diff verified in-place PDF editing and redaction.

## Provenance

Every acquired skill is tracked in [`reference/skills/REGISTRY.md`](../../reference/skills/REGISTRY.md).
