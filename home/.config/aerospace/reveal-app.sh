#!/usr/bin/env bash
set -euo pipefail

AEROSPACE="${AEROSPACE:-/opt/homebrew/bin/aerospace}"

bundle_id="${1:-}"
fallback_app="${2:-}"

if [ -z "$bundle_id" ]; then
  exit 64
fi

if [ ! -x "$AEROSPACE" ]; then
  [ -n "$fallback_app" ] && open -a "$fallback_app" >/dev/null 2>&1 || true
  exit 0
fi

window="$(
  "$AEROSPACE" list-windows \
    --monitor all \
    --app-bundle-id "$bundle_id" \
    --format "%{window-id}%{tab}%{workspace}%{tab}%{window-title}" 2>/dev/null |
    awk -F "$(printf '\t')" '
      $1 != "" && $2 != "" {
        if ($3 != "") {
          print
          exit
        }
        fallback = fallback ? fallback : $0
      }
      END {
        if (fallback != "") print fallback
      }
    '
)" || true

if [ -z "$window" ]; then
  if [ -n "$fallback_app" ]; then
    open -a "$fallback_app" >/dev/null 2>&1 || true
  else
    open -b "$bundle_id" >/dev/null 2>&1 || true
  fi
  exit 0
fi

IFS=$'\t' read -r window_id workspace _title <<<"$window"

current_workspace="$("$AEROSPACE" list-workspaces --focused 2>/dev/null | /usr/bin/head -n 1 || true)"
focused_window="$("$AEROSPACE" list-windows --focused --format "%{window-id}" 2>/dev/null | /usr/bin/head -n 1 || true)"

if [ "$current_workspace" != "$workspace" ]; then
  "$AEROSPACE" workspace "$workspace" >/dev/null 2>&1 || true
fi

if [ "$focused_window" != "$window_id" ]; then
  "$AEROSPACE" focus --window-id "$window_id" >/dev/null 2>&1 || true
fi
