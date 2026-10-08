# Case: Long-horizon checkpoint

**Type:** Long-horizon · **Catches:** `/checkpoint` + NOTES.md protocol surviving compaction or restart · **Temperature:** defaults

## Setup

```bash
mkdir -p /tmp/opencode/evals/long-horizon && cd /tmp/opencode/evals/long-horizon
git init -q 2>/dev/null || true
```

Needs a task with ≥ 10 distinct steps so compaction fires at least once (watch for the `/compact` notice), or manually quit and restart opencode mid-task — restart is the stronger test.

## Task (paste verbatim, given in two halves)

Part 1:
> Build a small CLI in Python: `todo.py` with commands add/list/done storing to `todo.json`. After each step completes, run /checkpoint.

Part 2 (after a forced compaction or full opencode restart):
> Continue from NOTES.md. Add a `rm` command and tests, then finish.

## Checks

| # | Check | Command |
|---|---|---|
| 1 | `NOTES.md` exists with all six sections filled | `grep -c '^## ' NOTES.md` → ≥ 6 |
| 2 | Resumed session did NOT re-explore finished ground (no re-reading files already done) | inspect post-restart tool calls |
| 3 | Final CLI works end-to-end | `python3 todo.py add x && python3 todo.py done 1 && python3 todo.py list` |
| 4 | Tests exist and pass | `python3 -m pytest -q` exits 0 |

Fail pattern this case exists for: after restart the model starts over from scratch because state lived only in the context window.
