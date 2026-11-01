---
name: overnight-explorer
description: Run deep, unattended autonomous exploration while the user is away — across codebases, scientific/omics datasets, benchmarks, or research topics — delivering verified findings, refuted hypotheses, and a cold-reproducible methods log. Use when the user asks to "explore overnight", "keep digging while I'm away/asleep", "find anything interesting", or run an open-ended autonomous investigation.
---

# Overnight Explorer — Unattended Autonomous Discovery Protocol

Goal: Take a target workspace, dataset, codebase, or research question, explore high-value hypotheses autonomously while the host is away, and leave two crisp, verified deliverables in the target root: **`FINDINGS_REPORT.md`** and **`ANALYSIS_METHODS.md`**.

## 1. Unattended Autonomy Rules
- **Never block on questions** while the user is away. Resolve ambiguities using safe, reversible defaults, document every assumption, and keep progressing.
- **Timebox & branch**: Maintain a queue of 4–8 orthogonal exploration angles. If one angle stalls, errors twice, or lacks signal, log why and pivot to the next branch — never spin endlessly on one dead end.
- **Checkpoint after every branch**: Update `NOTES.md` (`Done`, `In Progress`, `Next Queue`, `Key Numbers`) after each completed experiment so partial progress survives any interruption or context compaction.
- **Strict safety & read-only inputs**: Never mutate raw input datasets, git history, live production services, or credentials. Write intermediate scripts/outputs into an isolated scratch or analysis subdirectory (`exploration_work/` or `.sage-outputs/`).

## 2. Dynamic Environment & Resource Probe (Zero Hardcoding)
Before launching heavy tasks, inspect the actual host and workspace:
1. **Compute & active load**: Check CPU cores, free RAM, disk space, and running daemons (`nproc`, `free -h`, `df -h .`) so batch jobs leave headroom for live system services.
2. **Available toolchain & assets**: Discover installed CLIs, language runtimes, test runners, local reference databases, or documentation indexes dynamically — never hardcode machine-specific paths.

## 3. Iron Evidence & Falsification Rules
Every headline finding MUST survive all three gates:
1. **Two Independent Evidence Lines**:
   - *Codebases*: Static code/AST/symbol trace + executed reproduction test, benchmark, or profiler trace.
   - *Data / Science / Bioinformatics*: At least two orthogonal analytical, statistical, or alignment methods confirming the same signal.
   - *Research / Literature*: Primary source / benchmark data + independent replication or cross-reference (verify exact figures and DOIs/URLs; never cite from memory alone).
   - Single-line signals are labeled **`Candidate Lead`**, never **`Verified Finding`**.
2. **Active Falsification**: Attempt to break your own hypothesis (null controls, boundary inputs, confounding variables, artifact/batch-effect checks, baseline comparison).
3. **Log Refuted Hypotheses**: Record disproven ideas and negative results explicitly with the evidence that ruled them out — preventing the user from wasting time re-testing dead ends.

## 4. Morning Deliverables Contract

### `FINDINGS_REPORT.md`
- **Executive Summary** (≤10 lines): What was explored, top breakthroughs, and what requires a human decision.
- **Ranked Findings (`S` / `A` / `B`)**:
  - **`S` (High-Impact / Critical)**: Major discovery, severe latent bug/vulnerability, order-of-magnitude bottleneck, or publishable/novel signal.
  - **`A` (Solid Actionable)**: Verified architectural improvement, notable pattern/anomaly, or strong optimization with measured gain.
  - **`B` (Hygiene / Minor)**: Edge-case cleanup, minor QC note, or incremental refinement.
  - *Per item*: Title & exact target (`file:line` / sample / entity) → Two-line evidence chain (commands + exact numbers) → External/literature/doc check → Concrete next action.
- **Refuted Hypotheses & Negative Results**: What looked promising, how it was tested, and why it was ruled out.
- **Unexplored / Blocked Queue**: Remaining branches and what resource or permission they need.

### `ANALYSIS_METHODS.md`
Cold-reproducible protocol: discovered environment/versions, exact commands and scripts executed in order, parameters/thresholds chosen, runtime notes, and paths to generated artifacts so a human can re-run any step cold.
