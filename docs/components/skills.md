# Agent Skills

Skills are modular, on-demand procedure guides that instruct the agent on how to execute specialized multi-step workflows. They are loaded dynamically when relevant, protecting the context window from token bloat.

All bundled skills live in [`reference/skills/`](../../reference/skills/) and are installed into `~/.config/opencode/skills/` via `scripts/activate.sh`. Machine-private skills placed in gitignored `reference/skills.local/` are also synced automatically without entering version control.

## Catalog (30 Bundled Skills)

### 1. Core Software Engineering & Discipline
- **`agentic-coding`**: Working agreements for coding loops: plan-then-edit, minimal diffs, verify each step.
- **`grill-me`** *(mattpocock/skills, 302k ⭐)*: Relentless design-tree interview loop in rounds with concrete defaults to stress-test plans before code is written.
- **`domain-modeling`** *(mattpocock/skills, 302k ⭐)*: Active domain modeling discipline, `GLOSSARY.md` maintenance, and ADR authoring when trade-offs crystallize.
- **`codebase-design`** *(mattpocock/skills, 302k ⭐)*: Deep modules vs shallow modules (Ousterhout), high leverage, locality, and seam discipline.
- **`to-spec`** *(mattpocock/skills, 302k ⭐)*: Spec-driven synthesis: converts conversation and codebase context into verified technical specifications.
- **`to-tickets`** *(mattpocock/skills, 302k ⭐)*: Vertical tracer-bullet slicing with blocking dependency chains and expand-contract refactors.
- **`git-commit-convention`**: History-first house-style inference, Conventional Commits format, imperative summaries, closing keywords.
- **`test-driven-development`** *(superpowers, 296k ⭐)*: The iron law of TDD: no production code without a failing test first.
- **`systematic-debugging`** *(superpowers)*: 4-phase root-cause loop (reproduce → hypothesize → test minimally → fix cause).
- **`verification-before-completion`** *(superpowers)*: Evidence gate: completion claims require executed test/lint/build output.
- **`using-git-worktrees`** *(superpowers, 296k ⭐)*: Workspace and branch isolation for invasive changes.
- **`github-repo-best-practices`**: Top-1% standard for repo layout, README, CI/CD, and release metadata.
- **`security-audit`**: Stack-agnostic OWASP Top-10 static & dynamic security audit for web applications and APIs.
- **`webapp-testing`** *(anthropics/skills, 180k ⭐)*: Playwright-based testing and server lifecycle management for web applications.
- **`mcp-builder`** *(anthropics/skills, 180k ⭐)*: Comprehensive guide for designing and developing Model Context Protocol servers.

### 2. Bioinformatics & Genomics Stack
- **`nextflow`** *(K-Dense-AI, 47.9k ⭐)*: Nextflow DSL2 pipelines, nf-core conventions, samplesheets, process/channel flow, and SLURM HPC deployment.
- **`pysam`** *(K-Dense-AI, 47.9k ⭐)*: Low-level streaming access and manipulation for SAM/BAM/CRAM, VCF/BCF, and FASTA/FASTQ.
- **`biopython`** *(K-Dense-AI, 47.9k ⭐)*: Sequence manipulation, structure parsing (PDB), phylogenetic trees, and programmatic NCBI Entrez queries.
- **`statistical-data-visualization`**: Verification of statistical plots, bias detection, and interpretability for scientific reports.
- **`pipeline-sketch-results`**: Clean consolidation of custom pipeline outputs into a numbered `results/` deliverable directory while withholding internal code and secrets.
- **`fair-data-principles`**: Enforce and audit FAIR data principles (Findable, Accessible, Interoperable, Reusable) across scientific datasets and pipelines.

### 3. Reverse Engineering
- **`reverse-engineer-anything`** *(morluto/rea, 99.9k ⭐)*: Autonomous multi-target reverse engineering via zero-overhead `rea` CLI (`rea-agents@6.4.0`, optional `--with-rea` MCP) whenever compiled binaries, APKs, firmware, `.asar`, WASM/bytecode, or minified JS bundles without source are encountered.

### 4. Autonomous Discovery, Context Discipline & Utility
- **`overnight-explorer`**: Domain-general unattended multi-iteration discovery loop (codebases, datasets, benchmarks, research topics) synthesizing `FINDINGS_REPORT.md` + `ANALYSIS_METHODS.md` with refuted-hypothesis tracking while the host is away.
- **`first-principles-explainer`**: Break down complex bioinformatics, data pipelines, and algorithmic logic from first principles.
- **`token-efficiency`**: Context-window and token budget discipline (grep/LSP-first retrieval ladder, sliced reads, subagent isolation).
- **`skill-acquisition`**: Search trust ladder, vet (stars, maintenance, security scan), synthesize, and register new skills.
- **`skill-evaluation`**: Quantitative benchmarking and A/B comparison for prompts and skill changes.
- **`skill-maker`**: Red-Green-Refactor authoring loop for agent skills.
- **`web-scraping`**: Structured data extraction from static and client-rendered web pages.
- **`pdf-inplace-editing`**: Pixel-diff verified in-place PDF editing and redaction (`pdf_edit.py`).

*(When optional sibling [`hybrid-sage`](https://github.com/bioassembly/hybrid-sage) is installed, `model-router` is automatically linked as the cross-harness routing skill.)*

## Provenance

Every acquired skill is tracked in [`reference/skills/REGISTRY.md`](../../reference/skills/REGISTRY.md).
