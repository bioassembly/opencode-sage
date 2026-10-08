#!/usr/bin/env bash
# Pin floating MCP versions in the staged opencode config to exact resolved
# versions. Fixes supply-chain drift: npx @latest fetches whatever a tag points
# at that day; pinning makes every cold start reproducible.
# Usage: ./pin-mcp.sh [path/to/opencode.template.json]
set -euo pipefail

CFG="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../reference" && pwd)/opencode.template.json}"
command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }
command -v npm >/dev/null || { echo "npm required" >&2; exit 1; }

resolve() { # package[@tag] -> package@exact-version
  local pkg="$1" spec="$1"
  [[ "$pkg" == *@* ]] || spec="$pkg@latest"
  npm view "$spec" version 2>/dev/null | tail -n1
}

for pkg in "@modelcontextprotocol/server-sequential-thinking" "@playwright/mcp" "@modelcontextprotocol/server-memory"; do
  ver="$(resolve "$pkg")"
  [ -n "$ver" ] || { echo "could not resolve $pkg" >&2; exit 1; }
  echo "pinning $pkg -> $ver"
  jq --arg pkg "$pkg" --arg ver "$ver" '
    .mcp |= with_entries(
      if .value.type == "local" and (.value.command | index("npx")) then
        .value.command |= map(if . == $pkg or startswith($pkg + "@") then $pkg + "@" + $ver else . end)
      else . end)
  ' "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
done

echo "done. Review the diff, re-run activate.sh, restart opencode."
