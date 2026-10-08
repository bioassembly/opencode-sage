# Backup & Restore

How to back up and restore the opencode harness. Written so a human or an AI agent can execute it verbatim.

## Where backups live

Every run of `activate.sh` snapshots whatever it is about to overwrite into a timestamped directory:

```
~/.config/opencode/backup-<YYYYMMDD-HHMMSS>/
├── opencode.json      ← the previous global config (contains your API key)
├── AGENTS.md          ← previous global agent protocol (if one existed)
├── agent/             ← previous subagents (reviewer, bioinformatician, skeptic…)
├── command/           ← previous slash commands (/gpu, /doctor, /review…)
└── skills/            ← previous skills
```

Only directories that existed at backup time are included. The harness source (`harness/` in the playground) is never modified by the installer — it is the source of truth, not a backup target.

## List available backups

```bash
ls -dt ~/.config/opencode/backup-*        # newest first
```

## Restore (the part you're here for)

**0. Before restoring:** if opencode is running, quit it. Config files are only read at startup, so restoring while it runs does nothing visible until restart — but restoring half-applied state mid-session is confusing. Quit first, restore second, relaunch third.

**Full restore** — put everything back exactly as it was at backup time:

```bash
BACKUP=~/.config/opencode/backup-<YYYYMMDD-HHMMSS>   # pick one from the list above

cp "$BACKUP/opencode.json" ~/.config/opencode/opencode.json
rm -rf ~/.config/opencode/agent ~/.config/opencode/command ~/.config/opencode/skills
cp -r "$BACKUP/agent"   ~/.config/opencode/agent    2>/dev/null || true
cp -r "$BACKUP/command" ~/.config/opencode/command  2>/dev/null || true
cp -r "$BACKUP/skills"  ~/.config/opencode/skills   2>/dev/null || true

chmod 700 ~/.config/opencode
chmod 600 ~/.config/opencode/opencode.json
```

Then start opencode. Done — you are back to the exact pre-change state.

**Selective restores** — only what broke:

```bash
# Only the config (model/provider/MCP changes went wrong):
cp "$BACKUP/opencode.json" ~/.config/opencode/opencode.json

# Only skills (a new skill misbehaves):
rm -rf ~/.config/opencode/skills && cp -r "$BACKUP/skills" ~/.config/opencode/skills

# Only agents or commands:
rm -rf ~/.config/opencode/agent   && cp -r "$BACKUP/agent"   ~/.config/opencode/agent
rm -rf ~/.config/opencode/command && cp -r "$BACKUP/command" ~/.config/opencode/command
```

Restart opencode after any of these.

## Verify a restore worked

```bash
jq empty ~/.config/opencode/opencode.json && echo "config valid"
ls ~/.config/opencode/skills | wc -l       # compare with expected skill count
```

Then in opencode: `/doctor` should report all-PASS on server, MCPs, and LSPs.

## Create a manual backup (before risky experiments)

```bash
TS=$(date +%Y%m%d-%H%M%S)
mkdir -p ~/.config/opencode/backup-manual-$TS
cp ~/.config/opencode/opencode.json ~/.config/opencode/backup-manual-$TS/
for d in agent command skills; do
  [ -d ~/.config/opencode/$d ] && cp -r ~/.config/opencode/$d ~/.config/opencode/backup-manual-$TS/
done
echo "backup: ~/.config/opencode/backup-manual-$TS"
```

Restore from it identically (set `BACKUP=...backup-manual-$TS`).

## Prune old backups

Backups each contain a keyed config — keep a few, delete the rest:

```bash
ls -dt ~/.config/opencode/backup-* | tail -n +4 | xargs rm -rf   # keep 3 newest
```

## What is NOT covered by these backups

| Item | Why | Protect it by |
|---|---|---|
| `harness/` staging dir | source of truth; installer never touches it | commit to git |
| `harness/memory.json` | memory MCP graph, written at runtime | include in your own backups/git |
| `~/.unsloth/`, models, llama.cpp builds | GB-scale binaries | re-downloadable; document versions |
| This repo (`sage-cookbook/`) | documentation + reference copies | push to GitHub |

Rule of thumb: **backups roll back the installed harness; git preserves its source.**
