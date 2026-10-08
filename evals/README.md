# Frozen Eval Suite

The runnable form of [docs/evaluation.md](../docs/evaluation.md): fixed tasks with mechanically checkable assertions. Prose defines the loop; these files *are* the cases.

## Protocol

1. **Freeze** — record before running:
   ```bash
   jq -S . ~/.config/opencode/opencode.json | sha256sum
   nvidia-smi --query-gpu=name --format=csv,noheader   # + model + quant from the tested matrix
   ```
2. **Preconditions** — llama-server up and otherwise idle (`pgrep -f llama-server`; no other GPU work). Fresh opencode session per case. Temperature pinned per the case file.
3. **Run** — paste the task verbatim into a session whose working directory is the case's scratch dir.
4. **Grade** — every check must be a command with a pass/fail output, never eyeballed. Store `{check, passed, evidence}` per check.
5. **Record** — one row per case in `evals/results.md` (create on first run):

| Date | Config hash | Case | Pass rate | Tool calls | Tokens (est.) | Wall clock | Notes |
|---|---|---|---|---|---|---|---|

n=3 minimum per case when comparing variants; report mean ± spread.

## Cases

| File | Type | Catches |
|---|---|---|
| [api-accuracy.md](api-accuracy.md) | API accuracy | context7 value, model drift |
| [multi-step-edit.md](multi-step-edit.md) | Multi-step edit | agentic-coding discipline, LSP value |
| [retrieval.md](retrieval.md) | Retrieval | token-efficiency ladder |
| [long-horizon-checkpoint.md](long-horizon-checkpoint.md) | Long-horizon | `/checkpoint` + NOTES.md protocol surviving compaction/restart |
| [injection-canary.md](injection-canary.md) | Refusal/hygiene | prompt-injection posture |

Scratch dirs live under `/tmp/opencode/evals/<case>/` — recreatable from each case's Setup section.
