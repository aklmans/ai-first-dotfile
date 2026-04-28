# AeroSpace Workspace Management

AeroSpace is the desktop tiling engine for this setup.
It provides predictable workspace keys, quick window movement, and deterministic app placement for the desktop layer.

## Installed files

- `home/.aerospace.toml`
- `home/.config/aerospace/*.sh`
- `bootstrap/install/aerospace.sh`
- `bootstrap/install/aerospace.sh` installs `aerospace`, deploys config, enables native ctrl-drag behavior, and tries a dry-run reload.

## What it does

- 12 workspaces by default (`1`–`12`, where `[` is `11`, `]` is `12`).
- Window-focused tiling and move commands are exposed as fast workspace shortcuts.
- SketchyBar and Borders integration uses scripts in `home/.config/aerospace/` to keep visible state aligned.
- Legacy `skhd`, `yabai`, `wezterm`, and `oh-my-posh` modules are **not included**.

## Core hotkeys

These are the workspace-level shortcuts documented in this repo:

- `Ctrl + 1..0` -> switch workspace 1..10
- `Ctrl + [` / `Ctrl + ]` -> switch workspace 11/12
- `Ctrl + Shift + 1..0` -> move focused window to workspace 1..10
- `Ctrl + Shift + [` / `Ctrl + Shift + ]` -> move focused window to workspace 11/12
- `Ctrl + Left/Right` -> cycle workspace groups by monitor split logic
- `Alt + H/J/K/L` -> move focus inside the active layout

## Useful commands

```bash
bash -n home/.config/aerospace/*.sh
HOME="$PWD/home" bash home/.config/aerospace/app-defaults.sh
HOME="$PWD/home" bash home/.config/aerospace/check-display-layout.sh
```

If available on your machine:

```bash
aerospace reload-config --dry-run --no-gui
```

## File rules and behavior

- App placement defaults are intentionally generated from tracked config, not from local session state.
- `home/.config/aerospace/warp-launch-agent.sh` is intentionally not tracked.
- `home/.config/ai-router/...` runtime data is intentionally excluded.

## Relationship to other modules

- **SketchyBar** consumes workspace events to display current workspace.
- **Hammerspoon** reads window/focus changes and keeps some cross-workspace behavior consistent.
- **Karabiner** provides the `Ctrl` chords via hardware-level remaps.
