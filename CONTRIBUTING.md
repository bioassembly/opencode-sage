# Contributing to sage-cookbook

Docs + staged config for a local AI coding workstation. No application code, no test suite — content is Markdown, one JSON config template, and four bash scripts.

## Core workflow: stage → activate → restart

`reference/` is the source of truth; `scripts/activate.sh` installs it into `~/.config/opencode`.

1. Edit under `reference/` (config template, agents/, commands/, skills/) or `docs/`.
2. Re-run `./scripts/activate.sh --key <any-non-empty-string>` — idempotent; auto-backs up live config and prints the rollback path.
3. Restart opencode — config is read only at startup.

Never edit `~/.config/opencode/` directly: the next `activate.sh` run overwrites it.

## Before opening a PR

```bash
jq empty reference/opencode.template.json   # config parses
bash -n scripts/*.sh                        # scripts parse
```

If you changed anything `activate.sh` installs, actually run it (`--key x`) and confirm `Config JSON valid.` CI runs exactly these checks.

## Hard rules

- **Secrets never enter the repo.** The config template keeps the literal `__UNSLOTH_API_KEY__` placeholder; keys are injected at install time.
- **No `@latest` in MCP commands.** After changing MCP package versions, run `./scripts/pin-mcp.sh`, then re-run `activate.sh`.
- **Online-acquired skills must be vetted and registered** (append-only) in `reference/skills/REGISTRY.md` with source — unvetted instruction files are a prompt-injection vector.
- **Log every harness change** in `IMPROVEMENTS.md` (append-only: what, why, source).
- "Qwen3.8-27B" is the intentional model name used consistently across all docs — do not "correct" it.

## PR style

Small, one logical change per PR, using the PR template checklist. Docs follow the existing voice: declarative, evidence-linked, tables over prose where possible.
