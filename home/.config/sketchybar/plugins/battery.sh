#!/usr/bin/env bash
set -euo pipefail

SKETCHYBAR_BIN="${SKETCHYBAR_BIN:-sketchybar}"
ITEM_NAME="${NAME:-battery}"
SHOW_BATTERY="${SKETCHYBAR_SHOW_BATTERY:-auto}"

hide_battery() {
  "$SKETCHYBAR_BIN" --set "$ITEM_NAME" drawing=off >/dev/null 2>&1 || true
}

BATTERY_INFO="$(pmset -g batt 2>/dev/null || true)"

case "$SHOW_BATTERY" in
  0|false|False|FALSE|off|Off|OFF|no|No|NO)
    hide_battery
    exit 0
    ;;
  1|true|True|TRUE|on|On|ON|yes|Yes|YES)
    ;;
  auto|"")
    case "$BATTERY_INFO" in
      *InternalBattery*)
        ;;
      *)
        hide_battery
        exit 0
        ;;
    esac
    ;;
  *)
    printf 'Unknown SKETCHYBAR_SHOW_BATTERY value: %s\n' "$SHOW_BATTERY" >&2
    hide_battery
    exit 64
    ;;
esac

PERCENTAGE="$(printf '%s\n' "$BATTERY_INFO" | grep -Eo '[0-9]+%' | head -n 1 | cut -d% -f1)"

if [ "$PERCENTAGE" = "" ]; then
  hide_battery
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="􀛨"
  ;;
  [6-8][0-9]) ICON="􀺸"
  ;;
  [3-5][0-9]) ICON="􀺶"
  ;;
  [1-2][0-9]) ICON="􀛩"
  ;;
  *) ICON="􀛪"
esac

if printf '%s\n' "$BATTERY_INFO" | grep -F 'AC Power' >/dev/null 2>&1; then
  ICON="􀢋"
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
"$SKETCHYBAR_BIN" --set "$ITEM_NAME" drawing=on icon="$ICON ${PERCENTAGE}%"
