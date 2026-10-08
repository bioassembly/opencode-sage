---
description: Dump current task state to NOTES.md in the working directory so work survives compaction or a session restart.
agent: build
---

Checkpoint the current task to disk.

1. Read `NOTES.md` in the working directory if it exists — merge into it, never clobber unrelated content.
2. Rewrite/update these sections:

```
# NOTES — <one-line task name>
## Goal
## Done            # with file:line refs
## In progress     # exact step it stopped at
## Next steps      # ordered, actionable
## Decisions       # choice + why (one line each)
## Resume hint     # what to read first to pick this up cold
```

Rules:
- Max ~60 lines. File paths and identifiers verbatim — a fresh session must resume without re-exploring.
- If no task is in progress, say so and stop; do not create an empty NOTES.md.
- Confirm the path you wrote when done.
