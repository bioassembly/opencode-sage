---
description: One-shot health check of the whole harness — MCP servers, LSPs, model server, context-limit match, backups, key permissions. Read-only.
agent: build
---

Run this harness health check:

1. Execute the doctor script (`~/.local/bin/opencode-doctor` installed by `activate.sh`):
   `opencode-doctor 2>/dev/null || bash ~/.local/bin/opencode-doctor`
2. Report the result concisely with PASS/INFO/WARN/FAIL rows and a single overall verdict.

CRITICAL: report only. Do not fix, prune, or restart anything yourself unless asked.
