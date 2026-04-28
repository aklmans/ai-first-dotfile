# ai-first-dotfile

MacOS first-class dotfiles with a clean, public-friendly baseline history.

## Source and migration scope

This repository is a sanitized migration of dotfiles from a private source tree into a fresh public history.

- Source: `/Users/aklman/Workspace/Projects/workflow/wow-dotfile-v2`
- Target: `/Users/aklman/Workspace/Projects/workflow/ai-first-dotfile`

Migration goals:

- Start from a new Git history with no old commit graph.
- Keep module-by-module commits for auditability.
- Remove private/runtime artifacts, paths, and secrets before tracking.

## Repository Layout

- `home/`: tracked source-of-truth files that are deployed to the user home.
- `bootstrap/`: installer scripts, macOS defaults entrypoints, and Homebrew/App Store bootstrap logic.
- `manifests/`: package manifests.
- `tests/smoke/`: repository validation and safety checks.
- `docs/tools/`: per-tool documentation.

## Current modules

- Shell: `home/.zshenv`, `home/.config/zsh/*`, `home/.config/starship.toml`
- Workspace: `home/.aerospace.toml`, `home/.config/aerospace/`, `home/.hammerspoon/*`, `home/.config/karabiner/*`
- Desktop UI: `home/.config/sketchybar/`, `home/.config/borders/`
- Terminals / tools: `home/.config/kaku/*`, `home/.config/warp/*`, `home/.config/yazi/*`
- AI workflow: `home/.config/ai-router/*`
- Editor/media/app configs: `home/.ideavimrc`, `home/.config/mpv/*`

## Install and bootstrap

```bash
# baseline bootstrap
./bootstrap/brew.sh
./bootstrap/app-store.sh

# core config modules
./bootstrap/install/zsh.sh
./bootstrap/install/starship.sh
./bootstrap/install/kaku.sh
./bootstrap/install/yazi.sh

# workspace + desktop + AI workflow
./bootstrap/install/aerospace.sh
./bootstrap/install/hammerspoon.sh
./bootstrap/install/sketchybar.sh
./bootstrap/install/borders.sh
./bootstrap/install/bettertouchtool.sh
./bootstrap/install/ai-router.sh

# optional
./bootstrap/install/warp.sh
./bootstrap/install/mpv.sh
./bootstrap/install/karabiner.sh
```

All install scripts use deploy-backup semantics and do not append blindly into startup files.

## Runtime/Private directories not tracked

The repository intentionally ignores runtime and state directories.
See `.gitignore` for full patterns:

- `.env*`
- `*.bak`, `*.backup*`
- `**/cache/`, `**/logs/`, `**/state/`
- `home/.config/ai-router/catalogs/`
- `home/.config/ai-router/cache/`
- `home/.config/ai-router/state/`
- `home/.config/ai-router/logs/`
- `home/.config/skhd/`, `home/.config/yabai/`, `home/.config/wezterm/`, `home/.config/oh-my-posh/`

## Component responsibilities

- **AeroSpace**: window/workspace rules and tiling behavior.
- **Hammerspoon**: active-window helpers for window lifecycle and workspace binding, and AI chooser glue (`ai_hotkeys.lua`).
- **Karabiner**: keyboard remapping profile (`CapsLock AI Lite`), Hyper mode, and global launch shortcuts.
- **AI Router**: prompt/snippet catalog and provider render/run/export workflows.
- **Warp / Kaku / Starship / mpv / Yazi / IdeaVim**: terminal, media, and editor/tooling integration.

## Keyboard and workflow docs

- `docs/tools/current-workflow/README.md` contains active keymaps and operating notes.
- `home/.config/karabiner/CapsLock-AI-Lite.md` documents the key profile intent.
- `home/.config/ai-router/README.md` and `ROADMAP.md` document AI Router behavior and known gaps.

## Deprecated modules (not maintained here)

The following are not maintained in this repository and are only mentioned for migration history:

- skhd
- yabai
- wezterm
- oh-my-posh

If any legacy leftovers exist locally, they must be treated as optional legacy state and excluded from this repo.

## Additional notes

- Obsidian workspace/session, runtime bundles, and private vault contents are intentionally not migrated.
- Some old local-only assets (for example binary fonts and private media data) are intentionally excluded.
- If you migrate additional third-party assets, keep them behind explicit install steps and verify they are public-compatible.

## License

MIT — see [LICENSE](LICENSE).

