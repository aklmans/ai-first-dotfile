#!/bin/bash

power=(
	icon.color=$BAR_COLOR
	icon.padding_left=10
	label.color=$BAR_COLOR
  align=center
	background.height=26
	background.corner_radius=20
	background.padding_right=5
	background.border_width=$BORDER_WIDTH
	background.border_color=$BAR_COLOR
	background.color=$CYAN
  update_freq=120
	script="$PLUGIN_DIR/battery.sh"
)


sketchybar --add item battery right \
           --set battery "${power[@]}" \
           --subscribe battery system_woke power_source_change



