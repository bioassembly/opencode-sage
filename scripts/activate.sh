#!/usr/bin/env bash
# Install the staged harness from reference/ into ~/.config/opencode (global scope).
# - Backs up existing config + agents/commands/skills to a timestamped dir
# - Substitutes __BASE_URL__, __UNSLOTH_API_KEY__ and __MEMORY_PATH__
# - Copies reference/{opencode.template.json,agents,commands,skills} into place
# - Updates reference/AGENTS.md
# Idempotent. Rollback path is printed at the end.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/reference"
DST="$HOME/.config/opencode"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DST/backup-$TS"
KEY=""
BASE_URL=""
MEMORY_PATH="${MEMORY_PATH:-$DST/memory.json}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --key) KEY="${2:?--key requires a value}"; shift 2 ;;
    --base-url) BASE_URL="${2:?--base-url requires a value}"; shift 2 ;;
    *) echo "usage: $0 [--key <api-key>] [--base-url <base-url>]" >&2; exit 1 ;;
  esac
done

mkdir -p "$DST"

# Extract existing key and base_url if not provided
if [[ -z "$KEY" && -f "$DST/opencode.json" ]]; then
  KEY="$(jq -r '.provider[]?.options.apiKey // empty' "$DST/opencode.json" 2>/dev/null | head -n1)"
fi
[[ -n "$KEY" ]] || { echo "No key available: pass --key <value> (any non-empty string for a local server)." >&2; exit 1; }

if [[ -z "$BASE_URL" && -f "$DST/opencode.json" ]]; then
  BASE_URL="$(jq -r '.provider[]?.options.baseURL // empty' "$DST/opencode.json" 2>/dev/null | head -n1)"
fi
BASE_URL="${BASE_URL:-http://10.4.100.102:8888/v1}"

if [[ -f "$DST/opencode.json" ]]; then
  mkdir -p "$BACKUP"
  cp "$DST/opencode.json" "$BACKUP/"
  [[ -f "$DST/AGENTS.md" ]] && cp "$DST/AGENTS.md" "$BACKUP/"
  for d in agent agents command commands skill skills; do
    [ -d "$DST/$d" ] && cp -r "$DST/$d" "$BACKUP/"
  done
  echo "Backup created at: $BACKUP"
fi

echo "[-] Configuring opencode.json (BaseURL: $BASE_URL)..."
jq --arg key "$KEY" --arg mem "$MEMORY_PATH" --arg url "$BASE_URL" \
  'walk(if type == "string" and . == "__UNSLOTH_API_KEY__" then $key
        elif type == "string" and . == "__MEMORY_PATH__" then $mem
        elif type == "string" and . == "__BASE_URL__" then $url
        else . end)' \
  "$SRC/opencode.template.json" > "$DST/opencode.json"

echo "[-] Installing agents, commands, and skills..."
for pair in "agents:agent" "commands:command" "skills:skills"; do
  src="${pair%%:*}"; dst="${pair##*:}"
  mkdir -p "$DST/$dst"
  case "$src" in
    skills)
      # Copy each skill directory whole (SKILL.md + bundled scripts), minus REGISTRY.md
      find "$SRC/$src" -mindepth 1 -maxdepth 1 -type d ! -name 'REGISTRY.md' | while read -r d; do
        rm -rf "$DST/$dst/$(basename "$d")"
        cp -r "$d" "$DST/$dst/"
      done
      ;;
    *)
      find "$SRC/$src" -name '*.md' | while read -r f; do cp "$f" "$DST/$dst/"; done
      ;;
  esac
done

# Update AGENTS.md
cp "$SRC/AGENTS.md" "$DST/AGENTS.md"
echo "[-] Synced $DST/AGENTS.md"

jq empty "$DST/opencode.json" && echo "Config JSON valid."
chmod 700 "$DST" 2>/dev/null || true
chmod 600 "$DST/opencode.json" 2>/dev/null || true
echo
echo "DONE. Now quit and restart opencode for changes to load."
if [[ -f "$BACKUP/opencode.json" ]]; then
  echo "Rollback if needed:"
  echo "  cp $BACKUP/opencode.json $DST/opencode.json"
fi
exit 0
