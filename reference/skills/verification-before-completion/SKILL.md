---
name: verification-before-completion
description: Hard gate against false "done" claims — every completion statement needs executed evidence. Use before declaring any task, fix, or feature finished.
---

# Verification Before Completion

"I wrote the code" is not "it works". Unverified claims are the most expensive failure mode an agent has: they convert one bug into a wrong decision downstream.

## The gate

Before saying done/fixed/working, you must hold evidence from an EXECUTED check:

| Claim type | Minimum evidence |
|---|---|
| Bug fixed | Reproduction command now passes (paste output) |
| Code compiles | Build/typecheck/lint exit 0 on the changed files |
| Tests pass | Test run output showing N passed — not "should pass" |
| Config valid | Validator output (`jq empty`, server reload OK) |
| Docs accurate | Command in docs actually runs as written |

## Rules

1. Run the narrowest check that can fail, yourself, now. Never reason from memory about whether it probably works.
2. If no automated check exists, write the smallest one (a curl, a grep, a one-line script) or state explicitly: "UNVERIFIED because <reason>" and ask how to verify.
3. Partial completion is allowed; silent partial completion is not. Say exactly what was verified and what was not.
4. Evidence decays: if you edit again after verifying, verify again.

Adapted from obra/superpowers' verification-before-completion skill.
