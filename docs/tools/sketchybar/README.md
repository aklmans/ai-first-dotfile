# SketchyBar and Borders

`SketchyBar` plus `Borders` is the lightweight desktop UI layer for the AI-first workflow.

## Installed files

- `home/.config/sketchybar/`
- `home/.config/borders/`
- `bootstrap/install/sketchybar.sh`
- `bootstrap/install/borders.sh`

## What is included

- Left/center/right bar sections configured by `home/.config/sketchybar/sketchybarrc`.
- Visual themes and runtime helper scripts in `home/.config/sketchybar/` and `home/.config/borders/bordersrc`.
- AeroSpace workspace integration via plugin callbacks.
- Optional font fetch for the bar icon font and symbols.

## Install and refresh

```bash
./bootstrap/install/sketchybar.sh
./bootstrap/install/borders.sh
brew services restart sketchybar
brew services restart borders
```

## Core behavior

- No user session state is tracked in this repo.
- SketchyBar plugin cache/sockets are runtime-only and recreated per machine.
- Border style is reproducible from `bordersrc` and can be adjusted safely.

## Screenshot target

See `docs/screenshots.md` for the recommended `SketchyBar workspace bar` shot.

## Privacy notes

- `home/.config/sketchybar` does not include private account/session data.
- Runtime art assets and media cover fetches are not committed.
- `BORDER` and bar configuration only references local paths and public binaries.
