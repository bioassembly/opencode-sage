# Case: API accuracy

**Type:** API accuracy · **Catches:** context7 value, model drift · **Temperature:** 0.2 (build defaults)

## Setup

```bash
mkdir -p /tmp/opencode/evals/api-accuracy && cd /tmp/opencode/evals/api-accuracy
npm init -y >/dev/null
```

## Task (paste verbatim)

> Using jq 1.7, write a file `extract.sh` that prints only the `name` field of every object in the array stored in `data.json`, one per line. Then create a `data.json` with two objects and prove the script works.

## Checks

| # | Check | Command |
|---|---|---|
| 1 | `extract.sh` exists and is executable or runnable via `bash` | `test -f extract.sh && echo PASS` |
| 2 | Output is exactly the two names, one per line | `bash extract.sh` → compare to `jq -r '.[].name' data.json` |
| 3 | The jq invocation used is real jq 1.7 syntax (no invented flags) — grep the script | manual: no `-x`-style hallucinated flags; `jq --help` confirms each flag used |
| 4 | Session log shows a context7 lookup before writing code | inspect session tool calls |

Check 4 is the point of the case: a 27B without docs retrieval invents flags. Fail = wrote code with zero lookups.
