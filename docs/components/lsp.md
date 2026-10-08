# LSP Layer

## Why this exists

A local model cannot reliably self-verify code syntax and typing without external compiler feedback. Language servers provide **compiler-grade ground truth** — symbol definitions, types, diagnostics, and auto-completions — inside the agent's edit loop. For a 27B model, this converts "I think this API method exists" into verified structural facts.

opencode attaches servers automatically when matching files open via `"lsp": true`.

## Inventory

Installed to `~/.local/bin` (user-owned, isolated from system packages):

| Binary | Covers | Install source |
|---|---|---|
| `pyright-langserver` | Python | npm `pyright` |
| `bash-language-server` | Shell scripts, pipelines | npm `@bash-lsp/bash-language-server` |
| `yaml-language-server` | YAML (CI workflows, configs) | npm `yaml-language-server` |
| `vscode-json-language-server` | JSON | npm `vscode-langservers-extracted` |
| `vscode-html-language-server` | HTML | npm `vscode-langservers-extracted` |
| `vscode-css-language-server` | CSS | npm `vscode-langservers-extracted` |
| `vscode-eslint-language-server` | JS/TS linting | npm `vscode-langservers-extracted` |
| `tailwindcss-language-server` | Tailwind classes | npm `@tailwindcss/language-server` |
| `intelephense` | PHP / CodeIgniter 4 | npm `intelephense` |
| `typescript-language-server` | TypeScript / JavaScript | npm `typescript-language-server` |
| `marksman` | Markdown / Quarto `.qmd` | GitHub release binary |

## Installation

```bash
./scripts/install-lsps.sh
```

Idempotent and safe to re-run.

**Verify:** `ls ~/.local/bin | grep -E 'language-server|pyright|marksman|intelephense'`

## Retrieval Ladder with LSP

In accordance with the `token-efficiency` skill:
1. `grep` / pattern search for symbol name.
2. Read targeted line range or slice.
3. **LSP go-to-definition** and symbol references instead of brute-force full file reading.
4. `context7` or `deepwiki` for external dependencies/documentation.
5. Full-file read only as a last resort.
