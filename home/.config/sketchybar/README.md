## SketchyBar Configuration

This directory contains a public, reusable SketchyBar setup and plugin layout.

Fonts are provisioned by `bootstrap/install/sketchybar.sh`:

- `sf-symbols` (Homebrew Cask)
- `font-sf-mono` and `font-sf-pro` (Homebrew Cask)
- `sketchybar-app-font` downloaded from
  `https://github.com/kvndrsslr/sketchybar-app-font`.

Runtime files are intentionally not tracked:

- Album covers fetched by the Spotify plugin are cached in `/tmp` only.
- No runtime sockets, logs, session data, or cache/state directories are included here.

`icon_map.sh` is sourced by bar scripts at runtime; it has no secrets and is safe to share publicly.
