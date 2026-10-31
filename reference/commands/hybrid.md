---
description: "Toggle or inspect developmental hybrid cognitive tier routing (frontier vs local AI workers)"
agent: build
---

Toggle or inspect developmental hybrid cognitive tier routing:

1. Determine the desired action from user input (`status`, `on`, `off`, `set-endpoint <url>`). Default to `status` if no argument is specified.
2. Locate the toggle script:
   - Check `~/.config/opencode/skills/hybrid-routing/scripts/toggle.sh`
   - Or `~/opencode-sage/reference/skills/hybrid-routing/scripts/toggle.sh`
   - Or `~/.gemini/config/skills/hybrid-routing/scripts/toggle.sh`
3. Execute the toggle script with the specified action:
   - Status: `bash <toggle.sh> status`
   - Enable: `bash <toggle.sh> on`
   - Disable: `bash <toggle.sh> off`
   - Set endpoint: `bash <toggle.sh> set-endpoint <url>`
4. Report:
   - Current routing state (`ENABLED` / `DISABLED`)
   - Local worker endpoint URL and probe status (latency / reachable)
   - Cognitive tier summary:
     * **Tier 1 (Frontier):** Architecture, pre-implementation red-teaming (`skeptic`), deep debugging, critical code review (`reviewer`).
     * **Tier 2 (Local Worker):** Deterministic mechanical edits, regex/boilerplate conversions, syntax formatting, test logs.
   - Clarify that fallback to frontier or `flash_lite` is always automatic if local workers are unreachable.
