# Acquired Skills Registry

Append-only provenance log of curated and online-acquired skills shipped in `reference/skills/`.
Future sessions: check this file BEFORE re-searching the web for a skill.

Format: `- YYYY-MM-DD <skill-name> <- <source repo/url> (stars: N) <one-line note>`

- 2026-08-22 security-audit <- self-authored — stack-agnostic OWASP Top-10 web & API security audit
- 2026-08-22 statistical-data-visualization <- self-authored — viz correctness/bias checks for bioinformatics reports
- 2026-08-23 pdf-inplace-editing <- self-authored — zero-layout-drift PDF editing/anonymization: content-stream byte swaps + raster re-lettering + pixel-diff verification (`pdf_edit.py`)
- 2026-08-23 token-efficiency <- self-authored — context-window and token budget discipline (grep/LSP-first retrieval ladder, sliced reads, subagent isolation)
- 2026-08-23 systematic-debugging <- adapted from github.com/obra/superpowers — 4-phase root-cause debugging loop
- 2026-08-23 verification-before-completion <- adapted from github.com/obra/superpowers — evidence-gated completion claims
- 2026-08-25 skill-maker <- synthesized from github.com/anthropics/skills + github.com/obra/superpowers (writing-skills) — skill authoring standard: TDD loop, SDO descriptions, progressive disclosure
- 2026-08-25 github-repo-best-practices <- synthesized from anthropics/skills, obra/superpowers, paperswithcode/releasing-research-code, nf-core specs — repo+README audit/build standard with AI/ML and bioinformatics overlays
- 2026-10-08 test-driven-development <- github.com/obra/superpowers (stars: 296.4k, MIT) — Red-Green-Refactor iron law: no production code without failing test first
- 2026-10-08 using-git-worktrees <- github.com/obra/superpowers (stars: 296.4k, MIT) — safe workspace isolation using native worktrees or git fallback
- 2026-10-08 nextflow <- github.com/K-Dense-AI/scientific-agent-skills (stars: 47.9k, Apache-2.0) — Nextflow DSL2 pipelines, nf-core modules, nextflow.config, SLURM HPC execution
- 2026-10-08 pysam <- github.com/K-Dense-AI/scientific-agent-skills (stars: 47.9k, MIT) — low-level genomic file streaming and query (SAM/BAM/CRAM, VCF/BCF, tabix)
- 2026-10-08 biopython <- github.com/K-Dense-AI/scientific-agent-skills (stars: 47.9k, Biopython License) — sequence analysis, structure parsing, programmatic NCBI Entrez/PubMed access
- 2026-10-08 webapp-testing <- github.com/anthropics/skills (stars: 180k, Apache-2.0) — Playwright test runner and server lifecycle automation
- 2026-10-08 mcp-builder <- github.com/anthropics/skills (stars: 180k, Apache-2.0) — protocol guide for building high-quality MCP servers in Python and TypeScript
- 2026-10-09 first-principles-explainer <- self-authored — first-principles explainer for bioinformatics/data-pipeline discrepancies with grounded examples
- 2026-10-09 fair-data-principles <- self-authored (Wilkinson et al. 2016) — FAIR principles enforcement, Frictionless schema validation, and MIMAG/MIxS standards for scientific workflows
- 2026-10-12 reverse-engineer-anything <- github.com/morluto/rea (stars: 99.9k, MIT) — autonomous binary/APK/firmware/Electron/WASM-EVM reverse engineering via zero-overhead `rea` CLI (`rea-agents@6.4.0`, optional `--with-rea` MCP)
- 2026-10-25 grill-me <- github.com/mattpocock/skills (stars: 302.6k, MIT) — relentless design-tree interview loop in rounds with recommended defaults to stress-test plans before code is written
- 2026-10-25 domain-modeling <- github.com/mattpocock/skills (stars: 302.6k, MIT) — active domain modeling, GLOSSARY.md maintenance, and ADR authoring when trade-offs crystallize
- 2026-10-25 codebase-design <- github.com/mattpocock/skills (stars: 302.6k, MIT) — deep modules vs shallow modules (Ousterhout), leverage, locality, and seam discipline
- 2026-10-25 to-spec <- github.com/mattpocock/skills (stars: 302.6k, MIT) — spec-driven development turning discussion and codebase context into verified technical specifications
- 2026-10-25 to-tickets <- github.com/mattpocock/skills (stars: 302.6k, MIT) — tracer-bullet vertical slice tickets with explicit blocking edges and expand-contract refactoring
- 2026-10-25 git-commit-convention <- self-authored (conventionalcommits.org 1.0.0, GitHub Docs, cbea.ms) — history-first house-style inference, Conventional Commits format, imperative summaries, closing keywords, amend/force-with-lease fix path
- 2026-11-01 overnight-explorer <- self-authored — domain-general unattended autonomous discovery loop (hypothesis ledger, refuted-hypothesis tracking, `FINDINGS_REPORT.md` + `ANALYSIS_METHODS.md` synthesis)

- 2026-11-08 harness-integrity pass <- local audit + official MCP SDK, Nextflow/Seqera, pysam, and Biopython documentation — repaired unavailable scientific/MCP guide links, added local MCP evaluation and test-design guides, aligned acquisition with authorized maintenance, and preferred isolated Python environments. New support text is locally authored; existing upstream attribution remains.
