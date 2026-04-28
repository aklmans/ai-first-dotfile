#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"

case "$action" in
    mission-control)
        btt_action=7
        ;;
    app-expose)
        btt_action=6
        ;;
    *)
        exit 64
        ;;
esac

/usr/bin/osascript -e "tell application \"BetterTouchTool\" to trigger_action \"{\\\"BTTPredefinedActionType\\\":${btt_action}}\"" >/dev/null
