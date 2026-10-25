---
description: Interview the user relentlessly to sharpen a plan, architecture, or design before implementation.
agent: plan
---

Run a relentless design interview to stress-test the user's plan or idea:

1. Identify the core idea, plan, or design being discussed. If nothing has been stated yet, ask for the feature or plan in one sentence and stop.
2. Load and follow the `grill-me` skill:
   - Map the decisions as a design tree where prerequisites must be settled first.
   - Compute the active frontier of open questions.
   - Present the frontier questions in numbered rounds with your concrete recommended answer for each.
   - Word each question so "yes" accepts your recommended answer.
   - Investigate facts in the repo yourself; never ask the user for information you can discover with tools.
3. Once all branches of the design tree have been settled, summarize the agreed-upon architecture and verify the user confirms shared understanding before starting implementation.
