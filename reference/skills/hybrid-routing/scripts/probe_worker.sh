#!/usr/bin/env bash
# Probes Tier 3 local/LAN LLM inference servers (llama-server, vLLM, Ollama, Strata)
# Returns JSON status: {"available": bool, "endpoint": string, "model": string, "latency_ms": number}
set -uo pipefail

CUSTOM_ENDPOINT="${LOCAL_LLM_ENDPOINT:-}"
CONFIG_GEMINI="${HOME}/.gemini/config/hybrid-routing.json"
CONFIG_OPENCODE="${HOME}/.config/opencode/hybrid-routing.json"

if [ -z "$CUSTOM_ENDPOINT" ] && [ -f "$CONFIG_GEMINI" ]; then
  CUSTOM_ENDPOINT=$(jq -r '.local_endpoint // empty' "$CONFIG_GEMINI" 2>/dev/null || true)
fi
if [ -z "$CUSTOM_ENDPOINT" ] && [ -f "$CONFIG_OPENCODE" ]; then
  CUSTOM_ENDPOINT=$(jq -r '.local_endpoint // empty' "$CONFIG_OPENCODE" 2>/dev/null || true)
fi

ENDPOINTS=(
  "${CUSTOM_ENDPOINT}"
  "http://localhost:8080/v1"
  "http://10.4.100.102:8080/v1"
  "http://localhost:11434/v1"
)

for ep in "${ENDPOINTS[@]}"; do
  [ -z "$ep" ] && continue
  START_TIME=$(date +%s%3N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1000))')
  RESPONSE=$(curl -s -f --max-time 2 "${ep}/models" 2>/dev/null || true)
  END_TIME=$(date +%s%3N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1000))')
  
  if [ -n "$RESPONSE" ]; then
    MODEL_ID=$(echo "$RESPONSE" | jq -r '.data[0].id // .models[0].name // "local-worker"' 2>/dev/null || echo "local-worker")
    LATENCY=$(( END_TIME - START_TIME ))
    echo "{\"available\": true, \"endpoint\": \"$ep\", \"model\": \"$MODEL_ID\", \"latency_ms\": $LATENCY}"
    exit 0
  fi
done

echo "{\"available\": false, \"endpoint\": null, \"model\": null, \"latency_ms\": null}"
exit 1
