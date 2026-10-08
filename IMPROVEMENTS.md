# Improvement Log

Append-only record of harness upgrades: what was added, why, and the public source each change is grounded in.

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
