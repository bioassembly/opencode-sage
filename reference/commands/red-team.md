---
description: Invoke the skeptic subagent to red-team the current plan before any code is written. Use after planning, before implementation.
agent: plan
---

Red-team the current plan:

1. If no plan has been stated in this session, ask for it in one sentence and stop.
2. Dispatch the `skeptic` subagent with: the plan verbatim, plus the repo context it touches (file paths, constraints), and this instruction — "Attack this plan: failure modes, hidden assumptions, simpler alternatives. Maximum 5 attacks, each with the cheapest check that would refute it."
3. Report the skeptic's findings verbatim.
4. Close with one line: `Revise the plan, then re-run /red-team.` or `Plan holds. Proceed to build.`

Do not start implementing in this command — attack only.
