# Current Workflow Overview

Last updated: 2026-04-28

## Source of truth

All tracked runtime inputs live in:

- `home/.aerospace.toml` and `home/.config/aerospace/` (window manager)
- `home/.hammerspoon/` (runtime automation glue)
- `home/.config/karabiner/` (keyboard profile)
- `home/.config/ai-router/` (prompts, snippets, providers, exports)
- `home/.config/zsh/`, `home/.zshenv` (shell startup + key helpers)
- `home/.config/sketchybar/`, `home/.config/borders/`
- `home/.config/kaku/`, `home/.config/warp/`, `home/.config/yazi/`
- `home/.ideavimrc`, `home/.config/mpv/` (editor/media/app configs)

`bootstrap/install/*.sh` is the controlled deployment entrypoint for each module.

## Recommended mental model

The stack is split by responsibility:

- **AeroSpace + Karabiner** define workspace structure, app placement, and modifier semantics.
- **Hammerspoon** handles lightweight runtime glue (window inheritance, AI hotkey helper integration, and optional palette/agent launch glue).
- **AI Router** turns selected text into deterministic prompts and exports static snippets.
- **Terminal layer** remains in Kaku/Starship/Warp with a common deployment path.
- **Desktop layer** is provided by SketchyBar + Borders.

## Legacy modules not maintained here

- skhd
- yabai
- wezterm
- oh-my-posh

Their behavior should not be assumed active; only migration-history references are kept in docs where needed.

## AeroSpace essentials

- `Ctrl + 1...0` switch workspace 1-10
- `Ctrl + [` / `Ctrl + ]` switch workspace 11/12
- `Ctrl + Shift + 1...0` move focused window to workspace 1-10
- `Ctrl + Shift + [` / `Ctrl + Shift + ]` move focused window to workspace 11/12
- `Alt + H/J/K/L` move focus in tiled layouts
- `Ctrl + Alt + R` reload AeroSpace config
- `Ctrl + Alt + S` reload AeroSpace config without extra resets

## AI Router / Hammerspoon / Karabiner relations

- Karabiner `CapsLock` profile is the keyboard entrypoint for prompt and agent actions.
- Hammerspoon consumes these shortcuts and launches/copies commands for selected providers.
- AI Router executes prompt rendering and export functions, and owns the static snippet catalogs.
- Typical flow: select text → prompt render → paste or run via agent chooser.

## Quick checks

```bash
zsh -n home/.zshenv home/.config/zsh/*.zsh
bash -n home/.config/ai-router/ai-router.sh
python3 -m json.tool home/.config/karabiner/karabiner.json
bash tests/smoke/repository_structure_smoke.sh
```

For full repo checks, see `tests/smoke/*.sh` and run all scripts from the repo root.
