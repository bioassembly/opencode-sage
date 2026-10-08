# Quantization & VRAM Allocation Strategy

The governing principle: **quality-per-token beats token-count** — run the highest-fidelity quant that fits, then spend every remaining megabyte of VRAM on context.

## The decision procedure (RTX 3090, 24 GB)

```
1. Pick the largest quant whose weights fit with NO RAM offload
   └─ offloading even one layer to RAM tanks tok/s; full GPU residency is non-negotiable
2. Everything left after weights = KV cache budget = your context size
3. Set the minimum acceptable context (here: 72k). If a quant can't reach it, drop one step.
4. Speculative decoding: OFF — its draft model costs VRAM you'd rather spend on context
5. Vision layers: OFF unless the task needs images
   └─ vision off frees ~1 GB → more context
   └─ if the task needs vision, drop the quant one step (Q6 → Q5) and re-run steps 2–3
```

## Worked example: Qwen3.8-27B on RTX 3090

| Choice | Weights | Context achieved | Notes |
|---|---|---|---|
| **UD-Q6, vision off** ← default | ~22.9 GB | **72–76k** | Best quality that fits; dynamic quants keep quality near Q8 |
| Q5, vision on | smaller | fits + vision | Only when the task actually processes images |
| Anything with offload | — | — | Rejected: offload destroys throughput |

## Why "highest Q possible" is right here

Context can be *compensated* by harness discipline (retrieval ladder, compaction, subagents — see [context-engineering.md](context-engineering.md)); quantization loss cannot be compensated by anything. So maximize weights fidelity first, then buy context with what's left, then let the harness make 72k behave like much more.

## Rules of thumb

- Dynamic/unsloth dynamic quants (UD-Q*) beat static quants at the same bit-width — uneven bit allocation protects sensitive layers.
- Verify real context after any change: `curl -s http://127.0.0.1:8888/v1/models` for Studio, or Studio's own dashboard; keep config `limit.context` ≤ the real value.
- Re-check VRAM headroom after enabling any new feature (vision, tools, long system prompts) — features silently eat the KV budget.
- If you upgrade GPUs, re-run this procedure; don't carry over numbers.
