#!/usr/bin/env bash
# Install the staged harness from reference/ into ~/.config/opencode (global scope).
# - Backs up existing config + agents/commands/skills to a timestamped dir
# - Substitutes __BASE_URL__, __UNSLOTH_API_KEY__ and __MEMORY_PATH__
# - Cleanly syncs reference/{opencode.template.json,agents,commands,skills,AGENTS.md}
# - Supports --with-rea to opt into the ~140-tool REA reverse-engineering MCP
# Idempotent. Rollback path is printed at the end.
set -euo pipefail
umask 077

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/reference"
DST="$HOME/.config/opencode"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DST/backup-$TS"
KEY=""
BASE_URL=""
WITH_REA=false
MEMORY_PATH="${MEMORY_PATH:-$DST/memory.json}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --key) KEY="${2:?--key requires a value}"; shift 2 ;;
    --base-url) BASE_URL="${2:?--base-url requires a value}"; shift 2 ;;
    --with-rea) WITH_REA=true; shift ;;
    *) echo "usage: $0 [--key <api-key>] [--base-url <base-url>] [--with-rea]" >&2; exit 1 ;;
  esac
done

mkdir -p "$DST" "$HOME/.local/bin"
ln -sfn "$REPO/scripts/doctor.sh" "$HOME/.local/bin/opencode-doctor"

# Extract existing key and base_url if not provided
if [[ -z "$KEY" && -f "$DST/opencode.json" ]]; then
  KEY="$(jq -r '.provider[]?.options.apiKey // empty' "$DST/opencode.json" 2>/dev/null | head -n1)"
fi
KEY="${KEY:-local-opencode}"

if [[ -z "$BASE_URL" && -f "$DST/opencode.json" ]]; then
  BASE_URL="$(jq -r '.provider[]?.options.baseURL // empty' "$DST/opencode.json" 2>/dev/null | head -n1)"
fi
BASE_URL="${BASE_URL:-http://127.0.0.1:8080/v1}"

# Preserve existing plugin list and hybrid-sage MCP before writing new config
PREV_PLUGINS="[]"
PREV_HS_MCP=""
if [[ -f "$DST/opencode.json" ]]; then
  PREV_PLUGINS="$(jq -c '.plugin // []' "$DST/opencode.json" 2>/dev/null || echo "[]")"
  PREV_HS_MCP="$(jq -c '.mcp["hybrid-sage"] // empty' "$DST/opencode.json" 2>/dev/null || true)"
fi

