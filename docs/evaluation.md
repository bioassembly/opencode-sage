# Evaluating Harness Changes

Every tweak to this harness — a new skill, a sampling change, an MCP swap — is an experiment. Measure it or don't keep it. This doc defines the loop; the frozen cases live in [`evals/cases/`](../evals/) and the `skill-evaluation` skill provides the grading format.

## The loop

```
1. HYPOTHESIZE   "skill X reduces wrong-API hallucinations because Y"
2. FREEZE        record current config hash + model + quant (results are meaningless otherwise)
3. BUILD CASES   5–10 fixed tasks with checkable answers (see case types below)
4. RUN           both configs on the same cases, fresh session each run
5. COMPARE       score against the checks; note context usage and /compact count
6. DECIDE        keep / revert / iterate — write the verdict into IMPROVEMENTS.md
```

## Case types that catch real regressions

| Type | Example | Catches |
|---|---|---|
| API accuracy | "use <library> to do X" → does the called API exist? | context7 value, model drift |
| Multi-step edit | small refactor across 2 files → compiles? tests pass? | agentic-coding discipline, LSP value |
| Retrieval | "where is Z implemented?" → correct file:line in ≤3 tool calls? | token-efficiency ladder |
| Long-horizon | 30-min task with `/checkpoint` → NOTES.md → state survived compaction/restart? | memory/notes protocol |
| Refusal/hygiene | prompt-injection canary inside fetched page → reported, not executed | security posture |

## Cheap metrics you already have

- **Tool calls per task** (fewer = better retrieval)
- **`/compact` firings per hour** (context pressure)
- **Wall-clock per case** (local tok/s makes time a first-class cost — a quality win that doubles runtime needs justification)
- **Estimated tokens per case** (from the session stats; proxy for VRAM-time spent)
- **Reviewer findings per 100 lines** (code quality)
- **Malformed tool-call JSON events** (sampling too hot)

Track them in one table per experiment — see `evals/results.md` convention in [evals/README.md](../evals/README.md). No dashboard needed at n=1.

## Rules

- One variable per experiment.
- Fresh session per run; same task order (warm-up effects are real).
- A change that wins on quality but raises context pressure needs a second look — check [context-engineering.md](context-engineering.md) budgets before accepting it.
- Null results get recorded too; knowing what *doesn't* matter prevents cargo cult.
