#!/usr/bin/env bash
# Probes local and LAN LLM inference servers (llama-server, vLLM, Ollama, Strata)
# Returns JSON status: {"available": bool, "endpoint": string, "model": string, "latency_ms": number}
set -uo pipefail

CONFIG_FILE="${HOME}/.gemini/config/hybrid-routing.json"
CUSTOM_ENDPOINT=""

if [ -f "$CONFIG_FILE" ]; then
  CUSTOM_ENDPOINT=$(jq -r '.local_endpoint // empty' "$CONFIG_FILE" 2>/dev/null || true)
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
    MODEL_ID=$(echo "$RESPONSE" | jq -r '.data[0].id // .models[0].name // "unknown"' 2>/dev/null || echo "active")
    LATENCY=$(( END_TIME - START_TIME ))
    echo "{\"available\": true, \"endpoint\": \"$ep\", \"model\": \"$MODEL_ID\", \"latency_ms\": $LATENCY}"
    exit 0
  fi
done

echo "{\"available\": false, \"endpoint\": null, \"model\": null, \"latency_ms\": null}"
exit 1
