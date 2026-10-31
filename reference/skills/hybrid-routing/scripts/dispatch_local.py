#!/usr/bin/env python3
"""Dispatch a deterministic or mechanical task payload to Tier 3 (Local LLM worker).

Falls back gracefully with exit code 2 if worker is unreachable.
Usage:
  python3 dispatch_local.py --prompt "Format this JSON" [--system "..."] [--endpoint "..."] [--max-tokens 2048]
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error

CANDIDATE_ENDPOINTS = [
    os.environ.get("LOCAL_LLM_ENDPOINT", ""),
    "http://localhost:8080/v1",
    "http://10.4.100.102:8080/v1",
    "http://localhost:11434/v1"
]

def find_working_endpoint(preferred=None):
    if preferred:
        preferred = preferred.rstrip("/")
        try:
            req = urllib.request.Request(f"{preferred}/models", method="GET")
            with urllib.request.urlopen(req, timeout=1.5) as resp:
                if resp.status == 200:
                    return preferred
        except Exception:
            pass
    for ep in CANDIDATE_ENDPOINTS:
        if not ep:
            continue
        ep = ep.rstrip("/")
        try:
            req = urllib.request.Request(f"{ep}/models", method="GET")
            with urllib.request.urlopen(req, timeout=1.5) as resp:
                if resp.status == 200:
                    return ep
        except Exception:
            continue
    return None

def main():
    parser = argparse.ArgumentParser(description="Dispatch deterministic tasks to Tier 3 Local AI worker")
    parser.add_argument("--prompt", required=True, help="Instruction or text payload")
    parser.add_argument("--system", default="You are a precise, deterministic code and instruction execution worker. Output only requested results with zero commentary.", help="System prompt")
    parser.add_argument("--endpoint", default=None, help="Override base URL (e.g. http://localhost:8080/v1)")
    parser.add_argument("--max-tokens", type=int, default=2048, help="Max tokens for completion")
    parser.add_argument("--temperature", type=float, default=0.1, help="Sampling temperature")
    args = parser.parse_args()

    endpoint = find_working_endpoint(args.endpoint)
    if not endpoint:
        sys.stderr.write("[HYBRID-TIER3 WORKER OFFLINE]: No local LLM reachable. Fallback to Tier 2 (Gemini 3.8 Flash).\n")
        return 2

    url = f"{endpoint}/chat/completions"
    payload = {
        "model": "local-worker",
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
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            content = data["choices"][0]["message"]["content"]
            print(content)
            return 0
    except urllib.error.URLError as e:
        sys.stderr.write(f"[HYBRID-TIER3 WORKER CONNECTION ERROR]: {e}\n")
        return 2
    except Exception as e:
        sys.stderr.write(f"[HYBRID-TIER3 ERROR]: {e}\n")
        return 1

if __name__ == "__main__":
    sys.exit(main())
