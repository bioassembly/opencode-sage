# Operations Runbook

Daily driving the harness. All scripts live in [`scripts/`](../scripts/) and are idempotent.

## Deploying config, skill, or agent changes

1. Edit files in the staging area (`reference/` in this repo).
2. `./scripts/activate.sh` — backs up current config to `~/.config/opencode/backup-<timestamp>/`, syncs agents/commands/skills (pruning retired entries), validates JSON, and synchronizes optional `hybrid-sage` if present.
   - Add `--with-rea` only when reverse-engineering binaries/APKs with REA MCP (~140 tools).
   - Pass `--base-url <url>` and `--key <api-key>` to point OpenCode at any local or remote OpenAI-compatible provider.
3. Quit and restart `opencode` (config is read at startup).

## Checking harness & hardware status

- Inside `opencode`: `/doctor` (or `bash scripts/doctor.sh` from shell) checks `opencode.json` permissions, provider reachability, remote MCPs, LSP binaries, and skill/agent parity.
- If running a local GPU inference server (`llama-server`, `ollama`, `vllm`): use `nvtop` in a terminal to monitor VRAM/utilization directly; avoid killing or signaling active model server processes mid-session.

## Rollback

Full step-by-step restore instructions: **[BACKUP.md](../BACKUP.md)**. Quick version:

```bash
BACKUP=~/.config/opencode/backup-<timestamp>
cp "$BACKUP/opencode.json" ~/.config/opencode/opencode.json
# restore agent/, command/, skills/ from the same backup dir as needed
```

## Continuous Passive Enhancement (Zero-Weight-Touch)

Instead of weight-level LoRA/SFT fine-tuning on small session dumps (which risks quantization degradation and catastrophic forgetting), connect [`hybrid-sage`](https://github.com/bioassembly/hybrid-sage): 2-strike escalations (`escalate_task`) consult frontier models in read-only plan mode and append distilled root-cause invariants to `~/.config/opencode/lessons.jsonl`, enhancing future local runs cleanly at the prompt/memory layer.

## Housekeeping

- Backups auto-prune to the 5 newest on every `activate.sh` run (or run `bash scripts/doctor.sh --prune-backups`).
- Keep `reference/skills/REGISTRY.md` appended whenever a new skill is vetted and added.
- Re-run `activate.sh` after changing model servers so `limit.context` syncs automatically from `/models`.
