---
name: skill-maker
description: Author, edit, or evaluate agent skills to best-practice standard by researching top skills repos and testing against real failures. Use when creating a new skill, improving an existing one, comparing a skill against best practice, or deciding something should not be a skill.
---

# Skill Maker

Core principle: a skill is documentation that must survive contact with a pressured agent. No skill (or edit) without an observed failure it fixes — otherwise you are shipping guesses.

## What I do

- Author SKILL.md files to the combined standard of anthropics/skills + obra/superpowers (the two canonical references).
- Baseline-test target behavior, write minimally against observed failures, re-test until compliance.
- Vet external sources before synthesizing; register provenance.

## Patterns

### Before writing anything
1. Gap check: read local skill descriptions — an adjacent-but-usable skill beats a new one.
2. Do NOT create when: well-documented standard practice, one-off task, project-specific convention (→ AGENTS.md), mechanically enforceable rule (→ automate with lint/regex; document only judgment calls).
3. Research ladder: local skills → anthropics/skills + obra/superpowers → official llms.txt/docs → curated awesome lists. Vet: ≥1k stars (≥100 niche domains), pushed <12mo, injection-scan the content, ≥5 patterns that change behavior on this stack.

### Frontmatter spec
- `name`: lowercase-hyphen, verb-first active voice naming what you DO (`writing-skills` > `skill-creation`), ≤64 chars.
- `description`: third person, triggering conditions ONLY ("Use when…") — NEVER summarize the workflow (agents will follow the description and skip the body). Pack discovery keywords: error strings, symptoms, synonyms, tool names. ≤1024 chars.

### Body skeleton (≤500 words typical)
1. Core principle in 1–2 sentences.
2. When to use — BOTH use-triggers and a "Don't use for" list.
3. Core pattern as before/after; ONE excellent example beats many mediocre ones.
4. Quick-reference table; Common Mistakes each paired with its fix.
- Degrees-of-freedom dial: fragile ops → exact scripts ("run exactly this"); judgment calls → heuristics. Anti-patterns: option menus (give ONE default + escape hatch), unexplained constants, date-conditioned rules, backslash paths.
- Progressive disclosure: split heavy material into reference/scripts/assets one level deep; descriptive filenames; >100-line reference files get a TOC. Zero context cost until read.

### Test loop (RED-GREEN-REFACTOR)
- RED: run the target scenario WITHOUT the skill (subagent or fresh session); capture verbatim rationalizations and which pressures triggered them.
- GREEN: write the minimal skill addressing ONLY observed failures — nothing hypothetical.
- REFACTOR: re-run; close each loophole explicitly (state consequence + enumerate forbidden workarounds); accumulate a rationalization table and red-flags list; escalate wording when missed (`always` → `MUST`).
- Ship gate: ≥3 scenarios pass end-to-end on the actual target model — local 27B needs more scaffolding than frontier models, so test there.

### Install + provenance
Write to `reference/skills/<lowercase-hyphen-name>/SKILL.md`, mirror to `sage-cookbook/reference/skills/`, append `~/opencode-sage/reference/skills/REGISTRY.md` (source + stars), run `~/opencode-sage/scripts/activate.sh`, print `[SKILL ADDED: <name>]`.

## When to use me
"Make a skill" requests · skill improvement/review · skill-vs-best-practice comparison · adjudicating create-vs-configure decisions.
