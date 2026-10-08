# opencode-sage

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> A reproducible, state-of-the-art harness and knowledge base for **opencode** paired with local quantized models (Qwen 3.8 27B on RTX 3090) and remote endpoints, enhanced with battle-tested cross-pollinations from the Google Antigravity harness.

---

## 🌟 What is opencode-sage?

`opencode-sage` builds upon the foundational principles of `sage-cookbook`, supercharged with the top-performing capabilities, skills, and tools proven in the Antigravity best-practices setup:

1. **LSP Compiler Ground Truth**: 12 language servers in `~/.local/bin` covering Python (`pyright`), PHP (`intelephense`), Shell (`@bash-lsp`), Markdown/Quarto (`marksman`), YAML, HTML, CSS, JSON, ESLint, Tailwind, and TypeScript.
2. **Curated MCP Layer**: 
   - `context7`: Up-to-date third-party library API docs on demand.
   - `deepwiki`: Remote AI documentation and architecture indexing for public GitHub repos (zero VRAM overhead).
   - `sequential-thinking`: External structured planning scratchpad for local models.
   - `fetch`: Ultra-lightweight static web fetching without launching browsers.
   - `playwright`: High-fidelity browser testing for JS-heavy SPAs.
   - `memory`: Persistent knowledge graph surviving context compaction and restarts.
3. **20 Vetted Agent Skills**:
   - Software engineering: `agentic-coding`, `test-driven-development` (obra/superpowers, 296k ⭐), `using-git-worktrees` (obra/superpowers), `systematic-debugging`, `verification-before-completion`, `github-repo-best-practices`, `security-audit`, `webapp-testing` (anthropics/skills, 180k ⭐), `mcp-builder`.
   - Bioinformatics stack: `nextflow` (K-Dense-AI, 47.9k ⭐), `pysam` (K-Dense-AI), `biopython` (K-Dense-AI), `statistical-data-visualization`, `tool-installation`.
   - Context discipline: `token-efficiency`, `skill-acquisition`, `skill-evaluation`, `skill-maker`, `web-scraping`, `pdf-inplace-editing`.
4. **Subagent Roster**:
   - `reviewer`: Read-only code reviewer evaluating diffs against correctness bugs and conventions (`edit: deny`).
   - `skeptic`: Adversarial red-team attacking implementation plans before writing code (`edit: deny`).
   - `bioinformatician`: Production genomics specialist for Nextflow DSL2, nf-core, Quarto, conda, and SLURM.
5. **Interactive Commands**: `/review`, `/red-team`, `/checkpoint`, `/gpu`, `/doctor`.

---

## 🚀 Quick Start

### 1. Install Language Servers
Ensure Node 22+ is available with user prefix:
```bash
./scripts/install-lsps.sh
```

### 2. Stage & Activate the Harness
Install the configuration into `~/.config/opencode`:
```bash
./scripts/activate.sh [--base-url <url>] [--key <api-key>]
```
*Note: If `~/.config/opencode/opencode.json` already exists, `activate.sh` automatically retains your existing API key and base URL while creating a timestamped backup.*

### 3. Verify Health with Doctor
Run the diagnostic suite:
```bash
./scripts/doctor.sh
```
Or inside opencode:
```
/doctor
```

---

## 📁 Repository Structure

```text
opencode-sage/
├── .gitignore                  # Comprehensive gitignore for secrets, caches & runtime
├── LICENSE                     # MIT License
├── README.md                   # This document
├── AGENTS.md                   # Repository working agreements
├── CITATION.cff                # Academic citation metadata
├── CODE_OF_CONDUCT.md          # Community code of conduct
├── CONTRIBUTING.md              # Contribution guide & workflow
├── IMPROVEMENTS.md             # Append-only improvement log
├── docs/                       # Architecture, quantization, context engineering
│   ├── architecture.md
│   ├── context-engineering.md
│   ├── quantization.md
│   └── components/             # Detailed docs for LSP, MCP, skills, config, agents
├── reference/                  # Source of truth installed into ~/.config/opencode
│   ├── AGENTS.md               # Global agent instructions
│   ├── opencode.template.json  # Staged config template
│   ├── agents/                 # Subagent definitions (reviewer, skeptic, bioinformatician)
│   ├── commands/               # Slash commands (review, red-team, checkpoint, gpu, doctor)
│   └── skills/                 # 20 curated agent skills + REGISTRY.md
└── scripts/                    # Automation scripts
    ├── activate.sh             # Idempotent installer with auto-backup
    ├── doctor.sh               # Health check diagnostic suite
    ├── install-lsps.sh         # LSP compiler installer
    ├── pin-mcp.sh              # MCP package version pin tool
    └── gpu-prep.sh             # GPU power cap script for RTX 3090
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

