---
description: Show GPU and local-inference server status (VRAM, power, running model processes). Read-only.
agent: build
---

Check the local AI stack status. Run these read-only commands and summarize:

1. `nvidia-smi --query-gpu=memory.used,memory.total,power.draw,power.limit,temperature.gpu --format=csv,noheader`
2. `ps aux | grep -E 'llama-server|unsloth' | grep -v grep`

Then report:
- VRAM used / total (and whether a model is loaded)
- Whether llama-server and unsloth studio are up (PIDs only)
- One line: is it safe to start another GPU process? (no if VRAM used > 90%)

CRITICAL: report only. Never kill, restart, or signal any of these processes — killing them terminates the live model session.
