#!/usr/bin/env python3
"""Dispatch a prompt or mechanical task payload to a local OpenAI-compatible inference worker.

Falls back gracefully with exit code 2 if worker is unreachable.
Usage:
  python3 dispatch_local.py --prompt "Format this JSON" [--system "..."] [--max-tokens 2048]
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error

def get_config():
    cfg_path = os.path.expanduser("~/.gemini/config/hybrid-routing.json")
    if os.path.exists(cfg_path):
        try:
            with open(cfg_path) as f:
                return json.load(f)
        except Exception:
            pass
    return {
        "enabled": False,
        "local_endpoint": "http://localhost:8080/v1",
        "fallback_to_frontier": True
    }

def main():
    parser = argparse.ArgumentParser(description="Dispatch deterministic tasks to local AI worker")
    parser.add_argument("--prompt", required=True, help="Instruction or text payload")
    parser.add_argument("--system", default="You are a precise, deterministic code and instruction execution worker. Output only requested results with zero commentary.", help="System prompt")
    parser.add_argument("--endpoint", default=None, help="Override base URL (e.g. http://localhost:8080/v1)")
    parser.add_argument("--max-tokens", type=int, default=2048, help="Max tokens for completion")
    parser.add_argument("--temperature", type=float, default=0.1, help="Sampling temperature")
    args = parser.parse_args()

    cfg = get_config()
    endpoint = args.endpoint or cfg.get("local_endpoint") or "http://localhost:8080/v1"
    endpoint = endpoint.rstrip("/")

    url = f"{endpoint}/chat/completions"
    payload = {
        "messages": [
            {"role": "system", "content": args.system},
            {"role": "user", "content": args.prompt}
        ],
        "temperature": args.temperature,
        "max_tokens": args.max_tokens,
        "stream": False
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            content = data["choices"][0]["message"]["content"]
            print(content)
            return 0
    except urllib.error.URLError as e:
        sys.stderr.write(f"[HYBRID-ROUTING WORKER OFFLINE]: {e}\n")
        return 2
    except Exception as e:
        sys.stderr.write(f"[HYBRID-ROUTING ERROR]: {e}\n")
        return 1

if __name__ == "__main__":
    sys.exit(main())
