#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "--health-check" ]; then
  [ "${AI_ROUTER_ENABLE_CODEX_PROVIDER:-0}" = "1" ] && command -v codex >/dev/null 2>&1 && codex --version >/dev/null 2>&1
  exit
fi

if ! command -v codex >/dev/null 2>&1; then
  printf '%s\n' "codex CLI not found" >&2
  exit 69
fi

if [ "${AI_ROUTER_ENABLE_CODEX_PROVIDER:-0}" != "1" ]; then
  printf '%s\n' "codex text provider is disabled by default; use the Coding Agent menu, or set AI_ROUTER_ENABLE_CODEX_PROVIDER=1." >&2
  exit 69
fi

prompt="$(/bin/cat)"
codex exec "$prompt"

