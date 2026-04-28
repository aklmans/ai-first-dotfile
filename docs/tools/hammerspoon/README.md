# Hammerspoon Automation

Hammerspoon is the event and workflow glue that connects keyboard shortcuts, AeroSpace state, and AI Router commands.

## Installed files

- `home/.hammerspoon/init.lua`
- `home/.hammerspoon/ai_hotkeys.lua`
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
- Keep chooser tools deterministic and local.

## Runtime behavior

- Uses tracked config in `~/.hammerspoon`.
- Reads catalog/data from `~/.config/ai-router/`.
- Keeps `tmp` logs local and does not persist secrets.

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
