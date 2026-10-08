#!/usr/bin/env bash
# Install all language servers used by the harness into ~/.local/bin.
# Requires Stage-1 prerequisites: Node 22+, npm prefix set to ~/.local.
# Idempotent; safe to re-run.
set -euo pipefail

command -v npm >/dev/null || { echo "npm not found — see docs/replicate.md Stage 1." >&2; exit 1; }

echo "==> npm packages (prefix: $(npm config get prefix))"
npm install -g --silent \
  pyright \
  @bash-lsp/bash-language-server \
  yaml-language-server \
  vscode-langservers-extracted \
  @tailwindcss/language-server \
  intelephense \
  typescript \
  typescript-language-server

echo "==> marksman (Markdown / Quarto .qmd)"
BIN="$HOME/.local/bin/marksman"
if [[ ! -x "$BIN" ]]; then
  ARCH=$(uname -m); case "$ARCH" in x86_64) MARCH=amd64 ;; aarch64) MARCH=arm64 ;; *) echo "unsupported arch: $ARCH" >&2; exit 1 ;; esac
  URL=$(curl -fsSL https://api.github.com/repos/artempyanykh/marksman/releases/latest \
    | grep -o "https://[^ ]*marksman-linux-${MARCH}[^ \"]*" | head -n1)
  [ -n "$URL" ] || { echo "could not resolve marksman release URL" >&2; exit 1; }
  curl -fsSL "$URL" -o "$BIN" && chmod +x "$BIN"
else
  echo "    already installed, skipping"
fi

echo
echo "Installed binaries:"
ls "$HOME/.local/bin" | grep -E 'language-server|pyright|marksman|intelephense' || true
echo
echo "LSP installation and verification complete."
