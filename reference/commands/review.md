---
description: Invoke the read-only reviewer subagent on the current working diff (staged + unstaged). Use after edits, before committing.
agent: build
---

Review the current changes with maximum scrutiny:

1. `git status --short` and `git diff HEAD` to collect the working diff. If not a git repo or no diff, say so and stop.
2. Dispatch the `reviewer` subagent with: the full diff plus 3 lines of context around each hunk (`git diff -U3 HEAD`), and this instruction — "Review these changes for correctness bugs, security issues, and violations of any AGENTS.md conventions in this repo."
3. Report the reviewer's findings verbatim (it already formats severity/file/line/fix).
4. If findings exist, end with one line: `Fix first, then re-run /review.` If none: `No blocking findings. Ready to commit.`

Do not apply any fixes yourself in this command — review only.
