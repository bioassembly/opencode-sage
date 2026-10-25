---
name: grill-me
description: Relentless interview to sharpen a plan, decision, or architecture before code is written. Maps design trees in rounds with recommended defaults. Use when the user wants to stress-test their thinking or uses /grill-me.
---

# Grill Me

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

## Question Format

Format each round like so:

```markdown
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including trade-offs and options>

➡️ <your concrete recommended answer or default option>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including trade-offs and options>

➡️ <your concrete recommended answer or default option>
```

Word each question so answering "yes" accepts your recommended answer.

## Process Rules

1. **Recompute the frontier each round**: Settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.
2. **Find facts autonomously**: Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, codebase symbols, existing configs, tools, etc.), search and read it yourself (or dispatch a subagent). Never ask the user for anything you could look up directly.
3. **Keep moving**: Do not block on pending investigations: a running exploration is an unsettled prerequisite, so only questions downstream of it wait; ask the rest of the current frontier immediately. The _decisions_ are the user's: put each to them with a clear recommendation and wait.
4. **Capture emerging models**: When terminology crystallizes or trade-offs emerge during the interview, pair this with `domain-modeling` to capture domain vocabulary in `GLOSSARY.md` and high-impact decisions in `docs/adr/`.
5. **Shared understanding gate**: The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Summarize the agreed architectural decisions and do NOT act or implement until the user confirms you have reached a shared understanding.
