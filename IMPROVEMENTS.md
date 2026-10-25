# Improvement Log

Append-only record of harness upgrades: what was added, why, and the public source each change is grounded in.

---

## 2026-10-25 — Matt Pocock Engineering Skills Pass

### 1. New Vetted Skills Added (5)
| Skill | What it Adds | Source / Stars |
|---|---|---|
| `grill-me` | Relentless design-tree interview loop in rounds with concrete recommended defaults to stress-test plans before code is written. | `mattpocock/skills` (302.6k ⭐, MIT) |
| `domain-modeling` | Active domain modeling discipline, inline `GLOSSARY.md` maintenance, and ADR authoring when trade-offs crystallize. | `mattpocock/skills` (302.6k ⭐, MIT) |
| `codebase-design` | Deep modules vs shallow modules (Ousterhout), high leverage, locality, and seam discipline. | `mattpocock/skills` (302.6k ⭐, MIT) |
| `to-spec` | Spec-driven synthesis: converts conversation and codebase context into verified technical specifications. | `mattpocock/skills` (302.6k ⭐, MIT) |
| `to-tickets` | Vertical tracer-bullet slicing with blocking dependency chains and expand-contract refactors. | `mattpocock/skills` (302.6k ⭐, MIT) |

### 2. New Slash Command Added
- `/grill-me`: Interactive design-tree interview to stress-test architecture & plans before building.

---

## 2026-10-12 — Reverse-Engineering Capability Pass

Hypothesis: a skill-gated REA MCP adds binary/artifact analysis (zero coverage today) at near-zero idle context cost via the `compact` schema profile + load-only-on-match routing.

### 1. New MCP Server Added
| Server | Type | Purpose | Source / Rationale |
|---|---|---|---|
| `rea` | local stdio (`npx -y rea-agents@6.4.0 mcp`, `REA_MCP_INPUT_SCHEMA_PROFILE=compact`, 60s timeout) | Reverse engineering: native binaries, APKs, firmware, Electron/JS, .NET, WASM/EVM with evidence-backed findings | `morluto/rea` (99.9k ⭐, MIT, pushed 2026-10-11). Pinned exact version, no `@latest`. Added to `pin-mcp.sh` coverage. |

### 2. New Vetted Skill Added (1)
| Skill | What it Adds | Source / Stars |
|---|---|---|
| `reverse-engineer-anything` | Auto-activation routing (use-when/don't-use-when vs Serena/`security-audit`/docs tools), host readiness boundary (static-only: no Ghidra/Hopper/IDA installed), evidence contract (observations/inferences/unknowns + Evidence IDs), runtime-capture safety scope | Synthesized from `morluto/rea` `.agents/skills/reverse-engineer-anything/SKILL.md` (vetted: injection scan clean) + `reference/skills/REGISTRY.md` entry |

### 3. Boundary & Deferral
- Native decompilation (`open_binary` → pseudocode) deferred until Ghidra is installed; skill says so instead of failing. Static JS/Electron + .NET + ELF-layout + PE-resource routes work now.
- Full A/B eval per `docs/evaluation.md` deferred to first real REA task (no binary target available at staging time); null/pending result recorded here per loop rules.

---

## 2026-10-09 — FAIR Data Stewardship & First-Principles Explainer Pass

### New Vetted Skills Added
| Skill | What it Adds | Source / Stars |
|---|---|---|
| `fair-data-principles` | Enforces Findable, Accessible, Interoperable, and Reusable (FAIR) standards, Frictionless Data Package schemas (`datapackage.json`), MIMAG genome quality standards, and GSC MIxS metadata across scientific workflows. | Self-authored / Wilkinson et al. (2016 *Sci. Data*) |
| `first-principles-explainer` | Breaks down bioinformatics pipelines, data engineering, and algorithmic discrepancies from first principles. | Self-authored |

---

## 2026-10-08 — SOTA Intelligence, LSP & Genomics Expansion Pass

### 1. New MCP Server Added
| Server | Type | Purpose | Source / Rationale |
|---|---|---|---|
| `deepwiki` | remote (Streamable HTTP) | Instant AI-indexed GitHub documentation, wikis, and codebase architecture | Free, zero credentials, runs off-host with zero local VRAM cost. Adds external code intelligence. |

### 2. New Vetted Skills Added (7)
| Skill | What it Adds | Source / Stars |
|---|---|---|
| `test-driven-development` | Red-Green-Refactor iron law: no production code without a failing test first. Eliminates speculative hallucinatory code. | `obra/superpowers` (296.4k ⭐, MIT) |
| `using-git-worktrees` | Branch and worktree isolation prior to multi-file refactoring or invasive changes. | `obra/superpowers` (296.4k ⭐, MIT) |
| `nextflow` | Comprehensive Nextflow DSL2 pipelines, nf-core conventions, process/channel debugging, and SLURM HPC deployment. | `K-Dense-AI/scientific-agent-skills` (47.9k ⭐, Apache-2.0) |
| `pysam` | High-throughput HTSlib genomic data streaming (SAM/BAM/CRAM, VCF/BCF, tabix). | `K-Dense-AI/scientific-agent-skills` (47.9k ⭐, MIT) |
| `biopython` | Sequence manipulation, PDB structure analysis, and programmatic NCBI Entrez/PubMed queries. | `K-Dense-AI/scientific-agent-skills` (47.9k ⭐, Biopython License) |
| `webapp-testing` | Playwright test orchestration and automated server lifecycle handling for web apps. | `anthropics/skills` (180k ⭐, Apache-2.0) |
| `mcp-builder` | Model Context Protocol design and implementation guide (Python FastMCP & TypeScript SDK). | `anthropics/skills` (180k ⭐, Apache-2.0) |

### 3. LSP Expansion
| Addition | Purpose | Source |
|---|---|---|
| `intelephense` | Compiler-grade type checking and definition jumps for PHP / CodeIgniter 4 | npm `intelephense` |
| `typescript-language-server` | Full TypeScript/JavaScript semantic intelligence | npm `typescript-language-server` |

### 4. Tooling & Automation
- Created `scripts/doctor.sh` diagnostics suite testing model reachability, MCP responsiveness, LSP binary presence, and security permissions.
- Updated `scripts/activate.sh` to support dynamic `--base-url` and `--key` flags while backing up previous configuration to timestamped directories.
- Strengthened `reference/AGENTS.md` with explicit TDD discipline, git worktree isolation, and quality vetting standards.

---

## 2026-08-23 — Baseline Discipline, Security, and Measurement Pass

- Added `verification-before-completion` and `systematic-debugging` (obra/superpowers).
- Added `skeptic` subagent for pre-implementation red-teaming.
- Added `/doctor` and `/review` commands.
- Established documentation on quantization, context engineering, and evaluation.
