# Replication Guide

From a bare Ubuntu machine to a fully working local AI coding workstation. Every step includes a verification command — do not proceed past a failing check.

Estimated time: 60–90 minutes (dominated by model download).

---

## Stage 0 — Prerequisites

| Requirement | Minimum | Notes |
|---|---|---|
| OS | Linux (tested on Ubuntu) | macOS works for CPU-only; GPU scripts assume NVIDIA |
| GPU | NVIDIA 24 GB (tested: RTX 3090) | Smaller GPUs: use smaller quant / context |
| RAM | — | No minimum: the model runs fully in VRAM. Never offload layers to RAM — it drops throughput to ~2 tok/s |
| Disk | 18–26 GB | Adjustable; almost all of it is the model GGUF itself |

## Stage 1 — System dependencies

```bash
# Node.js 22+ (npm comes with it), git, build tools
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential git

# uv (provides `uvx`, used by the fetch MCP server)
curl -LsSf https://astral.sh/uv/install.sh | sh

# jq (used by activate.sh for key injection + validation)
sudo apt-get install -y jq
```

**Verify:**

```bash
node --version   # v22.x
npx --version    # 10+
uvx --version    # 0.11+ tested
jq --version     # 1.7 tested
```

Move npm's global prefix to a user-owned directory (avoids sudo-installed globals):

```bash
mkdir -p ~/.local
npm config set prefix ~/.local
export PATH="$HOME/.local/bin:$PATH"   # add to ~/.bashrc too
```

**Verify:** `npm config get prefix` → `/home/<you>/.local`

## Stage 2 — opencode

```bash
curl -fsSL https://opencode.ai/install | bash
```

**Verify:** `opencode --version`

## Stage 3 — GPU driver + power hygiene

```bash
sudo apt-get install -y nvidia-driver-550   # or your distro's current driver
```

Reboot, then **verify:** `nvidia-smi` shows your GPU.

Apply conservative power limits before heavy inference/training (script in this repo):

```bash
./scripts/gpu-prep.sh        # prompts for sudo; sets persistent mode + 320 W cap
```

## Stage 4 — Model serving

Serve through **Unsloth Studio**:

1. Install [Unsloth Studio](https://docs.unsloth.ai) and start its local server (`unsloth start`). It launches its own llama-server and exposes an OpenAI-compatible API on `http://localhost:8888/v1`.
2. Download/load a GGUF through Studio (served & tested: Qwen3.8-27B **Q6_K** — the quant this cookbook runs on; see [quantization.md](quantization.md)). Load **all layers onto the GPU** — RAM offload works but is unusably slow (~2 tok/s).

**Verify:**

```bash
curl -s http://127.0.0.1:8888/v1/models | jq .
```

> **Critical:** the config's `limit.context` must not exceed the server's real context. An inflated value makes opencode over-stuff prompts → silent truncation → the model "forgets" instructions mid-session.

## Stage 5 — Language servers

```bash
./scripts/install-lsps.sh
```

Installs to `~/.local/bin`: pyright, bash-language-server, yaml-language-server, vscode-json/html/css/eslint servers, tailwindcss-language-server, marksman (Markdown/Quarto). TypeScript is auto-provisioned by opencode on first use.

**Verify:** `ls ~/.local/bin | grep -E 'language-server|pyright|marksman'` → 11 entries.

## Stage 6 — Harness installation

1. Copy `reference/opencode.template.json` somewhere writable, or use this repo directly as your staging area.
2. Run the installer from the repo root:

```bash
./scripts/activate.sh --key "<any-non-empty-string>"
```

What it does:
- Backs up any existing `~/.config/opencode` config to `backup-<timestamp>/`
- Writes the config with your key substituted for `__UNSLOTH_API_KEY__`
- Installs agents, commands, and skills into global scope
- Validates the JSON before finishing

If you already have a working config with a key, omit `--key` and it reuses the existing one.

3. **Quit and restart opencode.** Config is read only at startup.

**Verify inside opencode:**
- MCP tools appear (context7, sequential-thinking, playwright, fetch, memory)
- `/gpu` command runs and reports VRAM + server PIDs
- Ask the agent to review a file → reviewer subagent triggers read-only

## Stage 7 — Post-install tuning

Set these to match your hardware (see [components/opencode-config.md](components/opencode-config.md)):

| Key | Set to |
|---|---|
| `provider.<name>.models.<m>.limit.context` | ≤ real server `n_ctx` from Stage 4 |
| `model` / `small_model` | your served model id |
| `provider...options.baseURL` | `:8888/v1` (Studio) or `:8080/v1` (direct) |

## Tested matrix

| Component | Version at time of writing |
|---|---|
| opencode | 1.18.x |
| Node.js | 22.23 |
| npm | 10.9 |
| uvx | 0.11.23 |
| jq | 1.7 |
| GPU/driver | RTX 3090, 24 GB |
| Model | Qwen3.8-27B GGUF (Q6_K), ctx 262144 declared / verify against server |

Newer versions almost certainly work; if something breaks, diff against the pinned versions above.
