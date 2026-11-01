#!/usr/bin/env python3
"""Dispatch a mechanical or review task payload to Tier 3 via the OpenCode CLI harness.

Execution paths:
  1. Primary: delegates through `hybrid-sage` (`mcp_core.handle_delegate_local`).
  2. Standalone fallback: invokes `opencode run --agent <reviewer|build|plan> --format json --auto`
     using OpenCode's configured provider (`~/.config/opencode/opencode.json`).
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import time
from pathlib import Path


def _discover_mcp_core_dir() -> Path | None:
    candidates: list[Path] = []
    env_dir = os.environ.get("HYBRID_SAGE_CORE_DIR")
    if env_dir:
        candidates.append(Path(env_dir).expanduser())
    agy_link = Path.home() / ".gemini" / "antigravity-cli" / "plugins" / "hybrid-sage"
    if agy_link.exists():
        candidates.append(agy_link.resolve().parent)
    oc_link = Path.home() / ".config" / "opencode" / "plugins" / "hybrid-sage.mjs"
    if oc_link.exists():
        candidates.append(oc_link.resolve().parent.parent.parent / "plugins")
    for anc in Path(__file__).resolve().parents:
        candidates.append(anc / "hybrid-sage" / "plugins")
    for cand in candidates:
        if (cand / "mcp_core.py").is_file():
            return cand
    return None


def _extract_code_fence(text: str) -> str:
    m = re.search(r"```[a-zA-Z0-9_+-]*\n(.*?)```", text, re.DOTALL)
    if m:
        return m.group(1).strip() + "\n"
    return text.strip() + "\n"


def _backup_existing_file(path: Path) -> Path | None:
    if not path.exists():
        return None
    backup_dir = path.parent / ".sage-backups"
    backup_dir.mkdir(parents=True, exist_ok=True)
    ts = int(time.time())
    backup_path = backup_dir / f"{path.name}.{ts}.bak"
    shutil.copy2(path, backup_path)
    return backup_path


def _run_verify_cmd(cmd_str: str, cwd: Path) -> subprocess.CompletedProcess[str]:
    argv = shlex.split(cmd_str)
    if not argv:
        return subprocess.CompletedProcess(args=[], returncode=1, stdout="", stderr="Empty verify_command")
    return subprocess.run(argv, shell=False, capture_output=True, text=True, cwd=str(cwd), timeout=120)


def main() -> int:
    parser = argparse.ArgumentParser(description="Dispatch Tier-3 task via local OpenCode harness.")
    parser.add_argument("--prompt", required=True, help="Task prompt to execute locally")
    parser.add_argument("--agent", default=None, help="OpenCode agent override (reviewer, build, plan)")
    parser.add_argument("--output-path", default=None, help="Directly write generated content to disk")
    parser.add_argument("--verify-command", default=None, help="Command to verify generated output (e.g. pytest -q)")
    parser.add_argument("--allow-busy", action="store_true", help="Do not skip if local slot 0 is busy")
    # Accept legacy flags as no-ops for backward compatibility
    parser.add_argument("--system", default=None, help=argparse.SUPPRESS)
    parser.add_argument("--endpoint", default=None, help=argparse.SUPPRESS)
    parser.add_argument("--max-tokens", type=int, default=None, help=argparse.SUPPRESS)
    parser.add_argument("--temperature", type=float, default=None, help=argparse.SUPPRESS)
    parser.add_argument("--reasoning-effort", default=None, help=argparse.SUPPRESS)
    args = parser.parse_args()

    # 1. Primary: Delegate via hybrid-sage mcp_core
    core_dir = _discover_mcp_core_dir()
    if core_dir is not None:
        if str(core_dir) not in sys.path:
            sys.path.insert(0, str(core_dir))
        import mcp_core  # type: ignore

        mode = "review" if (args.agent == "reviewer" or "review" in args.prompt.lower()) else "code"
        res = mcp_core.handle_delegate_local({
            "prompt": args.prompt,
            "mode": mode,
            "output_path": args.output_path,
            "verify_command": args.verify_command,
            "skip_if_busy": not args.allow_busy,
            "files": [args.output_path] if args.output_path else [],
        })
        if res.get("status") == "ok":
            print(res.get("response", ""))
            return 0
        if res.get("status") in ("busy_skipped", "skipped", "busy", "offline"):
            sys.stderr.write(f"[HYBRID-TIER3 WORKER BUSY/OFFLINE]: {res.get('message') or res.get('error', '')}\n")
            return 2

    # 2. Standalone fallback: invoke OpenCode CLI directly
    opencode_bin = shutil.which("opencode") or str(Path.home() / ".opencode" / "bin" / "opencode")
    if not (Path(opencode_bin).is_file() and os.access(opencode_bin, os.X_OK)):
        sys.stderr.write("[HYBRID-TIER3 WORKER OFFLINE]: OpenCode CLI not found. Fallback to Tier 2.\n")
        return 2

    agent_name = args.agent or ("reviewer" if "review" in args.prompt.lower() else "build")
    cmd = [opencode_bin, "run", "--agent", agent_name, "--format", "json", "--auto", args.prompt]
    t0 = time.monotonic()
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    elapsed = round(time.monotonic() - t0, 2)

    text_parts: list[str] = []
    for line in proc.stdout.splitlines():
        if not line.strip():
            continue
        try:
            ev = json.loads(line)
            part = ev.get("part", {})
            if (ev.get("type") == "text" or part.get("type") == "text") and part.get("text"):
                text_parts.append(part["text"])
        except Exception:
            pass

    clean_text = "\n".join(text_parts).strip() or proc.stdout.strip()
    clean_text = re.sub(r"<think>.*?</think>", "", clean_text, flags=re.DOTALL)
    clean_text = re.sub(r"<think>.*$", "", clean_text, flags=re.DOTALL).strip()

    out_dir = Path.cwd() / ".sage-outputs"
    out_dir.mkdir(parents=True, exist_ok=True)
    full_out = out_dir / f"opencode-{time.strftime('%Y%m%d-%H%M%S')}.md"
    full_out.write_text(clean_text, encoding="utf-8")

    if args.output_path:
        out_p = Path(args.output_path).resolve()
        out_p.parent.mkdir(parents=True, exist_ok=True)
        _backup_existing_file(out_p)
        out_p.write_text(_extract_code_fence(clean_text), encoding="utf-8")
        if args.verify_command:
            _run_verify_cmd(args.verify_command, out_p.parent)
        print(f"[HYBRID-TIER3 SUCCESS]: Wrote output to {out_p} via OpenCode {agent_name} (Time: {elapsed}s)")
        return 0

    preview = clean_text[:3000]
    if len(clean_text) > 3000:
        preview += f"\n\n... [Response capped at 3000 chars. Full output saved to: {full_out}]"
    print(preview)
    return 0


if __name__ == "__main__":
    sys.exit(main())
