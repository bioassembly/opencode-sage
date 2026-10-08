# Agent Protocol

## Skill & Tool Protocol

On session start, and before every non-trivial task:

1. Check available skills; load the one matching the task and follow its runbook.
2. For new features or bug fixes, always follow `test-driven-development` (write failing test first).
3. For complex multi-file plans, invoke `using-git-worktrees` to ensure workspace isolation.
4. No match → flag `[SKILL GAP: <topic>]`, then run the self-improvement loop below immediately — never ask permission first.

## Self-Improvement & Continuous Learning

1. **Vetting ladder**: Official docs (`docs.<tool>.io/llms.txt` first), canonical repo READMEs, curated collections (`obra/superpowers`, `K-Dense-AI/scientific-agent-skills`, `anthropics/skills`).
2. **Quality bar**: ≥1,000 stars (≥100 for niche bioinformatics); pushed within 12 months; zero malicious patterns; concise YAML frontmatter with actionable description.
3. **Write** a `SKILL.md` into the skills directory: name matches its folder exactly, description carries trigger keywords (<120 chars), under 80 lines, every line changes behavior.
4. **Register**: Add the skill to `reference/skills/REGISTRY.md` and announce `[SKILL ADDED: <name>]`.

## Multi-Agent & Subagent Guidelines

- For pre-implementation red-teaming: invoke the `skeptic` subagent (`/red-team`) to attack hidden assumptions, failure modes, and simpler alternatives before writing code.
- For pre-commit code review: invoke the `reviewer` subagent (`/review`) to audit the working diff for correctness, security, and repo conventions.
- For bioinformatics, Nextflow DSL2 pipelines, Quarto reports, and HPC jobs: use the `bioinformatician` subagent persona or skills.

## Post-Task Learning Loop

After any task that took >10 tool calls or recovered from a failure:

1. **Distill** — propose a SKILL.md diff + REGISTRY.md entry for the procedure; surface for vetting, never self-register.
2. **Log gaps** — needed a procedure no skill covered? Append `<trigger> — <missing capability>` to `.state/SKILL-GAPS.md`.
3. **Flush memory** — before session end or on a compaction warning, write durable facts/decisions to memory MCP; compaction prunes everything else.

## Hard Rules

- **Tight responses**: Direct, concise, technical. No padding, no unsolicited preamble or postamble.
- **Minimal diffs**: No drive-by reformatting, no unsolicited renames. Suggest cosmetic cleanups separately.
- **Verify before claiming done**: Run the narrowest test or command that can fail and cite executed evidence. No evidence, no "done".
- **Genomics & Python stack**: Python packages outside conda use `--break-system-packages`. Nextflow pipelines follow nf-core conventions with stub tests (`-stub-run`) before real data.
- **Durable memory**: Persist important architectural decisions, conventions, and user preferences to the `memory` MCP server. Never store credentials or API keys.
