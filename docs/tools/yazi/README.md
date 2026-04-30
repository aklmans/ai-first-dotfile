# Yazi File Manager

`yazi` is the terminal file manager in this stack.
Its configuration is fully tracked and reproducible; runtime state is local.

## Installed files

- `home/.config/yazi/yazi.toml`
- `home/.config/yazi/keymap.toml`
- `home/.config/yazi/init.lua`
- `home/.config/yazi/package.toml`
- `bootstrap/install/yazi.sh`

## Install

```bash
./bootstrap/install/yazi.sh
```

The installer supports current Yazi package management (`ya pkg add`) and falls back to legacy `ya pack -a` for older Yazi builds.

## What is configured

- Vim-like key bindings in `keymap.toml`.
- Preview and opener policies in `yazi.toml`.
- Runtime plugins are initialized from `init.lua`.
- External plugin packs are bootstrapped during install.

## Runtime folders (not tracked)

- `~/.local/state/yazi/`
- `~/.cache/yazi/`

These are user runtime and not part of version control.

## Useful checks

```bash
zsh -n home/.config/yazi/init.lua
```

```bash
HOME="$PWD/home" yazi
```

## Quick usage

- Open with `yazi` from terminal.
- Use `?` for help and `<Esc>` to close help overlays.
- Plugins in this config include previews, bookmarks, smart navigation, and format-aware file handling.
