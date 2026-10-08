#!/usr/bin/env bash
# Health check diagnostics for opencode-sage harness
set -uo pipefail

echo "=== opencode-sage Harness Health Check (Doctor) ==="

check_pass() { echo -e "[\033[32mPASS\033[0m] $1"; }
check_warn() { echo -e "[\033[33mWARN\033[0m] $1"; }
check_fail() { echo -e "[\033[31mFAIL\033[0m] $1"; }

CFG="$HOME/.config/opencode/opencode.json"

# 1. opencode command
if command -v opencode &>/dev/null; then
  check_pass "opencode binary found ($(opencode --version 2>/dev/null || echo "installed"))"
elif [ -f "$HOME/.opencode/bin/opencode" ]; then
  check_pass "opencode binary found at $HOME/.opencode/bin/opencode"
else
  check_warn "opencode binary not found directly on PATH (check ~/.opencode/bin)"
fi

# 2. Prerequisites
if command -v npx &>/dev/null; then
  check_pass "npx binary found ($(node --version 2>&1))"
else
  check_fail "npx not found (required for local MCP servers)"
fi

if command -v uvx &>/dev/null; then
  check_pass "uvx binary found ($(uvx --version 2>&1 | head -1))"
else
  check_fail "uvx not found (required for fetch / python MCPs)"
fi

# 3. Config validation & permissions
if [ -f "$CFG" ]; then
  if jq empty "$CFG" &>/dev/null; then
    PERMS=$(stat -c '%a' "$CFG" 2>/dev/null || echo "unknown")
    if [ "$PERMS" = "600" ]; then
      check_pass "opencode.json valid and properly secured (perms: 600)"
    else
      check_warn "opencode.json valid, but perms are $PERMS (recommend 600)"
    fi
  else
    check_fail "opencode.json has invalid JSON syntax"
  fi
else
  check_fail "opencode.json not found at $CFG"
fi

# 4. Model Server Reachability
BASE_URL="http://10.4.100.102:8888/v1"
if [ -f "$CFG" ]; then
  BASE_URL="$(jq -r '.provider[]?.options.baseURL // empty' "$CFG" 2>/dev/null | head -n1)"
fi
BASE_URL="${BASE_URL:-http://localhost:8888/v1}"

if curl -s --max-time 3 "$BASE_URL/models" &>/dev/null; then
  MODEL_NAME=$(curl -s --max-time 3 "$BASE_URL/models" | jq -r '.data[0].id // "active"' 2>/dev/null)
  check_pass "Model server reachable at $BASE_URL (Model: $MODEL_NAME)"
else
  check_warn "Model server at $BASE_URL not reachable (is workplace-ai running?)"
fi

# 5. Remote MCP Server Reachability
if curl -s -X POST https://mcp.context7.com/mcp --max-time 4 -H "Content-Type: application/json" -d '{}' &>/dev/null; then
  check_pass "Context7 remote MCP endpoint responsive"
else
  check_warn "Context7 remote MCP endpoint unreachable or slow"
fi

if curl -s -X POST https://mcp.deepwiki.com/mcp --max-time 4 -H "Content-Type: application/json" -d '{}' &>/dev/null; then
  check_pass "DeepWiki remote MCP endpoint responsive"
else
  check_warn "DeepWiki remote MCP endpoint unreachable or slow"
fi

# 6. LSP Binaries
LSP_COUNT=$(ls "$HOME/.local/bin" 2>/dev/null | grep -cE 'language-server|pyright|marksman|intelephense' || true)
if [ "$LSP_COUNT" -ge 8 ]; then
  check_pass "Language servers installed in ~/.local/bin ($LSP_COUNT binaries found)"
else
  check_warn "Found only $LSP_COUNT LSP binaries in ~/.local/bin (run scripts/install-lsps.sh)"
fi

# 7. Skills count
SKILLS_DIR="$HOME/.config/opencode/skills"
if [ -d "$SKILLS_DIR" ]; then
  SKILLS_COUNT=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
  check_pass "Active skills installed: $SKILLS_COUNT skills in $SKILLS_DIR"
else
  check_fail "Skills directory not found at $SKILLS_DIR"
fi

# 8. Subagents count
AGENTS_DIR="$HOME/.config/opencode/agent"
if [ -d "$AGENTS_DIR" ]; then
  AGENTS_LIST=$(ls "$AGENTS_DIR" | tr '\n' ' ')
  check_pass "Custom agents active: $AGENTS_LIST"
else
  check_warn "Agent directory not found at $AGENTS_DIR"
fi

# 9. Backup Hygiene
BACKUPS=$(find "$HOME/.config/opencode" -maxdepth 1 -type d -name "backup-*" 2>/dev/null | wc -l)
if [ "$BACKUPS" -le 5 ]; then
  check_pass "Backup hygiene good ($BACKUPS backups found)"
else
  check_warn "High backup count ($BACKUPS backups). Consider pruning old backups."
fi

echo "==================================================="
