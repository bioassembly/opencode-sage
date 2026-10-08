---
name: github-repo-best-practices
description: Create or audit GitHub repositories and READMEs to top-1% standard. Use when writing or reviewing a README, repo layout, community health files, docs structure, release or citation setup — software, AI/ML research code, or bioinformatics projects.
---

# GitHub Repository Best Practices

Core principle: a repo is judged in 30 seconds — README first impression → working quickstart → progressive depth. Every file earns its place; every claim links to evidence.

## What I do

- Audit/build the full repo skeleton: README anatomy, community health files, docs architecture, release/citation hygiene.
- Apply domain overlays: general OSS, AI/ML research code, bioinformatics pipelines.
- Write READMEs that survive skimming: pitch → proof → quickstart → depth.

## Patterns

### Non-negotiable files (GitHub community standards)
- `README.md`, `LICENSE` (the actual file, not "see license"), `.gitignore`.
- `CONTRIBUTING.md` (local setup + PR expectations), `CODE_OF_CONDUCT.md`, `SECURITY.md` (private-vuln contact, never "open an issue").
- `.github/ISSUE_TEMPLATE/` (+ `config.yml` contact links) and `.github/PULL_REQUEST_TEMPLATE.md` — templates cut triage cost.
- Research code: `CITATION.cff` (GitHub renders a "Cite this repository" button) + `CITATIONS.md` for tool references.
- Repo meta: description ≤120 chars, 5+ topics, tagged releases with notes. Changelog = keepachangelog + SemVer; an append-only IMPROVEMENTS.md may serve instead — never keep both.

### README anatomy (in order)
1. H1 + one-sentence pitch (what + for whom).
2. Badges — only live ones (CI, license, DOI); delete dead badges.
3. 30-second what/why; screenshot or GIF demo for anything visual.
4. **Quickstart**: copy-paste commands that work on a clean machine in ≤5 min.
5. Install with pinned env (`requirements.txt`+lock / `environment.yml` / container tag).
6. Minimal usage example with real input → real output.
7. Results table (ML/pipelines): metric + exact command reproducing each row.
8. Docs links · FAQ/troubleshooting as symptom→fix table · contributing pointer · citation (BibTeX) · license.
- TOC if >~150 lines. Write for skimmers: tables, bold lead-ins, fenced commands.

### Docs architecture
- Diátaxis split: tutorials (learning) / how-to (tasks) / reference (lookup) / explanation (rationale) — never mixed in one page.
- README = marketing + quickstart only; depth lives in `docs/`. Each doc self-contained so AI agents can extract one file without the rest.

### Engineering hygiene
- CI on every PR: lint + tests + build; badge must be truthful.
- Pin everything: lockfiles, container tags/digests, tool versions — never `@latest`/`:latest`.
- Conventional commits → SemVer tags → release notes. Secrets: placeholder pattern (`__KEY__`) injected at install; `.gitignore` covers env files.

### AI/ML overlay — ML Code Completeness Checklist, all 5 ticks
1. Dependencies specified · 2. training code · 3. evaluation code · 4. pretrained weights · 5. results table + exact reproduce command.
- Model card: intended use, limitations, bias, hardware used. Dataset card for data. Seeds recorded. Weights license ≠ code license — state both.

### Bioinformatics overlay — nf-core patterns
- `-profile test` CI on tiny data; version-pinned containers per process; parameter schema (`nextflow_schema.json`).
- Doc split: usage / parameters / output. Emit `versions.yml` into results; MultiQC summary; cite pipeline AND tools (`CITATIONS.md`).

## Anti-patterns
Wall-of-text README with no quickstart · TODO placeholders shipped · unpinned deps · missing LICENSE · docs duplicating the README · dead badges · UI tool with screenshot but no GIF.

## When to use me
New repo scaffolding · README writing/review · pre-release or open-sourcing audit · raising internal work to public-grade.
