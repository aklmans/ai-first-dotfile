# wow-dotfile

A comprehensive collection of macOS setup scripts and configuration files (dotfiles) designed to create a highly productive, aesthetically pleasing, and fully keyboard-driven development environment.

## Overview

This repository automates the configuration of a fresh macOS installation, providing tailored setups for system defaults, window management, terminal environments, and various essential tools. The configurations emphasize modern aesthetics with curated color schemes (Catppuccin Mocha, TokyoNight) and a fully keyboard-centric workflow that eliminates the need for a mouse in daily development tasks.

## Key Features

- **Fully Keyboard-Driven**: Every aspect of the workflow is optimized for keyboard navigation and control
- **Modern Aesthetics**: Consistent Catppuccin Mocha and TokyoNight themes across all tools
- **Tiling Window Management**: Automatic window tiling with AeroSpace for efficient screen real estate usage
- **Desktop Status Bar**: SketchyBar and Borders for workspace/status visibility and active-window focus
- **GPU-Accelerated Terminal**: Kaku and Warp configurations for fast, beautiful terminal experiences
- **CapsLock AI Workflow**: Karabiner, Hammerspoon, and AI Workflow Router for prompt rendering, agent launch, and snippet export
- **Rich Media Support**: MPV with Anime4K shaders for real-time video upscaling
- **Advanced File Management**: Yazi with extensive preview plugins for a modern terminal file manager

## Repository Structure

The normalized layout is source-driven and split by responsibility:

- `home/`: tracked files that are deployed into the user home directory
- `bootstrap/`: entrypoints for Homebrew, App Store, macOS defaults, and tool installers
- `manifests/`: machine and app manifests consumed by bootstrap scripts
- `apps/`: app-specific tracked assets and local workspace data
- `tests/smoke/`: repository verification scripts for structure, docs, and bootstrap behavior
- `docs/tools/`: tool-specific documentation for the moved configs

### Automated Installations

- `./bootstrap/brew.sh`: install the baseline CLI and toolchain profile
- `./bootstrap/app-store.sh`: restore tracked App Store apps through `mas`
- `./bootstrap/install/*.sh`: deploy tracked home configuration with timestamped backups
- `./bootstrap/macos/*.sh`: apply macOS defaults and system preferences

The normalized deploy model is:
- bootstrap scripts preflight required tracked sources, then deploy with timestamped backups instead of mutating files in place
- tracked config directories in this repository are the source of truth for distributed setup
- local-only assets such as private fonts, licensed files, and machine-specific secrets are not distributed from this repo
- shell startup behavior lives in the tracked `home/.zshenv` and `home/.config/zsh/` files rather than installer append operations
- Obsidian workspace/session files and plugin runtime bundles stay local; the repo keeps only stable vault settings and plugin metadata under `apps/obsidian/`

### Tool Configurations
- **Current Workflow**: End-to-end local workflow overview, app placement, reload commands, and hotkey reference in `docs/tools/current-workflow/README.md`

#### Window Management & Desktop Environment
- **AeroSpace**: Tiling window manager with tracked config in `home/.aerospace.toml` and helpers under `home/.config/aerospace/`
- **Hammerspoon**: Small automation layer for new-window workspace inheritance and fast post-close settling, tracked under `home/.hammerspoon/`
- **Borders**: JankyBorders configuration for dynamic active window borders in `home/.config/borders/`
- **SketchyBar**: Highly customizable macOS status bar replacement with tracked config in `home/.config/sketchybar/`
  - Custom scripts for battery, calendar, media controls (Spotify)
  - AeroSpace workspace indicators and system monitoring

#### Terminal Environment
- **Kaku**: AI-coding-focused terminal with tracked config under `home/.config/kaku/`
- **Warp**: Modern terminal with tracked config under `home/.config/warp/`
- **Yazi**: Blazing-fast terminal file manager with tracked config under `home/.config/yazi/`
- **Starship**: Fast cross-shell prompt configured in `home/.config/starship.toml`

#### Editor Integration
- **Neovim**: Modal editing configuration under `home/.config/nvim/`
- **IdeaVim**: JetBrains IDE configuration tracked in `home/.ideavimrc`
- **Obsidian**: Stable vault settings and tracked app data under `apps/obsidian/vault/`
  Local-only assets such as licensed or personal fonts, workspace state, and plugin runtime bundles should stay outside version control.

#### System Utilities & Media
- **mpv**: Feature-rich media player with tracked config under `home/.config/mpv/`
- **Karabiner**: Advanced keyboard customizations and complex key remappings under `home/.config/karabiner/`
- **AI Workflow Router**: CapsLock prompt, snippet, provider, and agent workflow under `home/.config/ai-router/`

## Prerequisites

