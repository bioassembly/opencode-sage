# AGENTS.md

## What this repo is

Docs + staged config for the opencode-sage coding workstation harness. No application code, no build system, no test suite, no CI — content is Markdown, one JSON config template, and four bash scripts.

## Core workflow: stage → activate → restart

`reference/` is the source of truth; `scripts/activate.sh` installs it into `~/.config/opencode`.

1. Edit under `reference/` (opencode.template.json, agents/, commands/, skills/) or `docs/`.
2. Re-run `./scripts/activate.sh --key <any-non-empty-string>` (idempotent; auto-backs up live config to `~/.config/opencode/backup-<ts>/` and prints the rollback path).
3. Restart opencode — config is read only at startup.

Never edit `~/.config/opencode/` directly: the next `activate.sh` run overwrites it.

## Hard rules

- Secrets never enter the repo. `reference/opencode.template.json` keeps the literal `__UNSLOTH_API_KEY__` placeholder; keys are injected at install time via jq. `.gitignore` excludes `opencode.json`, `*.local.json`, `.env*`.
- `@latest` is banned in MCP commands. After changing MCP package versions, run `./scripts/pin-mcp.sh`, then re-run `activate.sh`.
- Online-acquired skills must be registered (append-only) in `reference/skills/REGISTRY.md` with source, and their SKILL.md read before installing — unvetted instruction files are a prompt-injection vector.
- Harness additions follow the evaluation loop in `docs/evaluation.md` and get logged in `IMPROVEMENTS.md` (append-only: what, why, source). Facts/decisions may go to memory MCP; secrets and large blobs may not.
- Never kill/signal `llama-server`, `unsloth`, or opencode processes, and never start a second GPU-allocating process while one runs — VRAM contention kills live sessions. Check `/gpu` first.

## Non-obvious details

- `activate.sh` maps plural→singular on install: `reference/agents` → `~/.config/opencode/agent`, `reference/commands` → `command`; skills copy as whole directories, excluding `REGISTRY.md`.
- "Qwen3.8-27B" is the intentional model name used consistently across all docs — do not "correct" it.
- Each file in `docs/components/` is self-contained; extract what you need without reading the rest.
- Restore procedure lives in `BACKUP.md`: quit opencode first, then restore, then relaunch.

## Verification

No test suite. Before committing:

```bash
jq empty reference/opencode.template.json   # config parses
bash -n scripts/*.sh                        # scripts parse
```

If you changed anything `activate.sh` installs, actually run it (`--key x`) and confirm "Config JSON valid."
