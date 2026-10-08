# Security Notes

This setup runs a local model — data stays on the machine — but the harness itself touches secrets and system state. Rules below are part of the deployment contract. For agentic-specific threats (MCP tool poisoning, prompt injection, supply chain), see [docs/security-hardening.md](docs/security-hardening.md).

## API keys

- `reference/opencode.template.json` contains **only** the placeholder `__UNSLOTH_API_KEY__`. Never replace it with a real key inside this repo.
- Keys are injected at install time by `scripts/activate.sh` (via `jq`) from your environment or the `--key` flag. They live in exactly one place: `~/.config/opencode/opencode.json`.
- For a purely local server the key is a formality (any non-empty string works) — but use a real secret if you ever point `baseURL` at anything remote.
- Never paste keys into chat, scripts, logs, or `memory.json`.

## File hygiene

```bash
chmod 700 ~/.config/opencode
chmod 600 ~/.config/opencode/opencode.json   # contains the key
```

Backup dirs (`~/.config/opencode/backup-*`) contain copies of the keyed config — prune them periodically and never commit them.

## GPU process safety

VRAM contention doesn't just fail — it can kill your live session's server mid-write. This deployment runs exactly one model process (via Unsloth Studio). Never start a second GPU-allocating process while it's up, and never kill or signal `llama-server`, `unsloth`, or opencode processes. Check `/gpu` first; if VRAM > 90%, wait.

## Supply chain

- MCP servers launch via `npx -y`/`uvx`, which fetch packages at startup. First runs hit the network; pin versions (especially `@playwright/mcp@latest`) for reproducibility.
- Skills acquired online must be logged in `reference/skills/REGISTRY.md` with source — unvetted instruction files are a prompt-injection vector. Read every SKILL.md before installing it.

## What this setup deliberately does NOT protect against

- A malicious model output convincing the agent to run destructive shell commands — mitigated by per-agent permissions (`edit: deny`, `bash: ask`) but not eliminated. Review before approving.
- Other users on the machine — this is single-user hardening, not multi-tenant security.
