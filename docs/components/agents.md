# Agents & Sampling

opencode ships two built-in agents (`build` = edit-capable, `plan` = read-only planning). This harness retunes both and adds three subagents. Definitions live in [`reference/agents/`](../reference/agents/) and the `"agent"` block of [`reference/opencode.template.json`](../reference/opencode.template.json).

## Roster

| Agent | Mode | Temp / top_p | Permissions | Purpose |
|---|---|---|---|---|
| `build` | primary | 0.3 / 0.85 | full | Implementation work; low-ish temp for reliable tool-call JSON |
| `plan` | primary | 0.4 / 0.9 | read-only | Architecture/planning; slight latitude for exploration |
| `reviewer` | subagent | 0.2 / 0.8 | **edit: deny**, bash: ask | Strict code review after multi-file edits, before commits |
| `bioinformatician` | subagent | 0.3 / 0.85 | full | Domain expert: Nextflow/nf-core, Quarto, conda, HPC conventions |
| `skeptic` | subagent | 0.4 / 0.9 | **edit: deny**, bash: ask | Red-teams a *plan* before implementation: assumptions, failure modes, simpler alternatives (beta) |

## Why per-agent sampling

Tool-calling needs determinism (malformed JSON breaks the loop); planning benefits from diversity. One global temperature serves neither. If you enable Qwen3.8 thinking mode, raise `build` to ~0.6/0.95 (Qwen3.8-recommended) — the current values assume it is off.

## Thinking-mode rollout (experimental)

`plan` and `skeptic` run on the `qwen3.8-27b-thinking` model entry (`reasoning: true`) — slower, deeper reasoning where latency is acceptable. `reviewer` deliberately stays on the non-thinking entry until the experiment validates the model id against your server: if the id isn't served, reviews would break, and review is the agent you least want silently down. Verify with `curl -s http://localhost:8888/v1/models`, A/B per [evaluation.md](../evaluation.md), then extend or revert.

## The reviewer pattern

The most valuable agent in the set:

- `permission.edit: deny` makes destructive action structurally impossible, not just discouraged.
- `bash: ask` keeps read-only commands one confirmation away.
- Its prompt enforces output discipline: max 10 findings, each with file:line and a fix suggestion, verdict of ship/fix-first, no praise.

Use it proactively: any multi-file edit → reviewer before commit. It catches what the editing agent rationalizes.

## Subagents as context isolation

Subagent transcripts never enter the main session — only their final answer does. Route long exploratory work (codebase surveys, doc dives) into a subagent so the main window stays clean. This pairs with the `token-efficiency` skill's session-shape rules.

## Adding an agent

Add a block under `"agent"` in the staged config (or a `.md` file in `reference/agents/`), re-run `activate.sh`, restart opencode. Give every custom agent: a description that states *when* to use it, tuned sampling, and least-privilege permissions.