if [[ -f "$DST/opencode.json" ]]; then
  mkdir -p "$BACKUP"
  cp "$DST/opencode.json" "$BACKUP/"
  [[ -f "$DST/AGENTS.md" ]] && cp "$DST/AGENTS.md" "$BACKUP/"
  for d in agent agents command commands skill skills; do
    [ -d "$DST/$d" ] && cp -r "$DST/$d" "$BACKUP/"
  done
  echo "Backup created at: $BACKUP"

  # Prune old backups, retaining the 5 most recent
  mapfile -t BACKUP_DIRS < <(find "$DST" -maxdepth 1 -type d -name "backup-*" | sort)
  if [[ ${#BACKUP_DIRS[@]} -gt 5 ]]; then
    PRUNE_COUNT=$((${#BACKUP_DIRS[@]} - 5))
    for ((i=0; i<PRUNE_COUNT; i++)); do
      rm -rf "${BACKUP_DIRS[$i]}"
    done
    echo "[-] Pruned $PRUNE_COUNT old backup(s) (retaining latest 5)."
  fi
fi

echo "[-] Configuring opencode.json (BaseURL: $BASE_URL)..."
jq --arg key "$KEY" --arg mem "$MEMORY_PATH" --arg url "$BASE_URL" \
  'walk(if type == "string" and . == "__UNSLOTH_API_KEY__" then $key
        elif type == "string" and . == "__MEMORY_PATH__" then $mem
        elif type == "string" and . == "__BASE_URL__" then $url
        else . end)' \
  "$SRC/opencode.template.json" > "$DST/opencode.json"

# Merge preserved plugins, hybrid-sage MCP, and optional --with-rea MCP
TMP="$(mktemp)"
python3 - "$DST/opencode.json" "$PREV_PLUGINS" "$PREV_HS_MCP" "$WITH_REA" "$TMP" <<'PYEOF'
import json, sys
dst_path, prev_plugins_raw, prev_hs_raw, with_rea_raw, tmp_path = sys.argv[1:6]
with_rea = with_rea_raw.lower() in ("true", "1", "yes")
with open(dst_path, "r", encoding="utf-8") as f:
    cfg = json.load(f)
prev_plugins = json.loads(prev_plugins_raw)
cfg_plugins = cfg.setdefault("plugin", [])
for p in prev_plugins:
    if p not in cfg_plugins:
        cfg_plugins.append(p)
mcp = cfg.setdefault("mcp", {})
if prev_hs_raw.strip():
    mcp["hybrid-sage"] = json.loads(prev_hs_raw)
if with_rea:
    mcp["rea"] = {
        "type": "local",
        "command": ["npx", "-y", "rea-agents@6.4.0", "mcp"],
        "enabled": True,
        "timeout": 60000,
        "environment": {"REA_MCP_INPUT_SCHEMA_PROFILE": "compact"},
    }
with open(tmp_path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
PYEOF
if [[ -s "$TMP" ]]; then
  mv "$TMP" "$DST/opencode.json"
else
  rm -f "$TMP"
fi

# Auto-sync context limits from the loaded server model when reachable; keep template values if offline.
CTX="$(curl -s --max-time 4 -H "Authorization: Bearer $KEY" "$BASE_URL/models" 2>/dev/null | jq -r '[.data[] | select(.loaded==true or .status.value=="loaded") | (.meta.n_ctx // .context_length) // empty] | first // empty' 2>/dev/null || true)"
if [[ "$CTX" =~ ^[0-9]+$ ]]; then
  TMP="$(mktemp)"
  jq --argjson ctx "$CTX" '.provider.strata.models[]?.limit = {context: $ctx, output: $ctx}' "$DST/opencode.json" > "$TMP" && mv "$TMP" "$DST/opencode.json"
  echo "[-] Synced limits from server (context=output=$CTX)."
else
  echo "[-] Local server offline or context unreported; kept template limits."
fi

echo "[-] Syncing agents, commands, and skills (pruning retired entries)..."
rm -rf "$DST/agent" "$DST/command" "$DST/skills"
mkdir -p "$DST/agent" "$DST/command" "$DST/skills"
find "$SRC/agents" -name '*.md' -exec cp {} "$DST/agent/" \;
find "$SRC/commands" -name '*.md' -exec cp {} "$DST/command/" \;
find "$SRC/skills" -mindepth 1 -maxdepth 1 -type d | while read -r d; do
  cp -r "$d" "$DST/skills/"
done
if [[ -d "$SRC/skills.local" ]]; then
  find -L "$SRC/skills.local" -mindepth 1 -maxdepth 1 -type d | while read -r d; do
    cp -rL "$d" "$DST/skills/"
  done
  echo "[-] Synced machine-local skills from reference/skills.local/"
fi

# Ensure zero-overhead `rea` CLI binary is available when npm is present
if ! command -v rea &>/dev/null && [[ ! -x "$HOME/.local/bin/rea" ]] && command -v npm &>/dev/null; then
  echo "[-] Installing rea-agents@6.4.0 CLI for autonomous binary inspection..."
  npm install -g --silent rea-agents@6.4.0 || true
fi

# Update AGENTS.md
cp "$SRC/AGENTS.md" "$DST/AGENTS.md"
echo "[-] Synced $DST/AGENTS.md"

# Re-register optional sibling hybrid-sage plugin, skill, and commands if present
HS_INSTALL="$(cd "$REPO/../hybrid-sage" 2>/dev/null && pwd || true)/install-plugin.sh"
if [[ -f "$HS_INSTALL" ]]; then
  echo "[-] Synchronizing sibling hybrid-sage plugin..."
  bash "$HS_INSTALL"
fi

jq empty "$DST/opencode.json" && echo "Config JSON valid."
chmod 700 "$DST" 2>/dev/null || true
chmod 600 "$DST/opencode.json" 2>/dev/null || true
echo
echo "Installed to $DST. Quit and restart opencode to load."
[[ -d "$BACKUP" ]] && echo "Rollback: cp \"$BACKUP/opencode.json\" \"$DST/opencode.json\""
