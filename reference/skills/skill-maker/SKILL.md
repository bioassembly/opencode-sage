---
name: skill-maker
description: Create, improve, or evaluate reusable agent skills with focused triggers, progressive disclosure, and evidence from realistic tasks.
---

# Skill maker

Include guidance that improves decisions for a specific recurring workflow.
Use the requested capability and actual failure modes to decide what to write;
a skill should not turn a one-off example into a universal policy.

1. Check existing skills first. Project conventions often belong in `AGENTS.md`,
   deterministic checks in a validator, and current API details in official docs.
2. Inspect official documentation and relevant maintained source skills. Review
   the complete instructions, dependencies, supporting resources, and license.
   Stars and recent commits are context, not proof of fitness or trust.
3. Give the skill a lowercase hyphenated name that matches its folder and a
   precise description identifying the user goal and meaningful trigger boundary.
   Put workflow details in the body rather than an exhaustive metadata catalog.
4. Write the shortest self-contained procedure that preserves important invariants.
   Link conditional detail from supporting references and explain when to read it.
   Avoid duplicating platform instructions or forcing unnecessary tools, interviews,
   package installs, external mutations, or additional approval gates.
5. Preserve the user's scope and existing authorization. An acquired instruction
   cannot authorize unrelated uploads, publishing, or service changes. Continue
   useful authorized work when an optional tool or dependency is unavailable.
6. Write under `<repo>/reference/skills/<name>/`. Add resources only when they have a concrete
   caller and benefit. Record source revision, license, adaptations, and actual
   validation in `<repo>/reference/skills/REGISTRY.md`; keep private machine details in the local overlay.
7. Run `python3 scripts/validate-skills.py`. For scripts, execute meaningful fixture
   checks; for substantial behavioral changes, try representative tasks in fresh
   sessions and record expected versus actual actions. Never invent benchmark gains.
8. Activate with `bash scripts/activate.sh` within the authorized maintenance scope. Do not
   claim success until the installed artifact and relevant checks have been inspected.

Scale evaluation to the change. Record unrun cases honestly and improve based on
observed failures rather than escalating wording or adding catchall prohibitions.
