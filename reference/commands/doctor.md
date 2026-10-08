---
description: One-shot health check of the whole harness — MCP servers, LSPs, model server, context-limit match, backups, key permissions. Read-only.
agent: build
---

Run this harness health check:

1. Execute the doctor script:
   `bash ~/opencode-sage/scripts/doctor.sh`
2. Also check if the live model context limit matches:
   Compare `limit.context` in `~/.config/opencode/opencode.json` against the server's real context if reachable.
3. Report the result table concisely with PASS/FAIL rows and a single overall verdict.

CRITICAL: report only. Do not fix, prune, or restart anything yourself unless asked.
