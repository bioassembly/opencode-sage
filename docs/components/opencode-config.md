# opencode Config Reference

Annotated walkthrough of [`reference/opencode.template.json`](../../reference/opencode.template.json). Tuned for **local 27B-class models on 24 GB VRAM (RTX 3090)**.

## Model & Provider

```jsonc
"model": "workplace-ai/qwen3.8-27b",        // primary agent model
"small_model": "workplace-ai/qwen3.8-27b",  // auxiliary calls -> same local endpoint
```

```jsonc
"provider.workplace-ai": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "IGF Workplace AI (Komputer Putih)",
  "options": {
    "baseURL": "__BASE_URL__",               // e.g. http://10.4.100.102:8888/v1 or http://localhost:8888/v1
    "apiKey": "__UNSLOTH_API_KEY__"          // substituted at install time
  },
  "models": {
    "qwen3.8-27b": {
      "name": "IGF Workplace AI",
      "tool_call": true,
      "temperature": true,
      "reasoning": true,
      "limit": { "context": 262144, "output": 8192 },
      "reasoning_effort": "xhigh"
    },
    "qwen3.8-27b-thinking": {
      "name": "Qwen 3.8 Local (thinking)",
      "tool_call": true,
      "temperature": true,
      "reasoning": true,
      "limit": { "context": 262144, "output": 8192 },
      "reasoning_effort": "xhigh"
    }
  }
}
```

## Context Discipline

```jsonc
"tool_output": { "max_lines": 200, "max_bytes": 16384 }
```
Caps every tool return to prevent runaway output from blowing out prompt context.

```jsonc
"compaction": { "auto": true, "prune": true, "tail_turns": 12 }
```
Compaction prunes old tool observations instead of hallucinating lossy summaries.

## Permissions

```jsonc
"permission": {
  "skill": { "*": "allow" },
  "bash": {
    "rm -rf /": "deny",  "rm -rf /*": "deny",  "rm -rf ~*": "deny",
    "sudo rm*": "deny",  "mkfs*": "deny",
    "dd if=* of=/dev/*": "deny",  "chmod -R 777 *": "deny",
    "curl * | bash": "deny",  "curl * | sh": "deny",
    "wget * | bash": "deny",  "wget * | sh": "deny"
  }
}
```

Deny-list tripwire permanently blocking destructive command patterns.

## Plugins

```jsonc
"plugin": [
  "@dietrichgebert/ponytail"
]
```
Enables Ponytail lazy dev mode for AI agents.

## Applying Changes

```bash
./scripts/activate.sh [--key <api-key>] [--base-url <url>]
```
