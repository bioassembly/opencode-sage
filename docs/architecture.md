# Architecture

## 1. The stack, end to end

```
opencode session
  │  provider: workplace-ai (OpenAI-compatible client)
  ▼
Unsloth Studio proxy — http://localhost:8888/v1
  │  (auth, model registry, fine-tune integration)
  ▼
llama-server (~/.unsloth/llama.cpp/)
  │  (GGUF inference, KV cache, /v1 endpoints)
  ▼
Qwen3.8-27B GGUF (Q6_K) · RTX 3090 (24 GB) · full GPU residency (-ngl 999, zero layers in RAM)
```

This deployment serves through **Unsloth Studio only**: opencode → :8888 → llama-server. Fine-tuned models appear automatically after export — no config change beyond the model id.

> Direct llama-server serving (`:8080`) is possible with any llama.cpp build but is not part of this deployment. If you ever add it, remember only one process may hold VRAM at a time.

## 2. The harness around the model

The model sees the world only through what fits in its context window. The harness is therefore a **context supply chain**, and every component is placed by token economics:

```
                    ┌──────────── CONTEXT SUPPLY CHAIN ────────────┐
 cheap ──────────►  │ grep/glob → sliced reads → LSP defs          │
                    │              ↓ on miss                       │
                    │ context7 MCP (docs)   memory MCP (facts)     │
                    │              ↓ last resort                   │
 expensive ◄──────  │ full-file reads   playwright (browser)       │
                    └──────────────────────────────────────────────┘
```

### Why grep-first instead of vector RAG?

For one machine and one repo, exact search has ~100% precision; embeddings inject near-misses that cost more tokens than they save. Semantic retrieval is used only where vocabulary is unknown *by design*: `context7` for library docs, `memory` for cross-session facts. True vector RAG over a private corpus remains an opt-in addition, never a default — it taxes every request.

### Why LSPs matter more for small models

A frontier model "knows" your API from training data. A local 27B does not, and cannot self-check. Language servers give it compiler-grade ground truth (types, definitions, diagnostics) inside the edit loop — the cheapest possible verification layer.

### Why output caps + prune-compaction

Uncapped tool dumps silently eat the window until the model "forgets" AGENTS.md mid-session. `tool_output` (200 lines / 16 KB) stops the inflow; `compaction { auto, prune, tail_turns: 12 }` garbage-collects old tool results instead of paying to summarize them.

## 3. Control plane: agents, skills, commands

| Layer | What it is | Instances here |
|---|---|---|
| **Subagents** | Separate system prompts + sampling + permissions | `reviewer` (read-only), `bioinformatician` (nf-core conventions); built-in `build`/`plan` retuned |
| **Skills** | On-demand instruction modules loaded by keyword match | 13 skills (see [components/skills.md](components/skills.md)) |
| **Commands** | User-invoked prompt macros | `/gpu` status · `/checkpoint` task state → NOTES.md |

Sampling is per-agent because tasks differ: review wants determinism (temp 0.2), planning wants a little latitude (0.4). Values in [components/agents.md](components/agents.md).

## 4. Deployment model: staging + installer

```
harness/  (source of truth, versionable)
   │  scripts/activate.sh
   │  - backs up existing config to ~/.config/opencode/backup-<ts>/
   │  - injects API key programmatically (jq) — key never lives in the repo
   ▼
~/.config/opencode/  (live config, read once at startup)
```

Rules that make this safe:

1. Edit the staged copy, re-run `activate.sh`, restart opencode.
2. Installation is idempotent; every run prints its backup path for rollback.
3. Secrets are injected at install time from the live environment, never stored in source.

This repo generalizes that pattern: `reference/` is the source of truth, `scripts/activate.sh` installs it anywhere.

## 5. Failure-mode map

| Failure class | Mechanism that prevents it |
|---|---|
| Context overflow → amnesia | tool_output caps, prune-compaction, retrieval ladder |
| API hallucination | context7 docs-on-demand, LSP diagnostics |
| Cross-session forgetting | memory MCP knowledge graph (`memory.json`) |
| Self-inflicted VRAM OOM | iron rule: one model process per GPU; check `/gpu` before starting anything |
| Bad edits shipped | reviewer subagent (edit denied, bash asks) |
| Config drift / bad deploy | timestamped backups + jq validation before commit |
| Thermal/power issues under load | gpu-prep.sh power limits (320 W cap on RTX 3090) |

## 6. Known trade-offs (accepted deliberately)

- **Plaintext local API key** — acceptable single-user; mitigations in [SECURITY.md](../SECURITY.md).
- **Five MCP servers = fixed token tax** — each was kept only if it earns its schema bytes; adding a sixth requires removing something.
- **Playwright is expensive** — reserved for JS-rendered targets; static content goes through `fetch`/curl.
- **Studio proxy adds a hop** — traded for zero-config model management and the fine-tune→serve loop.
