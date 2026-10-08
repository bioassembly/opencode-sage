#!/usr/bin/env bash
# Apply GPU power limits before heavy training/inference.
# Default (320 W) is tuned for an NVIDIA RTX 3090 (24 GB) — its stock limit is
# 350 W; 320 W sheds ~30 W of heat for negligible performance loss.
# On any other GPU, pass an appropriate wattage: GPU_POWER_LIMIT=<W> ./gpu-prep.sh
# Requires sudo; prompts for password.
set -euo pipefail

LIMIT="${GPU_POWER_LIMIT:-320}"

GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n1)
if [[ "$GPU_NAME" != *"RTX 3090"* ]]; then
  echo "NOTE: detected '$GPU_NAME', not an RTX 3090 — the ${LIMIT} W default may be wrong." >&2
  echo "      Re-run with GPU_POWER_LIMIT=<wattage> for your card." >&2
fi

sudo nvidia-smi -pm 1
sudo nvidia-smi -pl "$LIMIT"
nvidia-smi --query-gpu=name,power.limit --format=csv,noheader
