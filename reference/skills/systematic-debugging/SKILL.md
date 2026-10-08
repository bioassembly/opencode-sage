---
name: systematic-debugging
description: Four-phase root-cause debugging loop — reproduce, hypothesize, test minimally, fix cause not symptom. Use for any bug, error, or unexpected behavior.
---

# Systematic Debugging

Process over guessing. A fix without a root cause is a delayed second bug.

## Phase 1 — Reproduce

Make the failure deterministic before touching anything. Flaky = gather more data first (logs, exact commands, environment diff). If you cannot reproduce it, you cannot verify the fix.

## Phase 2 — Hypothesize

Write ONE concrete hypothesis: "X fails because Y". Read the actual error and the actual code path involved — no fixing from the error message alone. Prefer hypotheses you can falsify cheaply.

## Phase 3 — Test minimally

The smallest experiment that confirms/denies the hypothesis: add one log line, isolate one function, revert one commit, `git bisect`. Change ONE variable at a time. A test that can't fail is not a test.

## Phase 4 — Fix cause, verify, sweep

- Fix the root cause, not the loudest symptom (guarding a TypeError ≠ fixing the None).
- Verify with the reproduction from Phase 1 plus the nearest broader check (tests/build).
- Sweep: does this same bug pattern exist elsewhere? grep for it.

## Escalation rule

Max 3 failed fix attempts on the same error → STOP. Re-read the problem statement, question the hypothesis layer itself ("am I fixing the right thing?"), write findings into NOTES.md, and surface to the user with what was ruled out.

Adapted from obra/superpowers' systematic-debugging skill.
