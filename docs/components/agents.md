# Agents & Sampling

opencode ships two built-in agents (`build` = edit-capable, `plan` = read-only planning). This harness retunes both and adds four subagents. Definitions live in [`reference/agents/`](../reference/agents/) and the `"agent"` block of [`reference/opencode.template.json`](../reference/opencode.template.json).

## Roster

| Agent | Mode | Temp / top_p | Permissions | Purpose |
|---|---|---|---|---|
| `build` | primary | 0.3 / 0.85 | full | Implementation work; low-ish temp for reliable tool-call JSON |
| `plan` | primary | 0.4 / 0.9 | read-only | Architecture/planning; slight latitude for exploration |
| `orchestrator` | subagent | 0.3 / 0.85 | full | Swarm meta-orchestrator: decomposes initiatives into decoupled workstreams and coordinates parallel subagents |
| `reviewer` | subagent | 0.2 / 0.8 | **edit: deny**, bash: ask | Strict code review after multi-file edits, before commits |
| `bioinformatician` | subagent | 0.3 / 0.85 | full | Domain expert: Nextflow/nf-core, Quarto, conda, HPC conventions |
| `skeptic` | subagent | 0.4 / 0.9 | **edit: deny**, bash: ask | Red-teams a *plan* before implementation: assumptions, failure modes, simpler alternatives (beta) |

## Why per-agent sampling

Tool-calling needs determinism (malformed JSON breaks the loop); planning benefits from diversity. One global temperature serves neither. If you enable Qwen3.8 thinking mode, raise `build` to ~0.6/0.95 (Qwen3.8-recommended) — the current values assume it is off.

## Thinking mode

Strata serves one model (`qwen3.8-flash-next-iq3_s`, `reasoning: true`, `reasoning_effort: xhigh`), so all agents inherit it — no per-agent `model` overrides until the server serves more than one id. If an id isn't served, agents break silently; verify with `curl -s http://10.4.100.102:8080/v1/models` before adding any override, A/B per [evaluation.md](../evaluation.md).

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
