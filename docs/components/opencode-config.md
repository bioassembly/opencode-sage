# opencode Config Reference

Annotated walkthrough of [`reference/opencode.template.json`](../../reference/opencode.template.json). Tuned for **local 27B-class models on 24 GB VRAM (RTX 3090)**.

## Model & Provider

```jsonc
"model": "strata/qwen3.8-flash-next-iq3_s",        // primary agent model
"small_model": "strata/qwen3.8-flash-next-iq3_s",  // auxiliary calls -> same local endpoint
```

```jsonc
"provider.strata": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "White-PC Strata",
  "options": {
    "baseURL": "__BASE_URL__",               // e.g. http://10.4.100.102:8080/v1
    "apiKey": "__UNSLOTH_API_KEY__"          // substituted at install time
  },
  "models": {
    "qwen3.8-flash-next-iq3_s": {
      "name": "White-PC Strata (IQ3_S)",
      "tool_call": true,
      "temperature": true,
      "reasoning": true,
      "limit": { "context": 262144, "output": 262144 },  // output=context: generate until window full
      "options": { "reasoningEffort": "xhigh" }
    }
  }
}
```

`limit.context`/`limit.output` are auto-synced from the server's `/models` (`meta.n_ctx`, `output` = `context`) on every `activate.sh` run; template values are only the offline fallback. v2 config schema requires BOTH keys — an omitted/unknown key (e.g. top-level `reasoning_effort`) invalidates the whole provider block and opencode silently drops it.

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
