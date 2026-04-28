# AI-first-dotfile

AI-first-dotfile is a public, reproducible macOS dotfile setup for AI-assisted workflows.
It is a sanitized migration from a private setup into a clean Git history.

## Purpose

This repo gives you one place to manage:

- AI workspace behavior (`AeroSpace`, `Karabiner`, `Hammerspoon`)
- Desktop UI (`SketchyBar`, `Borders`)
- Terminal and file tools (`Kaku`, `Warp`, `Yazi`, `zsh`, `Starship`)
- AI execution pipeline (`AI Workflow Router`, `Prompts`, `Snippets`, `Providers`)
- Media/editor helpers (`mpv`, `IdeaVim`, and selected app configs)

## How this repo is organized

- `home/`: source of truth for files deployed to your home directory.
- `bootstrap/`: installers and bootstrap scripts.
- `manifests/`: package lists for optional App Store tooling.
- `tests/smoke/`: repo-wide validation and privacy checks.
- `docs/`: public documentation.
- `LICENSE`, `MIGRATION_PLAN.md`, `MIGRATION_REPORT.md`.

## Installation order

Use this order on a fresh machine:

1. **Core bootstrap**
   ```bash
cd /path/to/ai-first-dotfile
   ./bootstrap/brew.sh base desktop fonts
   ./bootstrap/app-store.sh
   ```
2. **Shell + terminal**
   ```bash
   ./bootstrap/install/zsh.sh
   ./bootstrap/install/starship.sh
   ./bootstrap/install/kaku.sh
   ./bootstrap/install/yazi.sh
   ./bootstrap/install/warp.sh       # optional
   ```
3. **Desktop/workspace**
   ```bash
   ./bootstrap/install/karabiner.sh
   ./bootstrap/install/aerospace.sh
   ./bootstrap/install/sketchybar.sh
   ./bootstrap/install/borders.sh
   ./bootstrap/install/bettertouchtool.sh  # optional
   ./bootstrap/install/hammerspoon.sh
   ```
4. **AI workflow and media**
   ```bash
   ./bootstrap/install/ai-router.sh
   ./bootstrap/install/mpv.sh              # optional
   ```
5. **Validate**
   ```bash
   bash tests/smoke/repository_structure_smoke.sh
   bash tests/smoke/install_script_syntax_smoke.sh
   ```

> You can install optional modules later and rerun relevant smoke tests.

## Mac permissions required

At runtime, the following macOS permissions are commonly required:

- **Accessibility**: `Karabiner`, `Hammerspoon`, `BetterTouchTool`
- **Input Monitoring**: `Hammerspoon` selection/clipboard workflows
- **Automation**: `Hammerspoon` app-launch and command dispatch
- **Screen Recording**: only if you use screenshot/ocr capture actions in your local customization

## Core workflow keys

- **AeroSpace**
  - `Ctrl + 1..0`: switch workspace 1–10 (`[` = 11, `]` = 12)
  - `Ctrl + Shift + 1..0`: move focused window to target workspace
  - `Ctrl + Left/Right`: cycle workspaces
  - `Ctrl + Up/Down`: Mission Control / App Expose
- **AI hotkeys (via `Hammerspoon` + `Karabiner`)**
  - `CapsLock + A/S/T/E/W/F/X/R/G/D/Y/=`
  - `CapsLock + C` (Coding Agent chooser)
  - `CapsLock + Ctrl + W/I/G/X/H/C/L` (direct launch/action)
  - `CapsLock + Space` (AI palette / chooser)
- **BetterTouchTool gestures**
  - 3/4-finger left/right = next/previous workspace
  - 3/4-finger up = Mission Control
  - 3/4-finger down = App Expose

## Key modules and docs

- [getting started](docs/getting-started.md)
- [privacy policy](docs/privacy.md)
- [troubleshooting](docs/troubleshooting.md)
- [screenshots plan](docs/screenshots.md)
- [Aerospace](docs/tools/aerospace/README.md)
- [SketchyBar + Borders](docs/tools/sketchybar/README.md)
- [Karabiner](docs/tools/karabiner/README.md)
- [Hammerspoon](docs/tools/hammerspoon/README.md)
- [AI Workflow Router](docs/tools/ai-router/README.md)
- [Terminal](docs/tools/terminal/README.md)
- [Zsh + Starship](docs/tools/zsh-starship/README.md)
- [BetterTouchTool](docs/tools/bettertouchtool/README.md)
- [mpv](docs/tools/mpv/README.md)
- [Yazi](docs/tools/yazi/README.md)
- [migration plan](MIGRATION_PLAN.md)
- [migration report](MIGRATION_REPORT.md)

## Notes for public use

- This repository intentionally does **not** contain private runtime/history artifacts.
- Runtime folders and secrets are excluded via `.gitignore` and migration policy.
- `gbrain` and AI provider credentials are template-based placeholders only:
  - `templates/gbrain/.env.local.example`
  - `templates/gbrain/codex-config.example.toml`
- Old legacy modules are intentionally dropped: `skhd`, `yabai`, `wezterm`, `oh-my-posh`.

## License

MIT — see [LICENSE](LICENSE).
