#!/bin/bash

calendar=(
  icon=􀐫
  icon.color=$BAR_COLOR
	icon.padding_left=10
  label.color=$BAR_COLOR
  align=center
	background.height=26
	background.corner_radius=20
	background.padding_right=5
	background.border_width=$BORDER_WIDTH
	background.border_color=$BAR_COLOR
	background.color=$BLUE
  padding_left=5
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
