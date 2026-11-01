---
name: token-efficiency
description: Context-window and token budget discipline for long sessions, large codebases, RAG-style retrieval questions, or when responses degrade late in a session.
---

# Token Efficiency Discipline

The context window is the scarcest resource. Every token spent on noise is one not spent on your code.

## Retrieval ladder — cheapest first, escalate only on miss

1. **Targeted grep/glob** with tight patterns before any file read. Never read a file just to "see what's there" — grep for the symbol.
2. **Read slices**: `offset`/`limit` around the match, not whole files. Multi-thousand-line reads waste attention budget.
3. **LSP go-to-definition** over reading module by module when tracing calls.
4. **context7 / deepwiki MCP** for library APIs and repository docs instead of reading vendored docs or guessing.
5. **Full-file read** only after 1–4 fail or for files <100 lines.

Example shapes:

- Bad: read `src/auth/service.ts` (1,800 lines) to find where tokens refresh.
- Good: `grep -rn "refresh" src/auth/` → hit at `service.ts:412` → read with offset 395, limit 40 (~50 tokens instead of ~15k).

## Output hygiene

- Tool output is capped (200 lines / 16 KB) by config; if a command needs targeted context, pipe through `grep -A5 -B2`, `head -50`, or `wc -l` first.
- Long exploratory work goes in a subagent (`explore`/task tool) so its transcript never enters the main session — only the distilled answer does.

## Session shape

- One task per session; `/compact` between tasks.
- Any task expected to outlive ~30 minutes or one compaction cycle gets a `NOTES.md` beside the work: decisions made, dead ends, next step. After compaction or a fresh session, read it first.
- Paste nothing >100 lines into chat; write it to a file and reference it.
- Re-state decisions tersely ("using X because Y") rather than re-pasting prior analysis.

## RAG honesty

For a single repository, grep-first + LSP retrieval beats vector RAG: exact-match search has ~100% precision, whereas embeddings inject near-misses that cost more tokens than they save. Reach for semantic retrieval (`context7` or `deepwiki`) only when exploring external documentation where exact symbol names are not yet known.
