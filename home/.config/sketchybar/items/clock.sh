#!/bin/bash

COLOR=$MAGENTA

clock=(
  icon=􀐫
  icon.padding_left=10
  icon.color=$BAR_COLOR
  label.color=$BAR_COLOR
  label.padding_right=5
  label.width=78
  align=center
	background.height=26
	background.corner_radius=20
	background.padding_right=5
	background.border_width=$BORDER_WIDTH
	background.border_color=$BAR_COLOR
  background.color=$MAGENTA
  update_freq=1
  script="$PLUGIN_DIR/clock.sh"
  # click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item clock right       \
           --set clock "${clock[@]}"
