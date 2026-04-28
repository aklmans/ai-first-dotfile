# Zsh + Starship

This repository uses `zsh` as the primary shell environment, with `Starship` for prompt rendering.

## Installed files

- `home/.zshenv`
- `home/.config/zsh/.zshrc`
- `home/.config/zsh/.zprofile`
- `home/.config/zsh/env.zsh`
- `home/.config/zsh/plugins.zsh`
- `home/.config/zsh/aliases.zsh`
- `home/.config/zsh/functions.zsh`
- `home/.config/zsh/personal.zsh`
- `home/.config/zsh/codex-widget.zsh`
- `home/.config/starship.toml`
- `bootstrap/install/zsh.sh`
- `bootstrap/install/starship.sh`

## Install

```bash
./bootstrap/install/zsh.sh
./bootstrap/install/starship.sh
```

## Shell layout

`home/.zshenv` sets:

- `XDG_CONFIG_HOME`
- `XDG_DATA_HOME`
- `XDG_CACHE_HOME`
- `ZDOTDIR=$HOME/.config/zsh`

`home/.config/zsh/.zshrc` sources:

- `env.zsh`
- Kaku integration (`~/.config/kaku/zsh/kaku.zsh`) when available
- plugin/completion/aliases/functions

## Starship

`home/.config/starship.toml` defines prompt sections, path/git/dir modules, and style.
If starship is absent, shell init falls back gracefully.

![Starship prompt](../../../assets/screenshots/starship-prompt.png)

## Local overrides

- `home/.config/zsh/private.zsh` is optional and intentionally not tracked.
- You can export machine-specific paths and tool settings there.

## Quick checks

```bash
zsh -n home/.config/zsh/*.zsh
zsh -n home/.zshenv
```

## Common workflow keys in shell layer

- `Ctrl + 1..0` etc are workspace keys handled by AeroSpace and Karabiner.
- `CapsLock` actions are handled by Karabiner + Hammerspoon, not by `zsh`.
