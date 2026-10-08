# Case: Retrieval

**Type:** Retrieval · **Catches:** token-efficiency ladder (grep/glob → sliced reads) · **Temperature:** 0.2

## Setup

Point the session at any real, non-trivial repo you know the answer for (use this cookbook repo itself if unsure). Pre-compute the ground truth **before** the run:

```bash
# example ground truth on sage-cookbook:
rg -n "tail_turns" --type md   # note file:line answers
```

Write the expected `file:line` answers into the case log first — never derive them after seeing the model's output.

## Task (paste verbatim)

> In this repo, find where tool-output pruning is configured and where the compaction tail window is set. Answer with file:line references only. Do not explain.

## Checks

| # | Check | Command |
|---|---|---|
| 1 | Both references are correct file:line | compare against pre-computed ground truth |
| 2 | Answer reached in ≤ 3 search/read tool calls | inspect session tool calls |
| 3 | No full-file reads of files > 200 lines | inspect session: reads carry offset/limit or are small files |

Check 2 is the metric: grep-first should beat read-everything. A rising call count across runs signals retrieval-ladder drift.
