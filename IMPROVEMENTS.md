# Improvement Log

Append-only record of harness upgrades: what was added, why, and the public source each change is grounded in.

---

## 2026-11-01 — Hardware-Agnostic Pruning, Autonomous Zero-Overhead REA CLI & General Overnight Explorer

What:
1. Pruned hardware-coupled and redundant tools/skills: removed `/gpu` command (`nvtop` covers GPU monitoring externally), `scripts/gpu-prep.sh` (RTX 3090 specific), `scripts/export-trajectory.sh` (SFT trajectory export superseded by zero-weight-touch `lessons.jsonl`), `tool-installation` (Python-version-specific filler already in `AGENTS.md`), and duplicate `hybrid-routing` + `/hybrid` (consolidated into optional sibling `hybrid-sage`'s `model-router`).
2. Rewrote `overnight-explorer` as a clean, zero-hardcoding, domain-general autonomous exploration skill (`FINDINGS_REPORT.md` + `ANALYSIS_METHODS.md` + refuted-hypothesis tracking) for unattended sessions while the host is away, and added gitignored `reference/skills.local/` support so machine-private skills remain synced locally without entering public git history.
3. Pre-installed `rea-agents@6.4.0` CLI (`~/.local/bin/rea`) and added autonomous opaque-artifact trigger rules to `AGENTS.md` and `reverse-engineer-anything` so the agent inspects binaries, APKs, `.asar`, WASM/bytecode, firmware, and minified JS bundles automatically during codebase exploration while keeping the 140-tool `rea` MCP opt-in (`--with-rea`).
4. Added missing `orchestrator` subagent sampling configuration (`0.3` / `0.85`) to `reference/opencode.template.json`, generalized `security-audit` into a stack-agnostic OWASP Top-10 web & API audit skill, and updated `scripts/activate.sh` + `scripts/doctor.sh` for clean `skills.local/` and `rea` CLI verification.
Why: Keeps the default harness hardware-portable and zero-overhead on normal source-code turns while giving agents zero-touch binary inspection, unattended discovery, and clean separation between public and machine-local skills.
Source: `skill-maker` pruning discipline (`anthropics/skills`, `obra/superpowers`), `morluto/rea` CLI (`rea-agents@6.4.0`).

---

## 2026-10-31 — Swarm Orchestrator, Hybrid Routing & Doctor Hardening

What:
1. Added `orchestrator` subagent (`reference/agents/orchestrator.md`): decomposes complex initiatives into parallelizable workstreams, spawns and tracks specialized subagents, and synthesizes outputs.
2. Added `hybrid-routing` skill (`reference/skills/hybrid-routing/`): 3-tier adaptive cognitive routing partitioning abstract/conceptual reasoning to Gemini 4 Argon, standard execution/review to Gemini 3.8 Flash, and deterministic instruction tasks to local AI workers via `probe_worker.sh` and `dispatch_local.py`, activating on-demand with `/hybrid` without toggle complexity.
3. Hardened `scripts/activate.sh` and `scripts/doctor.sh`: automatic backup retention (keeps 5 most recent timestamped backups, prunes older ones); `doctor.sh` checks installed skills/agents parity against `reference/` and supports `--prune-backups`; injects Authorization header into `/models` probe.
4. Synced documentation and links (`README.md`, `AGENTS.md`, `docs/components/skills.md`, `docs/components/agents.md`, `evals/README.md`) to 31 skills and 4 subagents.
Why: Prevents context/token exhaustion on repetitive mechanical tasks via local routing; coordinates multi-agent swarms for broad initiatives; eliminates unbounded backup directory growth; ensures continuous parity between reference and live config.
Source: Self-improvement loop; user-orchestrator pattern; Conventional Commits & repo guidelines.

---

## 2026-10-27 — Provider migration: Legacy Local Proxy → Direct OpenAI-Compatible Server

What: template provider `workplace-ai` (Unsloth Studio `:8888`, retired) replaced by `strata` (direct `llama-server` `:8080`, model `qwen3.8-flash-next-iq3_s`, `limit.context` = `limit.output` = server-reported `n_ctx` 262144). `activate.sh`/`doctor.sh` fallback URLs → `:8080`; auto-sync parses llama-server's payload (`status.value=="loaded"`, `meta.n_ctx`; still accepts `loaded`/`context_length`). Per-agent thinking-model overrides removed — server serves one id. `reasoning_effort` moved from top-level model key to `options.reasoningEffort` (v2: top-level legacy `reasoning`/`temperature` are omitted; unknown keys invalidate the whole provider block → opencode skips it silently). `compaction.prune`/`tail_turns` dropped (v2-omitted legacy).
Why: retired proxy endpoint replaced with direct server; server reports `n_ctx 262144` so `activate.sh` syncs full window limits dynamically.
Source: live `GET :8080/v1/models`; opencode v2.0.24 runtime log (provider skipped as malformed) + opencode.ai/config.json v2 schema (limit requires context AND output; model entry rejects unknown keys).

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

## 2026-10-12 — Auto-Sync Model Limits + Output=Context

What: `scripts/activate.sh` now reads `context_length` of the `loaded==true` model from `$BASE_URL/models` on every run and sets `limit.context` = `limit.output` for all `workplace-ai` models; template fallbacks set to 124288/124288. Unreachable/unreported server keeps template values with a warning, never fails activation.
Why: hardcoded `limit.context: 262144` vs server `124288` meant auto-compaction (~90% threshold) never fired before server 400s; manual resync on every `-c` change was toil; user wants full-window outputs.
Source: opencode docs `/models` (explicit `limit` required for custom OpenAI-compatible; no detection) + `/compaction` (`buffer` defaults to 10% of limit).

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

## 2026-11-08 — Skill integrity and scoped autonomous learning

- Aligned acquisition and post-task learning: use official docs for one-off gaps;
  install vetted reusable skills when requested or within authorized harness work.
  Removed arbitrary star-count gates as a substitute for inspecting instructions,
  references, license, and compatibility. Existing authorization remains sufficient.
- Replaced default system Python overrides with existing project environments,
  `uv`/venv, or named conda environments; removed hardcoded environment assumptions.
- Repaired absent Nextflow, pysam, Biopython, and MCP guide references using official
  documentation; added local MCP evaluation and behavior-oriented test guidance.
  Preserved upstream attribution and clarified illustrative scientific examples.
- Added dependency-free skill metadata/resource validation before activation,
  four regression tests for the validator, and CI coverage. Corrected repository
  instructions so smoke tests preserve live credentials and use temporary HOME.
- Made review, design interviews, worktrees, and cross-harness escalation proportional
  to the task, with Codex-aware consultation and graceful unavailable-tool fallback.
- Sources: local audit; https://docs.seqera.io/nextflow/;
  https://nf-co.re/docs/developing/overview; https://pysam.readthedocs.io/;
  https://biopython.org/docs/latest/Tutorial/; official MCP SDK repositories and
  https://modelcontextprotocol.io/docs/develop/build-server.
- Hypothesis: resolving broken resource routes and conflicting acquisition rules
  prevents dead-end retrieval and irrelevant installs. Static/link checks and
  isolated activation are the validation for this change; behavioral A/B gains
  remain unmeasured. Frozen cases: `evals/cases/procedure-selection.md`.
