# OpenCode SAGE

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **OpenCode SAGE (State-of-the-Art Agentic Genomics & Engineering Harness)**: A reproducible, high-performance configuration harness for **opencode**, engineered to match and exceed the capabilities of modern agentic coding and bioinformatics harnesses.

---

## 🌟 Architecture & Design Philosophy

1. **Native Strengths & LSP Compiler Ground Truth**: Leverages opencode's native `"lsp": true` engine coupled with 12 language servers pre-installed in `~/.local/bin` (covering Python, PHP, TypeScript, Bash, Markdown/Quarto, YAML, HTML, CSS, JSON, ESLint, Tailwind). The agent receives compiler-grade symbol search, type diagnostics, jump-to-definition, and semantic refactoring directly without LLM hallucination.
2. **Curated Model Context Protocol (MCP) Layer**: Outfitted with a focused, high-throughput MCP server layer: `context7` for real-time framework documentation, `deepwiki` for remote AI-indexed GitHub documentation without token cost, `sequential-thinking` for structured planning, `fetch` for fast static web requests, and `playwright` for headless browser workflows.
3. **Persistent Project Memory**: Powered by `@modelcontextprotocol/server-memory`, storing a local knowledge graph (`~/.config/opencode/memory.json`) that preserves durable project architectural decisions, user preferences, and conventions across context compactions and new sessions.
4. **Autonomous Execution with Strict Safeguards**: Outfitted with fine-grained permissions and an anchored Deny list (`rm -rf /`, `mkfs`, raw block device writes, unvetted pipe-to-shell executions) combined with subagent permission isolation (`edit: deny` for `reviewer` and `skeptic`).

---

## 📦 What is Included

### 1. Language Server Protocol (LSP) Compilers (12 Total)
Installed directly into `~/.local/bin`:
- **Python**: `pyright` (type analysis & autocompletion)
- **PHP**: `intelephense` (PHP & CodeIgniter 4 semantic analysis)
- **TypeScript / JavaScript**: `typescript-language-server`
- **Shell / Bash**: `bash-language-server` (`@bash-lsp`)
- **Documentation & Quarto**: `marksman`
- **Web & Config**: `yaml-language-server`, `vscode-html-languageserver`, `vscode-css-languageserver`, `vscode-json-languageserver`, `vscode-eslint-language-server`, `tailwindcss-language-server`

### 2. Model Context Protocol (MCP) Servers
- **`context7`**: Remote Streamable HTTP MCP for real-time framework & library API documentation (`https://mcp.context7.com/mcp`).
- **`deepwiki`**: Remote Streamable HTTP MCP for querying AI-indexed GitHub repository wikis and architectures without credentials (`https://mcp.deepwiki.com/mcp`).
- **`sequential-thinking`**: Local MCP structured planning scratchpad (`@modelcontextprotocol/server-sequential-thinking@2026.7.4`).
- **`memory`**: Local MCP knowledge graph for durable project memory (`~/.config/opencode/memory.json`).
- **`fetch`**: Lightweight static web content extraction (`mcp-server-fetch`).
- **`playwright`**: Headless browser automation for dynamic single-page web applications (`@playwright/mcp@0.0.79`).

### 3. Vetted Agent Skills (20 Total)
- **Core Software Engineering**: `agentic-coding`, `test-driven-development` (obra/superpowers, 296k ⭐), `using-git-worktrees` (obra/superpowers), `systematic-debugging`, `verification-before-completion`, `github-repo-best-practices`, `security-audit`, `webapp-testing` (anthropics/skills, 180k ⭐), `mcp-builder`.
- **Bioinformatics & Scientific Stack**: `nextflow` (K-Dense-AI, 47.9k ⭐), `pysam` (K-Dense-AI), `biopython` (K-Dense-AI), `statistical-data-visualization`, `tool-installation`.
- **Context & Reasoning Discipline**: `token-efficiency`, `skill-acquisition`, `skill-evaluation`, `skill-maker`, `web-scraping`, `pdf-inplace-editing`.

### 4. Custom Subagents (`~/.config/opencode/agent/`)
- **`reviewer`**: Read-only code reviewer evaluating diffs against correctness bugs, security vulnerabilities, and repo conventions (`edit: deny`).
- **`skeptic`**: Adversarial senior engineer attacking implementation plans before writing code (hidden assumptions, failure modes, simpler alternatives, `edit: deny`).
- **`bioinformatician`**: Specialized persona for Nextflow DSL2, nf-core conventions, Quarto reporting, conda environments, and genomic QC workflows.

### 5. Interactive Slash Commands (`~/.config/opencode/command/`)
- `/review`: Proactive git working diff review via `reviewer` subagent.
- `/red-team`: Adversarial pre-implementation plan attack via `skeptic` subagent.
- `/checkpoint`: Context dump to `NOTES.md` before compaction or session boundary.
- `/gpu`: GPU VRAM, power limits, and inference process monitor.
- `/doctor`: Harness integrity and health diagnostic suite.

### 6. Global Rules (`~/.config/opencode/AGENTS.md`)
Machine-wide agent protocol enforcing:
- Progressive skill activation and strict vetting ladder
- Verification-before-completion hard gate (no claim without executed evidence)
- Minimal diff discipline and test-driven development (TDD)
- Clean environment standards and credential protection

---

## 🚀 One-Command Installation & Replication

To install or reproduce this harness on any machine or server:

```bash
# 1. Clone this repository
git clone https://github.com/bioassembly/opencode-sage.git
cd opencode-sage

# 2. Install all language servers into ~/.local/bin
bash scripts/install-lsps.sh

# 3. Stage & activate the harness (with automatic timestamped backup)
bash scripts/activate.sh [--base-url <url>] [--key <api-key>]

# 4. Verify health with Doctor
bash scripts/doctor.sh
```

### What `activate.sh` Does:
1. Backs up existing `~/.config/opencode` configuration, agents, commands, and skills to a timestamped directory (`~/.config/opencode/backup-<YYYYMMDD-HHMMSS>`).
2. Deploys `reference/opencode.template.json` to `~/.config/opencode/opencode.json` with dynamic endpoint and memory path resolution.
3. Installs subagents into `~/.config/opencode/agent/`.
4. Installs slash commands into `~/.config/opencode/command/`.
5. Syncs all 20 vetted skills into `~/.config/opencode/skills/`.
6. Deploys global agent protocol rules to `~/.config/opencode/AGENTS.md`.

---

## 🔍 Diagnostics & Health Check

To verify your setup at any time:

```bash
bash scripts/doctor.sh
```
Or directly inside the opencode TUI:
```
/doctor
```

---

## 📋 Directory Structure

```text
opencode-sage/
├── .gitignore                  # Comprehensive gitignore for secrets, caches & runtime
├── LICENSE                     # MIT License
├── README.md                   # This documentation
├── AGENTS.md                   # Repository working agreements
├── CITATION.cff                # Academic citation metadata
├── CODE_OF_CONDUCT.md          # Community code of conduct
├── CONTRIBUTING.md              # Contribution guide & workflow
├── IMPROVEMENTS.md             # Append-only improvement log
├── docs/                       # Architecture, context engineering & guides
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
    └── gpu-prep.sh             # GPU power cap script
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
