# Agent Skills

Skills are modular, on-demand procedure guides that instruct the agent on how to execute specialized multi-step workflows. They are loaded dynamically when relevant, protecting the context window from token bloat.

All skills live in [`reference/skills/`](../../reference/skills/) and are installed into `~/.config/opencode/skills/` via `scripts/activate.sh`.

## Catalog (30 Skills)

### 1. Core Software Engineering & Discipline
- **`agentic-coding`**: Working agreements for coding loops: plan-then-edit, minimal diffs, verify each step.
- **`grill-me`** *(mattpocock/skills, 302k ⭐)*: Relentless design-tree interview loop in rounds with concrete defaults to stress-test plans before code is written.
- **`domain-modeling`** *(mattpocock/skills, 302k ⭐)*: Active domain modeling discipline, GLOSSARY.md maintenance, and ADR authoring when trade-offs crystallize.
- **`codebase-design`** *(mattpocock/skills, 302k ⭐)*: Deep modules vs shallow modules (Ousterhout), high leverage, locality, and seam discipline.
- **`to-spec`** *(mattpocock/skills, 302k ⭐)*: Spec-driven synthesis: converts conversation and codebase context into verified technical specifications.
- **`to-tickets`** *(mattpocock/skills, 302k ⭐)*: Vertical tracer-bullet slicing with blocking dependency chains and expand-contract refactors.
- **`git-commit-convention`**: History-first house-style inference, Conventional Commits format, imperative summaries, closing keywords.
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
- **`pipeline-sketch-results`**: Manual pipeline results ingestion and publication with selective ingestion and evidence citations.
- **`fair-data-principles`**: Enforce and audit FAIR data principles (Findable, Accessible, Interoperable, Reusable) across scientific datasets and pipelines.

### 3. Reverse Engineering
- **`reverse-engineer-anything`** *(morluto/rea, 99.9k ⭐)*: Multi-target reverse engineering for native binaries, APKs, firmware, Electron/JS, and WASM/EVM.

### 4. Context Discipline & Utility
- **`first-principles-explainer`**: Break down complex bioinformatics, data pipelines, and algorithmic logic from first principles.
- **`token-efficiency`**: Context budget management for local models on limited VRAM.
- **`skill-acquisition`**: Search trust ladder, vet (stars, maintenance, security scan), synthesize, and register new skills.
- **`skill-evaluation`**: Quantitative benchmarking and A/B comparison for prompts and skill changes.
- **`skill-maker`**: Red-Green-Refactor authoring loop for agent skills.
- **`web-scraping`**: Structured data extraction from static and client-rendered web pages.
- **`pdf-inplace-editing`**: Pixel-diff verified in-place PDF editing and redaction.

## Provenance

Every acquired skill is tracked in [`reference/skills/REGISTRY.md`](../../reference/skills/REGISTRY.md).
