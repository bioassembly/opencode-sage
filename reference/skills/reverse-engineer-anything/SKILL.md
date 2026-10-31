---
name: reverse-engineer-anything
description: "Reverse-engineer binaries, APKs, firmware, Electron, WASM/EVM via REA. Use for no-source targets: decompile, analyze."
---

# Reverse-Engineer Anything (REA)

Use when the claim depends on a shipped artifact, not on available source:
a native binary, shared library, APK, firmware image, Electron/ASAR bundle,
WASM/EVM bytecode, or "how does this app's feature work" with no repo.

## Do NOT use when

- Source is available → normal repo tools + Serena LSP, never REA.
- Web-app vulnerability audit → `security-audit`.
- Library/API docs question → Context7 / DeepWiki.
- Ordinary source-architecture analysis → say so, skip REA readiness checks.

## Readiness on this machine

No native providers installed (no Ghidra/Hopper/IDA). What works now,
with zero extra installs:

- JS/Electron trees: `analyze_javascript_application` (CLI fallback:
  `npx -y rea-agents@6.4.0 analyze-javascript-application <abs-path> --json`)
- .NET assembly metadata/CIL: `inspect_managed_artifact`
- ELF layout/symbols/relocations (offline, needs pwntools): `inspect_binary_layout`
- PE resources/icons: `inspect_pe_resources`

Native decompilation (`open_binary` → pseudocode) needs Ghidra. If asked:
say Ghidra is missing and stop — do not fake pseudocode from strings.

## Routing (first tool by target)

Binary/lib/database → `open_binary`, then focused tools, `close_binary` at end.
APK code/classes → `inspect_android_package`. Firmware → `inspect_firmware_regions`.
Large/unknown-size target → `"detail": "summary"` first, then page via the
returned Evidence ID (`inspect_analysis_view`); never re-run an identical call.

## Evidence contract

Every conclusion separates **observations / inferences / unknowns**, cites
Evidence IDs, keeps coverage limits. Static analysis never observed execution —
never claim runtime behavior from static output.

## Safety

Runtime-capture tools EXECUTE the target with user permissions. Analyze local
copies of user-owned targets only; untrusted binaries go nowhere near this
workflow without an isolated sandbox. Never broaden target or action beyond
the declared request. Findings with missing coverage are partial, say so.
