# Operations Runbook

Daily driving the harness. All scripts are in [`scripts/`](../scripts/) and are idempotent unless noted.

## Before heavy GPU work

```bash
./scripts/gpu-prep.sh
```

Enables persistent mode and caps power at 320 W (RTX 3090). Prompts for sudo.

## Checking stack status

Inside opencode: `/gpu` — reports VRAM used/total, whether llama-server and Studio are up (PIDs only), and a one-line safety verdict.

From shell:

```bash
nvidia-smi --query-gpu=memory.used,memory.total,power.draw --format=csv,noheader
pgrep -af 'llama-server|unsloth'
```

**Iron rule:** never kill or signal `llama-server`, `unsloth`, or opencode processes; never start anything GPU-allocating while VRAM > 90%.

## Serving a new/fine-tuned model

After exporting a GGUF, it appears on Studio's `:8888/v1` automatically. Update only the model id in the config if it changed, then re-run `activate.sh` and restart opencode.

### Quant selection rule (RTX 3090, 24 GB)

Highest quant that fits with **zero RAM offload** → all remaining VRAM becomes context (target ≥ 72k). Speculative decoding stays off (its VRAM buys more context instead). Vision layers off unless needed (~1 GB back); if a task needs vision, drop one quant step (Q6 → Q5). Example: Qwen3.8-27B → UD-Q6 (~22.9 GB) → 72–76k context.

## Deploying config/skill/agent changes

1. Edit files in the staging area (`reference/` in this repo, or your `harness/` dir).
2. `./scripts/activate.sh` — backs up current config to `~/.config/opencode/backup-<timestamp>/`, installs, validates JSON.
3. Quit and restart opencode.

## Rollback

Full step-by-step restore instructions (full and selective): **[BACKUP.md](../BACKUP.md)**. Quick version:

```bash
BACKUP=~/.config/opencode/backup-<timestamp>
cp "$BACKUP/opencode.json" ~/.config/opencode/opencode.json
# restore agents/, commands/, skills/ from the same backup dir as needed
```

## Capturing fine-tune trajectories

Daily sessions are SFT training data in waiting — Studio exports a fine-tuned GGUF and it auto-appears on `:8888` (see [architecture.md](architecture.md)). Keep keeper sessions:

```bash
scripts/export-trajectory.sh              # list recent sessions (id, tokens, title)
scripts/export-trajectory.sh <session-id> ~/ml/trajectories
```

Writes one JSONL per session (messages + tool parts, time-ordered) plus a `manifest.csv`. **Review for secrets before training or sharing** — transcripts contain everything typed.

## Housekeeping

- Prune old backups periodically: `ls -dt ~/.config/opencode/backup-* | tail -n +4 | xargs rm -rf` (keeps 3 newest).
- Keep `REGISTRY.md` appended whenever a skill is acquired.
- Re-check `limit.context` against real `n_ctx` after any server change.
