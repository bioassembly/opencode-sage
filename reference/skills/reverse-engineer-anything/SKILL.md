---
name: reverse-engineer-anything
description: Autonomously inspect and reverse-engineer opaque or compiled artifacts encountered during codebase exploration — native binaries (ELF/PE/Mach-O, .so/.dll/.dylib), APKs, firmware, Electron/ASAR, minified JS bundles, .NET/JVM/Python/WASM/EVM bytecode — via the zero-overhead `rea` CLI without manual user invocation.
---

# Reverse-Engineer Anything (Autonomous On-Demand CLI)

## Autonomous Trigger Boundary (Source vs. Opaque Artifact)

When exploring **any** codebase, directory, or release bundle, choose tools automatically — **never wait for the user to ask for `rea`**:

- **Readable source exists** (`.py`, `.ts`, `.js`, `.rs`, `.go`, `.c`, `.cpp`, `.java`, `.nf`, etc.) → Use **LSP** + `grep` + sliced file reads. Never waste REA calls on source code.
- **No readable source for a component** (compiled binary, proprietary `.so`/`.dll`/`.dylib` extension, `.apk`/`.aab`/`.ipa`, Electron `app.asar`, minified/webpacked `dist/*.js` with no `src/`, `.wasm`, `.pyc`, `.jar`/`.class`, `.NET` DLL, EVM bytecode, or firmware `.bin`/`.img`) → **Automatically activate this protocol** and inspect via the `rea` CLI (`~/.local/bin/rea`, fallback `npx -y rea-agents@6.4.0`).

Running `rea` via CLI keeps **0 standing MCP schema tokens** on normal turns while giving full on-demand access to all 140+ REA analysis commands the instant an opaque artifact appears.

## Fast On-Demand CLI Ladder (Cheapest First)

Set `REA="rea"` (or `REA="npx -y rea-agents@6.4.0"` if `rea` is not in `PATH`):

1. **Universal Triage (1st call on any unknown binary/bundle)**:
   ```bash
   file <path>
   $REA inspect-artifact <abs-path>
   ```
   Returns artifact format, architecture, observations, and exact recommended next probes.

2. **Target-Specific Static Reconstruction**:
   - **Minified JS / Web / Electron / ASAR app**:
     `$REA analyze-javascript-application <abs-path>` (or `$REA inspect-electron-page <abs-path>`)
   - **Native ELF / PE / Mach-O / `.so` / `.dll` layout, imports & symbols**:
     `$REA inspect-binary-layout <abs-path>` (pair with `nm -DC <path>`, `readelf -Ws <path>`, or `objdump -d -M intel <path>` for targeted symbol disassembly)
   - **Android APK / AAB**:
     `$REA inspect-android-package <abs-path>` → `$REA inspect-android-class <abs-path> <class>` → `$REA inspect-android-method <abs-path> <class> <method>`
   - **.NET / Managed CLI assembly**:
     `$REA inspect-managed-artifact <abs-path>`
   - **Firmware image**:
     `$REA extract-firmware <abs-path>`
   - **WASM / EVM bytecode**:
     `$REA inspect-evm-interface <bytecode>` or `wasm2wat` / `$REA analyze <abs-path>`
   - **Full function / module decompilation** (when Ghidra/JEB provider is configured via `GHIDRA_INSTALL_DIR`):
     `$REA decompile <abs-path> ...` / `$REA function <abs-path> ...`
     *(If no native decompiler backend is installed on the host, combine `$REA inspect-binary-layout` + `objdump -d` / symbol imports and state clearly that Ghidra pseudocode is unavailable — never fabricate C pseudocode from strings.)*

3. **Token-Safe Output Scoping**:
   - Pipe large JSON outputs to `/tmp/rea-evidence.json` and query specific fields with `jq`, or project views with `$REA inspect-analysis-view` — never dump megabytes of raw disassembly into chat context.

## Evidence & Safety Contract
- Separate **verified static observations** (imports, exports, strings, control-flow, byte offsets) from **inferences** and **unknowns**.
- **Static First**: Use static `inspect-*` / `analyze-*` commands by default. Never execute untrusted binaries (`capture-process` / runtime scenarios) without explicit user approval and sandboxing.
