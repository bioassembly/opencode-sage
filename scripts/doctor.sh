#!/usr/bin/env bash
# Health check diagnostics for opencode-sage harness
set -uo pipefail

echo "=== opencode-sage Harness Health Check (Doctor) ==="

check_pass() { echo -e "[\033[32mPASS\033[0m] $1"; }
check_info() { echo -e "[\033[36mINFO\033[0m] $1"; }
check_warn() { echo -e "[\033[33mWARN\033[0m] $1"; }
check_fail() { echo -e "[\033[31mFAIL\033[0m] $1"; }

CFG="$HOME/.config/opencode/opencode.json"
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
REPO="$(cd -P "$(dirname "$SOURCE")/.." && pwd)"

# Prune backups if requested
if [ "${1:-}" = "--prune-backups" ]; then
  mapfile -t BACKUP_DIRS < <(find "$HOME/.config/opencode" -maxdepth 1 -type d -name "backup-*" 2>/dev/null | sort)
  if [[ ${#BACKUP_DIRS[@]} -gt 5 ]]; then
    PRUNE_COUNT=$((${#BACKUP_DIRS[@]} - 5))
    for ((i=0; i<PRUNE_COUNT; i++)); do
      rm -rf "${BACKUP_DIRS[$i]}"
    done
    echo "Pruned $PRUNE_COUNT old backup(s)."
  fi
fi

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

if command -v rea &>/dev/null || [ -x "$HOME/.local/bin/rea" ]; then
  check_pass "rea CLI installed (zero-overhead autonomous binary inspection ready)"
else
  check_info "rea CLI not globally installed (falls back to npx -y rea-agents@6.4.0)"
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

# 4. Configured Model Provider Reachability (Optional for offline/unstarted local servers)
BASE_URL="http://127.0.0.1:8080/v1"
API_KEY=""
if [ -f "$CFG" ]; then
  BASE_URL="$(jq -r '.provider[]?.options.baseURL // empty' "$CFG" 2>/dev/null | head -n1)"
  API_KEY="$(jq -r '.provider[]?.options.apiKey // empty' "$CFG" 2>/dev/null | head -n1)"
fi
BASE_URL="${BASE_URL:-http://127.0.0.1:8080/v1}"

AUTH_HEADER=()
if [ -n "$API_KEY" ]; then
  AUTH_HEADER=(-H "Authorization: Bearer $API_KEY")
fi

if curl -s -f --max-time 3 "${AUTH_HEADER[@]}" "$BASE_URL/models" &>/dev/null; then
  MODEL_NAME=$(curl -s --max-time 3 "${AUTH_HEADER[@]}" "$BASE_URL/models" | jq -r '.data[0].id // "active"' 2>/dev/null)
  check_pass "Model provider reachable at $BASE_URL (Model: $MODEL_NAME)"
else
  check_info "Model provider at $BASE_URL not currently running (start your OpenAI-compatible server or set --base-url)"
fi

# 4b. Optional Hybrid SAGE Integration Check
if [ -f "$CFG" ]; then
  if jq -e '.mcp["hybrid-sage"]' "$CFG" &>/dev/null; then
    check_pass "hybrid-sage MCP & plugin registered in opencode.json"
  else
    check_info "hybrid-sage plugin not installed (standalone OpenCode mode)"
  fi
fi

# 5. Remote MCP Server Reachability
if curl -s -f -X POST https://mcp.context7.com/mcp --max-time 4 -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d '{"jsonrpc":"2.0","method":"ping","id":1}' &>/dev/null; then
  check_pass "Context7 remote MCP endpoint responsive"
else
  check_warn "Context7 remote MCP endpoint unreachable or slow"
fi

if curl -s -f -X POST https://mcp.deepwiki.com/mcp --max-time 4 -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d '{"jsonrpc":"2.0","method":"ping","id":1}' &>/dev/null; then
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

# 7. Skills count (accounting for optional gitignored skills.local/ + hybrid-sage model-router symlink)
SKILLS_DIR="$HOME/.config/opencode/skills"
REF_SKILLS_DIR="$REPO/reference/skills"
LOCAL_SKILLS_DIR="$REPO/reference/skills.local"
if [ -d "$SKILLS_DIR" ]; then
  SKILLS_COUNT=$(find -L "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
  if [ -d "$REF_SKILLS_DIR" ]; then
    REF_SKILLS_COUNT=$(find "$REF_SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
    LOCAL_SKILLS_COUNT=0
    [ -d "$LOCAL_SKILLS_DIR" ] && LOCAL_SKILLS_COUNT=$(find -L "$LOCAL_SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
    EXTRA_PLUGIN=0
    [ -L "$SKILLS_DIR/model-router" ] && EXTRA_PLUGIN=1
    EXPECTED=$((REF_SKILLS_COUNT + LOCAL_SKILLS_COUNT + EXTRA_PLUGIN))
    if [ "$SKILLS_COUNT" -eq "$EXPECTED" ]; then
      check_pass "Active skills installed: $SKILLS_COUNT skills in $SKILLS_DIR (synced with reference)"
    else
      check_warn "Active skills count ($SKILLS_COUNT) differs from expected ($EXPECTED). Run scripts/activate.sh to sync."
    fi
  else
    check_pass "Active skills installed: $SKILLS_COUNT skills in $SKILLS_DIR"
  fi
else
  check_fail "Skills directory not found at $SKILLS_DIR"
fi

# 8. Subagents count
AGENTS_DIR="$HOME/.config/opencode/agent"
REF_AGENTS_DIR="$REPO/reference/agents"
if [ -d "$AGENTS_DIR" ]; then
  AGENTS_LIST=$(ls "$AGENTS_DIR" | tr '\n' ' ')
  if [ -d "$REF_AGENTS_DIR" ]; then
    REF_AGENTS_COUNT=$(find "$REF_AGENTS_DIR" -name '*.md' | wc -l)
    INST_AGENTS_COUNT=$(find "$AGENTS_DIR" -name '*.md' | wc -l)
    if [ "$INST_AGENTS_COUNT" -eq "$REF_AGENTS_COUNT" ]; then
      check_pass "Custom agents active: $AGENTS_LIST(synced with reference)"
    else
      check_warn "Custom agents active ($INST_AGENTS_COUNT) differs from reference ($REF_AGENTS_COUNT): $AGENTS_LIST"
    fi
  else
    check_pass "Custom agents active: $AGENTS_LIST"
  fi
else
  check_warn "Agent directory not found at $AGENTS_DIR"
fi

# 9. Lean MCP Footprint & Backup Hygiene
if [ -f "$CFG" ]; then
  if jq -e '.mcp["rea"]' "$CFG" &>/dev/null; then
    check_warn "REA MCP active (170 tools / ~67.6k schema tokens per turn; re-run activate.sh without --with-rea to use zero-overhead rea CLI)"
  else
    check_pass "Lean MCP footprint active (REA 170-tool MCP omitted, saving ~67.6k tokens/turn; rea CLI ready)"
  fi
fi

BACKUPS=$(find "$HOME/.config/opencode" -maxdepth 1 -type d -name "backup-*" 2>/dev/null | wc -l)
if [ "$BACKUPS" -le 5 ]; then
  check_pass "Backup hygiene good ($BACKUPS backups found)"
else
  check_warn "High backup count ($BACKUPS backups). Run with --prune-backups or re-run activate.sh to prune."
fi

echo "==================================================="
