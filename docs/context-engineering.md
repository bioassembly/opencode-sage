# Context Engineering

How this harness treats the context window as a **finite attention budget**, following [Anthropic's context-engineering guidance](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), adapted to a local 27B.

## The model

Every request pays attention to *everything* in the window: system prompt + tool schemas + AGENTS.md + history + tool results. Two failure modes as the window fills:

1. **Hard overflow** — instructions silently truncate; the model "forgets" its rules.
2. **Context rot** — technically-present but buried information degrades recall; prefill latency grows every turn.

The harness's job: keep only the smallest set of high-signal tokens in the window at each step.

## The three recovery layers (and which one is your bottleneck)

| Layer | Scope | Mechanism here | Use when |
|---|---|---|---|
| **Tool-result clearing** | single tool outputs | `tool_output` caps (200 lines / 16 KB) | outputs are huge but re-fetchable — always on |
| **Compaction** | whole transcript | `compaction {auto, prune, tail_turns: 12}` | session runs long; old turns summarized/pruned — always on |
| **Memory** | across sessions | memory MCP knowledge graph + NOTES.md files | facts must survive restarts |

All three are already enabled in stable. Beta adds the missing piece: **structured note-taking**.

## Structured note-taking (new in beta)

Anthropic's pattern: for long tasks, the agent maintains a `NOTES.md` beside the work — decisions made, dead ends, next step. After compaction or a fresh session, reading one small file restores full working state, without trusting a lossy summary to have kept it.

Rule: any task expected to outlive ~30 minutes or one compaction cycle gets a NOTES.md. Cost: one file. Benefit: compaction becomes lossless where it matters.

## Just-in-time retrieval over pre-loading

Don't pre-load anything the agent can fetch on demand. The retrieval ladder (token-efficiency skill) is exactly this: identifiers first (paths, symbols, queries), content only when needed. This is why grep-first beats vector RAG at this scale — embeddings pre-load near-misses; grep loads exact hits.

## Budget heuristics for a 72k–76k window

- System prompt + AGENTS.md + 5 MCP schemas: fixed tax (~5–8k). Fight every addition.
- Working set per task: aim ≤ 20k of live code/docs in window.
- History older than the current subtask: compactable. Tool results older than a few turns: prunable.
- If `/compact` fires more than once per hour of work, the task should be split or moved into a subagent.

## Subagents as context isolation

A subagent burns its own window and returns only the answer. Route: codebase surveys, doc dives, long explorations. Keep: implementation, review, anything needing conversation continuity.
