# Screenshots

This repository currently focuses on configuration and scripts. Public screenshots are optional and can be added over time.

## Purpose

Screenshots help new users verify:

- workspace layout behavior
- desktop status bar and borders
- prompt and chooser UX
- AI Router exports/import flows

## Recommended screenshot set

Use public demo windows and avoid any real names, project paths, logs, tickets, or emails.

1. `desktop-overview.png`  
   Full desktop with workspace bar and app layout.
2. `sketchybar-workspace-bar.png`  
   Top bar showing workspace indicator and window title modules.
3. `aerospace-tiling-layout.png`  
   Multi-window AeroSpace tiling with workspace labels `1-12`.
4. `capslock-chooser.png`  
   AI Router prompt/agent chooser window (`CapsLock + C` / agent flow).
5. `agent-chooser.png`  
   Long-running agent command selection.
6. `starship-prompt.png`  
   Shell prompt with path, git, and AI helper indicators.
7. `kaku-warp-terminal.png`  
   Kaku + Warp terminal split flow.
8. `raycast-import.png`  
   Raycast snippet import UI after exporting `ai-router` snippets.

## Current status

- No screenshot files are included yet.
- Add them when you have a sanitized environment and consented assets.
- Keep file names under `assets/screenshots/` and reference this list from PR checks.

## Screenshot sanitization rules

When you create screenshots for this repository:

- Remove real chats, URLs, project names, ticket IDs, and client/company identifiers.
- Do not capture notifications with personally identifying accounts or messages.
- Do not include secrets, API keys, token values, cookies, `.bash_history`, shell history, or browser login hints.
- Use demo project names such as `demo-workspace`, `sample-repo`, and placeholder text.
- Avoid capturing machine hostnames if they reveal an internal domain.

If a file currently contains sensitive content:

- regenerate with demo content
- crop and blur all sensitive regions
- or replace with a `TODO:` placeholder entry instead of uploading.

## Asset placement

- `assets/screenshots/README.md`
- `assets/screenshots/` (future image files)
