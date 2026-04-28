#!/bin/bash

aerospace_layout=(
  icon.width=0
  label.width=0
  script="$PLUGIN_DIR/aerospace_layout.sh"
  icon.font="$FONT:Bold:16.0"
  display=active
)

sketchybar --add event window_focus                    \
           --add item aerospace_layout left             \
           --set aerospace_layout "${aerospace_layout[@]}" \
           --subscribe aerospace_layout window_focus     \
                                      aerospace_workspace_change \
                                      front_app_switched \
                                      mouse.clicked
