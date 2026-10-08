---
name: agentic-coding
description: Working agreements for coding agent loops — plan-then-edit, minimal diffs, verify each step. Use for any multi-step implementation task, refactor, or bugfix in this workspace.
---

# Agentic Coding Discipline

## Loop shape

**Understand → Plan → Edit → Verify**, one coherent unit per iteration.

1. Read the exact code paths involved before proposing changes (see token-efficiency ladder).
2. State the plan in ≤5 bullets when a task spans >2 files; get confirmation on destructive refactors — route them through the `skeptic` subagent first.
3. Make the smallest diff that satisfies the task. No drive-by reformatting, no renaming sprees, no "while I'm here" fixes — list them as suggestions instead.
4. Verify immediately after editing: run the narrowest check that can fail (single test, typecheck of one file, script execution) before moving on.

## Example: minimal vs drive-by

Task: "add a --dry-run flag to deploy.sh".

- Minimal diff (+8/−2): parse the flag, branch around the ssh call, update usage string. Reviewer sees exactly what changed.
- Drive-by (rejected): same feature, plus renamed variables, reordered imports, and reformatted unrelated functions. The feature is now buried in diff noise and a bad reformat hides in it.

## Edit mechanics

- Prefer `edit` with unique anchors over rewriting whole files.
- Match surrounding conventions (imports, naming, error handling) — read neighbors first.
- Never leave TODOs or dead code behind as "documentation of intent".

## Failure handling

- A failing verification means: diagnose root cause next, not patch symptoms. Max 3 fix attempts on the same error before stepping back and re-planning explicitly.
- If scope grows mid-task ("this needs a migration too"), stop and surface it rather than silently expanding.

## Definition of done

Code compiles/lints/tests pass + you stated what you changed and what you verified. No summary padding beyond that.

## Learning loop (after the task, while failures are fresh)

1. **Distill**: any task that took >10 tool calls, or hit a failure you recovered from → propose a SKILL.md diff capturing the procedure + a REGISTRY.md entry. Surface it for vetting; never register your own proposal unreviewed.
2. **Log gaps**: you wanted a procedure but no registered skill covered it (or one misfired) → append one line to `.state/SKILL-GAPS.md`: `<trigger> — <missing capability>`. Demand-side signal drives what gets authored next.
3. **Flush memory**: before ending a session, or as soon as a compaction warning appears — write durable facts and decisions to memory MCP. Compaction prunes tool results; anything not in memory MCP or NOTES.md will not survive it.
