# Hammerspoon Automation

Hammerspoon is the event and workflow glue that connects keyboard shortcuts, AeroSpace state, and AI Router commands.

![Coding agent chooser](../../../assets/screenshots/agent-chooser.png)

## Installed files

- `home/.hammerspoon/init.lua`
- `home/.hammerspoon/ai_hotkeys.lua`
- `home/.hammerspoon/app_reveal.lua`
- `bootstrap/install/hammerspoon.sh`

## Install

```bash
./bootstrap/install/hammerspoon.sh
```

Open Hammerspoon and allow Accessibility + Automation permissions.

## Key responsibilities

- Launch/activate desktop windows and recover workspace focus.
- Provide fallback prompt chooser behavior when dynamic catalogs are not available.
- Execute AI Router actions from CapsLock hotkeys.
- Clear SketchyBar AI attention badges when tracked apps become active.
- Reveal tracked app windows through AeroSpace after app activation events.
- Keep chooser tools deterministic and local.

## Runtime behavior

- Uses tracked config in `~/.hammerspoon`.
- Reads catalog/data from `~/.config/ai-router/`.
- Writes AI attention clear requests through `~/.config/sketchybar/plugins/ai_app_notifications.sh`.
- Does not read the macOS notification database directly.
- Keeps `tmp` logs local and does not persist secrets.

## AI attention bridge

Hammerspoon watches focused windows and application activation events for:

- Warp
- Codex
- IntelliJ IDEA
- GoLand

When one of these apps becomes active, Hammerspoon writes a clear request and triggers the SketchyBar sync event. SketchyBar then clears the local status-bar badge using its own runtime state and notification database access.

## Script checks

```bash
lua -e "assert(loadfile('home/.hammerspoon/init.lua'))"
lua -e "assert(loadfile('home/.hammerspoon/ai_hotkeys.lua'))"
```

## Core interaction with other modules

- **Karabiner** creates `CapsLock` chords.
- **AeroSpace** provides workspace commands and window IDs for focus/move logic.
- **AI Router** executes render/run commands and agent chooser actions.

## Notes

- Do not add blocking `hs.execute` logic in local customizations.
- Keep external command invocation explicit and idempotent.
