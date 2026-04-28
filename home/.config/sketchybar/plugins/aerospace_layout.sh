#!/usr/bin/env bash

AEROSPACE="${AEROSPACE:-/opt/homebrew/bin/aerospace}"

window_state() {
  source "$CONFIG_DIR/colors.sh"
  source "$CONFIG_DIR/icons.sh"

  WINDOW="$("$AEROSPACE" list-windows --focused --format "%{window-layout}%{tab}%{window-parent-container-layout}%{tab}%{workspace-root-container-layout}%{tab}%{window-is-fullscreen}" 2>/dev/null || true)"

  COLOR=$BAR_BORDER_COLOR
  ICON=""
  LABEL=""

  if [ -n "$WINDOW" ]; then
    IFS=$'\t' read -r WINDOW_LAYOUT PARENT_LAYOUT ROOT_LAYOUT IS_FULLSCREEN <<<"$WINDOW"

    if [ "$IS_FULLSCREEN" = "true" ] || [[ "$WINDOW_LAYOUT" == *fullscreen* ]]; then
      ICON=$YABAI_FULLSCREEN_ZOOM
      COLOR=$GREEN
    elif [ "$WINDOW_LAYOUT" = "floating" ]; then
      ICON=$YABAI_FLOAT
      COLOR=$RED
    elif [[ "$PARENT_LAYOUT" == *accordion* || "$ROOT_LAYOUT" == *accordion* ]]; then
      ICON=$YABAI_STACK
      LABEL="ACC"
      COLOR=$MAGENTA
    fi
  fi

  args=(--animate sin 10 --set "$NAME" icon.color=$COLOR)

  [ -z "$LABEL" ] && args+=(label.width=0) \
                  || args+=(label="$LABEL" label.width=36)

  [ -z "$ICON" ] && args+=(icon.width=0) \
                 || args+=(icon="$ICON" icon.width=30)

  sketchybar -m "${args[@]}"
}

mouse_clicked() {
  "$AEROSPACE" layout floating tiling 2>/dev/null || true
  window_state
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  *) window_state ;;
esac
