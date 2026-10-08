---
name: skill-evaluation
description: Evaluate and benchmark skills, prompts, or model changes with test cases, assertions, and quantitative comparison. Use when asked to evaluate a skill, test a prompt, A/B compare outputs, or measure if a change improved results.
---

# Skill & Prompt Evaluation

## Core loop

1. **Test cases first** — 3-5 realistic prompts (the kind actually typed), saved with expected outputs. Subjective skills (style/writing) get qualitative review; objective ones (file transforms, data extraction) get assertions.
2. **Baseline + variant in parallel** — never run only the new version. Same prompts through old and new; differences are the signal.
3. **Assertions must be mechanically checkable**: "output contains valid JSON with key X", "file parses", "command exits 0" — not "looks good".
4. **n=3 minimum per case** — single runs hide variance; report mean ± spread for time/tokens.

## Grading

- Write a script for anything programmatic — faster, reusable across iterations, no eyeballing drift.
- Grade against the assertion text, storing `{text, passed, evidence}` triples so failures show *why*.

## Regression discipline

Keep an evergreen eval set per skill (`evals/evals.json`). Every skill edit reruns it before shipping:

```json
{"skill_name": "x", "evals": [{"id": 1, "prompt": "...", "expected_output": "...", "files": []}]}
```

## Local-model specifics (RTX 3090)

- Run evals only when llama-server is idle — GPU contention corrupts timing data and can OOM the live session. Check: `pgrep -f llama-server`.
- Compare variants within one session/process where possible; quantize noise by pinning temperature=0 for grading runs.
- Reference tooling exists locally at `Skills/Claude-Skills-Choice/` (grader/comparator/analyzer agents, `eval-viewer/generate_review.py --static out.html` for headless review).

## Reporting

One table: case × {baseline, variant} × {pass-rate, tokens, seconds}. Name what regressed, not just the average.
