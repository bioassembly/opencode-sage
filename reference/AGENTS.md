# Agent Protocol

## Skill & Tool Protocol

On session start, and before every non-trivial task:

1. Check available skills; load the one matching the task and follow its runbook.
2. For new features or bug fixes, always follow `test-driven-development` (write failing test first).
3. For complex multi-file plans, invoke `using-git-worktrees` to ensure workspace isolation.
4. **Autonomous Binary & Opaque Artifact Exploration**: While exploring a codebase or directory, keep LSP tools for readable source files, and **automatically** load `reverse-engineer-anything` (`rea` CLI: `rea inspect-artifact`, `rea analyze-javascript-application`, `rea inspect-binary-layout`, etc.) whenever you encounter compiled binaries, `.so`/`.dll`/`.dylib` libraries, `.apk`/`.asar` packages, `.wasm`/`.pyc`/`.jar` bytecode, firmware, or minified JS bundles without source — never wait for the user to ask for `rea`.
5. No matching skill → flag `[SKILL GAP: <topic>]`, then run the self-improvement loop below immediately — never ask permission first.

## Self-Improvement & Continuous Learning

1. **Vetting ladder**: Official docs (`docs.<tool>.io/llms.txt` first), canonical repo READMEs, curated collections (`obra/superpowers`, `K-Dense-AI/scientific-agent-skills`, `anthropics/skills`).
2. **Quality bar**: ≥1,000 stars (≥100 for niche bioinformatics); pushed within 12 months; zero malicious patterns; concise YAML frontmatter with actionable description.
3. **Write** a `SKILL.md` into the skills directory: name matches its folder exactly, description carries trigger keywords (<120 chars), under 80 lines, every line changes behavior.
4. **Register**: Add provenance to `reference/skills/REGISTRY.md` (or keep machine-private skills in gitignored `reference/skills.local/`) and announce `[SKILL ADDED: <name>]`.

## Multi-Agent & Subagent Guidelines

- For pre-implementation design stress-testing: run `/grill-me` to interview and resolve the design tree in rounds before building.
- For pre-implementation red-teaming: invoke the `skeptic` subagent (`/red-team`) to attack hidden assumptions, failure modes, and simpler alternatives before writing code.
- For pre-commit code review: invoke the `reviewer` subagent (`/review`) to audit the working diff for correctness, security, and repo conventions.
- For bioinformatics, Nextflow DSL2 pipelines, Quarto reports, and HPC jobs: use the `bioinformatician` subagent persona or skills.

## Optional Hybrid Fleet Routing (`hybrid-sage`)

When the `hybrid-sage` plugin/MCP is connected:
- **Direct Execution First**: Execute routine coding, bug fixes, refactoring, and test execution directly in OpenCode (never call `delegate_local` on yourself).
- **Proactive Upfront Routing**: For ambiguous greenfield system design or complex algorithmic trade-offs, run `route_task(prompt="...")` upfront. If routed to `frontier-architect` or `cloud-sprinter`, escalate via `escalate_task(...)` to obtain read-only diagnosis and invariants from Antigravity (`agy --mode plan`).
- **Two-Strike Rule**: After 2 failed fix attempts on the same bug or test failure, call `escalate_task(prompt="...", files=[...], attempted=[...], failing_command="...", failing_output="...")`, then implement and verify the returned spec locally.
- **Project-Scoped Lessons**: Reusable root-cause invariants are persisted in `~/.config/opencode/lessons.jsonl` and surfaced automatically on matching repositories.

## Post-Task Learning Loop

After any task that took >10 tool calls or recovered from a failure:

1. **Distill** — propose a SKILL.md diff + REGISTRY.md entry for the procedure; surface for vetting, never self-register.
2. **Log gaps** — needed a procedure no skill covered? Append `<trigger> — <missing capability>` to `.state/SKILL-GAPS.md`.
3. **Flush memory** — before session end or on a compaction warning, write durable facts/decisions to memory MCP; compaction prunes everything else.

## Hard Rules

- **Tight responses**: Direct, concise, technical. No padding, no unsolicited preamble or postamble.
- **Minimal diffs**: No drive-by reformatting, no unsolicited renames. Suggest cosmetic cleanups separately.
- **Verify before claiming done**: Run the narrowest test or command that can fail and cite executed evidence. No evidence, no "done".
- **Genomics & Python stack**: Prioritize `conda install -c bioconda -c conda-forge` for compiled bioinformatics tools; Python packages outside conda use `--break-system-packages`. Nextflow pipelines follow nf-core conventions with stub tests (`-stub-run`) before real data.
- **Durable memory**: Persist important architectural decisions, conventions, and user preferences to the `memory` MCP server. Never store credentials or API keys.
