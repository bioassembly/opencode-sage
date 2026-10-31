#!/usr/bin/env bash
# Feature flag toggle for Hybrid Routing (Developmental Skill)
# Usage: ./toggle.sh [on|off|status|set-endpoint <url>]
set -euo pipefail

CONFIG_FILE="${HOME}/.gemini/config/hybrid-routing.json"
mkdir -p "$(dirname "$CONFIG_FILE")"

if [ ! -f "$CONFIG_FILE" ]; then
  cat <<'EOF' > "$CONFIG_FILE"
{
  "enabled": false,
  "local_endpoint": "http://10.4.100.102:8080/v1",
  "fallback_to_frontier": true,
  "prefer_subagent_tier": "flash_lite",
  "log_routing_decisions": true
}
EOF
fi

ACTION="${1:-status}"

case "$ACTION" in
  on|enable|1)
    TMP=$(mktemp)
    jq '.enabled = true' "$CONFIG_FILE" > "$TMP" && mv "$TMP" "$CONFIG_FILE"
    echo "✓ Hybrid Routing ENABLED (Developmental mode active)"
    ;;
  off|disable|0)
    TMP=$(mktemp)
    jq '.enabled = false' "$CONFIG_FILE" > "$TMP" && mv "$TMP" "$CONFIG_FILE"
    echo "✓ Hybrid Routing DISABLED (100% Frontier execution)"
    ;;
  status)
    ENABLED=$(jq -r '.enabled' "$CONFIG_FILE")
    ENDPOINT=$(jq -r '.local_endpoint' "$CONFIG_FILE")
    PROBE=$(bash "$(dirname "$0")/probe_worker.sh" 2>/dev/null || echo '{"available": false}')
    WORKER_STATUS=$(echo "$PROBE" | jq -r 'if .available then "ONLINE (" + .endpoint + ", " + .model + ", " + (.latency_ms|tostring) + "ms)" else "OFFLINE" end')
    echo "=== Hybrid Routing Status ==="
    echo "State:          $([ "$ENABLED" = "true" ] && echo "ENABLED (Hybrid active)" || echo "DISABLED (Pure frontier)")"
    echo "Local Endpoint: $ENDPOINT"
    echo "Worker Probe:   $WORKER_STATUS"
    echo "Config Path:    $CONFIG_FILE"
    ;;
  set-endpoint)
    NEW_URL="${2:?Missing endpoint URL}"
    TMP=$(mktemp)
    jq --arg url "$NEW_URL" '.local_endpoint = $url' "$CONFIG_FILE" > "$TMP" && mv "$TMP" "$CONFIG_FILE"
    echo "✓ Local endpoint set to $NEW_URL"
    ;;
  *)
    echo "Usage: $0 [on|off|status|set-endpoint <url>]"
    exit 1
    ;;
esac
