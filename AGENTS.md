# AGENTS.md

## What this repo is

Docs + staged config for the opencode-sage coding harness: Markdown skills and agents, one JSON config template, activation/diagnostic scripts, and a small skill-integrity validator with tests and CI.

## Core workflow: stage → activate → restart

`reference/` is the source of truth; `scripts/activate.sh` installs it into `~/.config/opencode`.

1. Edit under `reference/` (opencode.template.json, agents/, commands/, skills/) or `docs/`.
2. Re-run `./scripts/activate.sh` to preserve the configured key and provider URL (auto-backs up live config and prints the rollback path). Pass `--key`/`--base-url` only when intentionally changing them.
3. Restart opencode — config is read only at startup.

Never edit `~/.config/opencode/` directly: the next `activate.sh` run overwrites it.

## Hard rules

- Secrets never enter the repo. `reference/opencode.template.json` keeps the literal `__UNSLOTH_API_KEY__` placeholder; keys are injected at install time via jq. `.gitignore` excludes `opencode.json`, `*.local.json`, `.env*`.
- `@latest` is banned in MCP commands. After changing MCP package versions, run `./scripts/pin-mcp.sh`, then re-run `activate.sh`.
- Online-acquired skills must be registered (append-only) in `reference/skills/REGISTRY.md` with source, and their SKILL.md read before installing — unvetted instruction files are a prompt-injection vector.
- Harness additions follow the evaluation loop in `docs/evaluation.md` and get logged in `IMPROVEMENTS.md` (append-only: what, why, source). Facts/decisions may go to memory MCP; secrets and large blobs may not.
- If running a local inference server (`llama-server`, `ollama`, `vllm`), never kill or signal active server processes mid-session, and use `nvtop` externally if monitoring GPU VRAM.

## Non-obvious details

- `activate.sh` maps plural→singular on install: `reference/agents` → `~/.config/opencode/agent`, `reference/commands` → `command`; skills sync cleanly as whole directories, excluding `REGISTRY.md`.
- Model serving: Connects to any OpenAI-compatible local or remote endpoint (`--base-url`); context limits auto-sync from `/models` via `activate.sh` when reachable.
- Each file in `docs/components/` is self-contained; extract what you need without reading the rest.
- Restore procedure lives in `BACKUP.md`: quit opencode first, then restore, then relaunch.

## Verification

Before committing:

```bash
jq empty reference/opencode.template.json   # config parses
for f in scripts/*.sh; do bash -n "$f"; done # scripts parse
python3 scripts/validate-skills.py           # skill resources present
python3 -m unittest discover -s tests -v     # validator behavior
```

If you changed anything `activate.sh` installs, run it in an isolated temporary HOME and confirm "Config JSON valid." Use a copied checkout without sibling plugin installers and an already-present/stubbed `rea` CLI to avoid unrelated global package installation. Never replace the live provider key with a test value.
