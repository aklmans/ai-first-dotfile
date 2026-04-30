# Karabiner CapsLock AI Lite

`home/.config/karabiner/karabiner.json` defines the `CapsLock AI Lite` profile used by this setup.
The profile exposes a minimal but practical `CapsLock`-based command layer.

![Karabiner CapsLock AI Lite profile](../../../assets/screenshots/karabiner-profile.png)

## Installed files

- `home/.config/karabiner/karabiner.json`
- `home/.config/karabiner/CapsLock-AI-Lite.md`
- `bootstrap/install/karabiner.sh`

## Install

```bash
./bootstrap/install/karabiner.sh
```

After install, open Karabiner-Elements and confirm profile:

- `CapsLock AI Lite` (selected)
- legacy or experimental `Default profile` is preserved as fallback

## What it provides

- `CapsLock` tap -> `Esc`
- `CapsLock` hold -> `Right Command + Right Option + Right Control + Right Shift` (Hyper-ish behavior)
- Prompt/agent launch combos for AI workflows
- Compact navigation and editing layer (safe defaults)
- Legacy/deprecated mouse layers are intentionally excluded

## Core hotkeys

### Prompt and action layer (AI helper chords)

- `CapsLock + A/S/T/E/W/F/X/R/G/D/Y/=`
  - prompt actions (render prompt templates, then copy/dispatch through AI Router flow)
- `CapsLock + C`
  - open AI agent chooser

### Direct launch / app shortcuts

- `CapsLock + Ctrl + <key>`
  - direct actions for Warp / coding tools / browser / Codex / Claude / etc.

See `home/.config/karabiner/CapsLock-AI-Lite.md` for the full mapping intent and fallback behavior.
For the complete public shortcut table, see [Shortcut Reference](../../shortcuts.md).

## Why this profile is safe

- Focuses on a small set of predictable chords.
- Keeps navigation/editing productive.
- Avoids large complex conditional layers from legacy private versions.

## Validation

```bash
python3 -m json.tool home/.config/karabiner/karabiner.json
```

Also verify selected profile and bindings in the Karabiner GUI after install.

## Notes

- We intentionally do not track large private complex-modifications bundles.
- `home/.config/karabiner/karabiner.json.backup-*` is only used locally and is excluded from version control.