- macOS (designed for latest versions)
- Homebrew installed (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`)
- Git configured with your credentials

## Quick Start

1. **Clone and navigate to the repository:**
   ```bash
   git clone <repository-url>
   cd wow-dotfile
   ```

2. **Apply macOS System Defaults:**
   ```bash
   ./bootstrap/macos/system.sh
   ./bootstrap/macos/dock.sh
   ./bootstrap/macos/finder.sh
   ./bootstrap/macos/trackpad.sh
   ```

3. **Install Baseline Tools:**
   ```bash
   ./bootstrap/brew.sh
   ./bootstrap/brew.sh desktop fonts
   ./bootstrap/brew.sh all
   ./bootstrap/app-store.sh
   ```
   `./bootstrap/brew.sh` now defaults to the baseline CLI/toolchain profile.
   The profile contents mirror the current machine's top-level Homebrew installs rather than every package ever tried historically.
   `./bootstrap/brew.sh` keeps its non-default Homebrew taps explicit: `farion1231/ccswitch`, `felixkratz/formulae`, `nikitabobko/tap`, `steipete/tap`, and `tw93/tap`.
   Use named profiles such as `desktop`, `infra`, `fonts`, `apps`, and `quicklook` for selective opt-in installs, or `all` to reproduce the old "install everything" behavior.
   `topgrade` is included in the baseline toolchain and is the preferred update entrypoint after bootstrap.
   Use `updates` to preview the full update run with `topgrade --dry-run`, and `upall` to execute the full `topgrade` workflow.
   The legacy `update` and `upgrade` aliases remain available for compatibility, but the `topgrade` flow is the default.
   `./bootstrap/app-store.sh` restores tracked App Store apps through `mas` using repo-managed manifests, with large apps prompted separately before install.

4. **Setup Desktop Status UI:**
   ```bash
   ./bootstrap/install/aerospace.sh
   ./bootstrap/install/bettertouchtool.sh
   ./bootstrap/install/ai-router.sh
   ./bootstrap/install/hammerspoon.sh
   ./bootstrap/install/sketchybar.sh
   ./bootstrap/install/borders.sh
   ```

5. **Configure Terminal Environment:**
   ```bash
   ./bootstrap/install/kaku.sh
   ./bootstrap/install/yazi.sh
   ./bootstrap/install/zsh.sh
   ./bootstrap/install/starship.sh
   ```
   The tracked `home/.zshenv` and `home/.config/zsh/` files define shell startup behavior; installers should deploy them rather than append startup lines into `~/.zshrc`.
   Kaku generates its shell integration under `~/.config/kaku/zsh` on first launch, and the tracked zsh startup sources it when present.

6. **Install Additional Tools as Needed:**
   ```bash
   ./bootstrap/install/mpv.sh
   ./bootstrap/install/karabiner.sh
   ```

7. **Install GBrain Agent Memory Workflow:**
   ```bash
   ./bootstrap/install/gbrain.sh
   ```
   This clones or reuses `~/Workspace/Projects/gbrain`, installs local Bun dependencies, creates `gbrain` / `gb` / `gg` wrappers in `~/.local/bin`, starts a Docker `gbrain-postgres` container, and writes `~/.gbrain/config.json` for the local Postgres backend.
   Real API keys are not tracked. Copy `templates/gbrain/.env.local.example` to `~/Workspace/Projects/gbrain/.env.local` and fill it locally.
   Codex MCP and the minimal plugin layout are documented in `templates/gbrain/codex-config.example.toml`; the installer only writes Codex config when explicitly run with `--configure-codex`. The zsh functions `cx`, `cxweb`, `cxppt`, `cxdesign`, `cxmac`, `cxdata`, `cxgui`, `cxgh`, and `cxg` start Codex with task-specific `-c` overrides. `cxg` injects the GBrain MCP server on demand so plain `cx` stays fast.

## Customization

### Themes & Colors
All major tools use consistent Catppuccin Mocha (default) or TokyoNight themes. To customize:
- Edit the respective tool's configuration file in its directory
- Color schemes are centrally defined and reused across configurations

### Keyboard Shortcuts
AeroSpace configuration (`home/.aerospace.toml`) defines window management shortcuts. Key patterns:
- `ctrl` + number keys switch workspaces `1` through `10`
- `ctrl` + `[` / `]` switch workspaces `11` and `12`
- `ctrl-shift` + number keys move the focused window to a workspace
- `ctrl-left` / `ctrl-right` cycle workspaces; `ctrl-up` / `ctrl-down` open Mission Control / App Exposé through BTT
- `CapsLock + C` opens the AI agent chooser; `CapsLock + Ctrl + C/L` directly launch Codex CLI / Claude Code
- `CapsLock + A/S/T/E/W/F/X/R/G/D/Y/=` render AI prompts to the clipboard
BetterTouchTool configuration is recreated by `home/.config/bettertouchtool/aerospace-gestures.sh`, which maps trackpad swipes to AeroSpace workspace cycling and Mission Control.
Karabiner configuration (`home/.config/karabiner/`) defines keyboard customization and global launch shortcuts.

## Keyboard Workflow

The setup emphasizes a complete keyboard-driven workflow:
- **Window Management**: AeroSpace for tiling, workspaces, displays, and app placement
- **Window Inheritance**: Hammerspoon keeps new windows/dialogs with the workspace that opened them
- **AI Workflow**: CapsLock AI Lite renders prompts, opens the agent chooser, and exports static snippets for Raycast
- **File Management**: Yazi provides full keyboard navigation with previews
- **Text Editing**: Consistent Vim keybindings across Neovim, JetBrains IDEs, and terminal
- **System Control**: Media playback, volume control, and system commands via hotkeys

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Catppuccin](https://github.com/catppuccin) for the beautiful color schemes
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) for the i3-like macOS tiling window manager
- [Hammerspoon](https://www.hammerspoon.org/) for lightweight macOS automation
- All the amazing open-source tools that make this setup possible
