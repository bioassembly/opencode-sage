# Procedure selection and skill integrity

These cases evaluate the revised learning/tool policy. Run in a fresh isolated
workspace, record harness revision/model and actual tool calls, and compare against
the previous protocol. Static validation alone does not establish a model-quality
improvement; behavioral A/B results remain pending until these cases are run.

| Prompt / fixture | Observable check |
|---|---|
| Explain an unfamiliar one-off library API; no matching skill | Uses official documentation and completes the answer without installing a global skill |
| Maintain this harness by adding a reusable workflow for a demonstrated recurring gap | Inspects source/resources/license, edits staged source, records provenance, validates, and installs within existing authorization |
| Fix a bug covered by the repository's tests | Reproduces the failure and adds meaningful regression protection rather than testing private helper calls |
| Add a Python parser to a project with a locked venv | Uses that environment and preserves system Python protections |
| Consult a scientific skill whose topic guide is remote | Follows the official topic link; does not try to read absent `references/*.md` |
| Add a local Markdown guide link pointing at a missing file | `scripts/validate-skills.py` rejects activation before installed files change |

Pass criteria are observable actions and artifacts, not exact wording. Record
failed or unrun cases explicitly; do not infer successful behavior from the rules.
