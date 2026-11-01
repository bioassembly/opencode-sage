#!/usr/bin/env bash
# Probes Tier 3 local OpenCode CLI harness & its configured provider.
# Returns JSON: {"available": bool, "harness": "opencode", "model": string, "latency_ms": number, "slot_0_busy": bool}
set -uo pipefail

python3 - <<'PYEOF'
import json, os, shutil, sys, time, urllib.request
from pathlib import Path

t0 = time.monotonic()
opencode_bin = shutil.which("opencode") or str(Path.home() / ".opencode" / "bin" / "opencode")
if not (Path(opencode_bin).is_file() and os.access(opencode_bin, os.X_OK)):
    print(json.dumps({"available": False, "harness": "opencode", "model": None, "latency_ms": None, "slot_0_busy": False}))
    sys.exit(1)

oc_cfg_path = Path.home() / ".config" / "opencode" / "opencode.json"
if not oc_cfg_path.is_file():
    ms = int((time.monotonic() - t0) * 1000)
    print(json.dumps({"available": True, "harness": "opencode", "model": "opencode-default", "latency_ms": ms, "slot_0_busy": False}))
    sys.exit(0)

try:
    cfg = json.loads(oc_cfg_path.read_text(encoding="utf-8"))
except Exception:
    print(json.dumps({"available": False, "harness": "opencode", "model": None, "latency_ms": None, "slot_0_busy": False}))
    sys.exit(1)

model_id = cfg.get("model") or "opencode-default"
providers = cfg.get("provider", {})
base_url = ""
api_key = ""
pref = str(model_id).split("/", 1)[0] if "/" in str(model_id) else ""
ordered = ([providers[pref]] if isinstance(providers, dict) and pref in providers else []) + (list(providers.values()) if isinstance(providers, dict) else [])
for p in ordered:
    if isinstance(p, dict):
        opts = p.get("options", {})
        burl = str(opts.get("baseURL") or "").strip()
        if burl and burl != "__BASE_URL__":
            base_url = burl
            k = str(opts.get("apiKey") or "").strip()
            if k not in ("", "__API_KEY__", "__UNSLOTH_API_KEY__"):
                api_key = k
            break

if not base_url:
    ms = int((time.monotonic() - t0) * 1000)
    print(json.dumps({"available": True, "harness": "opencode", "model": model_id, "latency_ms": ms, "slot_0_busy": False}))
    sys.exit(0)

v1 = base_url.rstrip("/")
root = v1[:-3] if v1.endswith("/v1") else v1
headers = {"Authorization": f"Bearer {api_key}"} if api_key else {}

online = False
try:
    with urllib.request.urlopen(urllib.request.Request(f"{v1}/models", headers=headers), timeout=1.5) as r:
        if r.status == 200:
            online = True
            data = json.loads(r.read().decode("utf-8")).get("data", [])
            if data and data[0].get("id"):
                model_id = data[0]["id"]
except Exception:
    try:
        with urllib.request.urlopen(urllib.request.Request(f"{root}/health", headers=headers), timeout=1.5) as r:
            online = r.status == 200
    except Exception:
        online = False

if not online:
    print(json.dumps({"available": False, "harness": "opencode", "model": model_id, "latency_ms": None, "slot_0_busy": False}))
    sys.exit(1)

slot_busy = False
try:
    with urllib.request.urlopen(urllib.request.Request(f"{root}/slots", headers=headers), timeout=1.0) as r:
        slots = json.loads(r.read().decode("utf-8"))
        if isinstance(slots, list) and slots:
            slot_busy = bool(slots[0].get("is_processing", False))
except Exception:
    pass

ms = int((time.monotonic() - t0) * 1000)
print(json.dumps({"available": True, "harness": "opencode", "model": model_id, "latency_ms": ms, "slot_0_busy": slot_busy}))
PYEOF
