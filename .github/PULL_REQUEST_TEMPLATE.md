## What & why

<!-- One paragraph: what failure does this change prevent or fix? -->

## Changes

-

## Verification

- [ ] `jq empty reference/opencode.template.json`
- [ ] `bash -n scripts/*.sh`
- [ ] Ran `./scripts/activate.sh --key x` (required if anything under `reference/` changed) — confirmed `Config JSON valid.`
- [ ] Change logged in `IMPROVEMENTS.md` (append-only)
- [ ] No secrets introduced; `__UNSLOTH_API_KEY__` placeholder intact; no `@latest` in MCP commands
