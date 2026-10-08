# Troubleshooting

Symptom → lever. Adjust in the staged config, re-run `scripts/activate.sh`, restart opencode.

| Symptom | Likely cause | Lever |
|---|---|---|
| Model "forgets" instructions late in session | Context overflow / silent truncation | Lower `tool_output` caps; verify `limit.context` ≤ real server `n_ctx`; check compaction fired (`/compact`) |
| Tool-call JSON malformed, agent loop breaks | Temperature too high for tool use | `build.temperature` → 0.2; confirm `tool_call: true` on the model entry |
| Slow, rambly answers | Thinking mode overhead | Disable Qwen3.8 thinking (`/no_think` or proxy setting) |
| Repetition loops in reasoning | Temperature too low for reasoning mode | Raise toward 0.6–0.7 (Qwen3.8-recommended when thinking is on) |
| Context full constantly | Standing token tax too high | Reduce MCP servers (each adds schemas to every request); shorten AGENTS.md files |
| Agent hallucinates library APIs | Stale training data, no docs retrieval | Force context7 usage before writing against any external API |
| Repeated bad edits of same file | No verification feedback | Confirm LSP servers installed and attached (`lsp: true`, binaries in `~/.local/bin`) |
| Config changes have no effect | opencode reads config only at startup | Quit and restart opencode after `activate.sh` |
| MCP tools missing from session | Server failed to start (npx/uvx fetch issue) | Run its command manually to see the error; check network for first-time npx downloads |
| Model fails to load / OOM in Studio | Context or quant too large for 24 GB VRAM | Lower the context size in Studio, or drop one quant step (UD-Q6 → Q5). Never free VRAM by offloading layers to RAM — throughput collapses to ~2 tok/s |

## Diagnostic order

1. `/gpu` or `nvidia-smi` — is anything actually running? How full is VRAM?
2. `curl -s http://127.0.0.1:<port>/props | jq '.default_generation_settings.n_ctx'` — what does the server *really* offer?
3. Compare with config `limit.context` — mismatch explains most "amnesia" reports.
4. Check `~/.config/opencode/backup-*/` — did a recent activate.sh change something you didn't expect?
