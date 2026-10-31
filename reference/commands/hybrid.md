---
description: "Activate 3-tier cognitive routing: Argon for concepts, 3.8 Flash for execution, local AI for mechanical tasks"
agent: build
---

Activate and display the 3-Tier Adaptive Cognitive Routing assessment:

1. Probe Tier 3 local worker status:
   ```bash
   bash ~/.config/opencode/skills/hybrid-routing/scripts/probe_worker.sh 2>/dev/null || \
   bash ~/opencode-sage/reference/skills/hybrid-routing/scripts/probe_worker.sh
   ```
2. Report the active 3-tier matrix:
   - **Tier 1 (Frontier / Conceptual):** Gemini 4 Argon (`argon` / `pro`)
     * High-entropy architecture, domain modeling, ADR trade-offs
     * Pre-implementation adversarial red-teaming (`skeptic`)
     * Deep non-deterministic root-cause debugging & DAG topological flows
   - **Tier 2 (Fast Frontier / Balanced Execution):** Gemini 3.8 Flash (`flash` / `inherit`)
     * Multi-file implementation, test suite authoring, refactoring
     * Working diff review (`reviewer`)
     * Active tool orchestration (Serena LSP navigation, command running)
   - **Tier 3 (Local Worker / Deterministic):** Local LLM (llama-server / vLLM / Ollama at `http://10.4.100.102:8080/v1` or `localhost:8080`)
     * Deterministic lint error fixes, code formatting, imports
     * Schema translations (JSON to TS/YAML/Pydantic)
     * Repetitive boilerplate scaffolding & log parsing (0 cloud tokens billed)
     * *Probe Status:* Online (endpoint + latency) or Offline (auto-cascades to Tier 2 Flash)
3. For the user's ongoing task or plan, automatically partition work items across these 3 tiers to maximize cognitive depth while minimizing token burn.
