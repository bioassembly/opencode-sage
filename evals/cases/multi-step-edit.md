# Case: Multi-step edit

**Type:** Multi-step edit · **Catches:** agentic-coding discipline, LSP value · **Temperature:** 0.3 (build defaults)

## Setup

```bash
mkdir -p /tmp/opencode/evals/multi-step && cd /tmp/opencode/evals/multi-step
cat > calc.py <<'EOF'
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def calculate(op, a, b):
    if op == "add":
        return add(a, b)
    elif op == "sub":
        return subtract(a, b)
    raise ValueError(f"unknown op {op}")
EOF
cat > test_calc.py <<'EOF'
from calc import calculate

def test_add():
    assert calculate("add", 2, 3) == 5

def test_sub():
    assert calculate("sub", 5, 2) == 3
EOF
python3 -m pytest test_calc.py -q   # must pass before starting
```

## Task (paste verbatim)

> Refactor `calc.py`: replace the if/elif dispatch in `calculate` with a dict mapping op → function. Keep the public behavior identical; tests must still pass.

## Checks

| # | Check | Command |
|---|---|---|
| 1 | Tests pass after the edit | `python3 -m pytest test_calc.py -q` exits 0 |
| 2 | No `if op ==` / `elif` remains in `calculate` | `! grep -nE 'if op|elif' calc.py` |
| 3 | Dispatch is a dict literal at module or function scope | `grep -n '{' calc.py` + manual confirm |
| 4 | Edit count ≤ 3 tool-edit calls (no churn rewrites of the whole file) | inspect session |

Fail pattern this case exists for: model rewrites the whole file and silently drops `raise ValueError`.
