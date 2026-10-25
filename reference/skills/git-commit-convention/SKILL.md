---
name: git-commit-convention
description: Write or fix git commit messages — infer house style from repo history, Conventional Commits spec, closing keywords, amend + force-with-lease.
---

# Git Commit Convention

Grounded in: Conventional Commits 1.0.0 (conventionalcommits.org), the commitlint/Angular type set, GitHub Docs (closing keywords; force-push guidance), and the widely adopted seven rules (cbea.ms/git-commit).

## Before writing any message

1. `git log --oneline -15` in the target repo first. Observed house style (types, `type(scope):` usage, case) wins over generic standards.
2. History inconsistent or empty → use the format below.

## The format (Conventional Commits)

```
<type>[optional scope][!]: <description>

[optional free-form body]

[optional footer(s)]
```

- Types: `fix` = bug fix (SemVer PATCH), `feat` = new feature (SemVer MINOR). commitlint's set for everything else: `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`, `test`.
- Breaking change: append `!` after type/scope (`feat!:`) or add a `BREAKING CHANGE: <description>` footer → SemVer MAJOR.
- Scope is an optional noun in parentheses (`fix(parser):`); use it only if the repo's history does.
- Description immediately follows the colon-space; it summarizes the change, not the code.
- Body begins exactly one blank line after the description; free-form paragraphs; footers one blank line after the body, `Token: value` style (`Acked-by: Z`, `Refs: #123`).

## Style rules

- Imperative mood: "add", "fix", "render" — never "added/fixed/updates".
- Subject ≤50 chars target, 72 hard cap. No trailing period.
- Blank line between subject and body; wrap body at 72 cols.
- Body explains *what* and *why*, never *how*. Omit it when the diff already says all three.
- One logical change per commit; split otherwise rather than writing a compound message.

## GitHub-specific semantics

- Closing keywords work in commit messages: `close(s|d)`, `fix(es|d)`, `resolve(s|d)` + `#N` (same repo) or `owner/repo#N` (cross-repo). They fire only when the commit merges into the *default* branch.
- Prefer `git push --force-with-lease` over `--force` — GitHub's own guidance against clobbering others' pushes.

## Fixing a wrong message

- Unpushed: `git commit --amend -m "type: summary"`.
- Pushed on a solo branch: amend + `git push --force-with-lease`.
- Pushed on a shared branch: do NOT rewrite; land a follow-up commit or ask first.

## Rejected patterns

- `Component: did something` — scope-as-prefix with no type.
- `Update stuff`, `wip`, `fix bug` — no type, no specificity.
- Compound messages covering unrelated changes — split the commit instead.
- Never `--no-verify` to dodge hooks; fix what the hook flags.

## Evidence before claiming done

Show `git log -1 --oneline` after every commit or amend; the message you intended and the message that landed must match.
