# Troubleshooting

This page covers common issues when first running the setup.

## Before you start

Run the smoke tests first and capture output:

```bash
bash tests/smoke/install_script_syntax_smoke.sh
bash tests/smoke/repository_structure_smoke.sh
bash tests/smoke/privacy_scan_smoke.sh
```

Then proceed by module.

## General issues

### Command not found: brew / lua / python3 / yazi

- Install prerequisites:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
./bootstrap/brew.sh base desktop fonts
```

- Re-run the module script.

### Permission denied running an installer

- Confirm script mode is executable:

```bash
chmod +x bootstrap/install/*.sh tests/smoke/*.sh
```

- Re-run the target command.

### macOS prompt denies permissions

Enable permissions in **System Settings → Privacy & Security**:

- Accessibility
- Input Monitoring
- Automation
- Screen Recording (only if you use capture/thumbnail features)

Restart the changed apps after granting permissions.

## Module-level troubleshooting

### AeroSpace

- If workspace keys do not apply, restart:

```bash
brew services restart nikitabobko/tap/aerospace || true
open -a AeroSpace
```

- Verify shell helper scripts:

```bash
bash -n home/.config/aerospace/*.sh
HOME="$PWD/home" bash home/.config/aerospace/check-display-layout.sh
```

### SketchyBar / Borders

- If SketchyBar fails to start:

```bash
brew services restart sketchybar
```

- Verify runtime scripts are executable and config is present:

```bash
zsh -n home/.config/sketchybar/sketchybarrc
```

- Re-run:

```bash
./bootstrap/install/sketchybar.sh
```

### Karabiner

- Open Karabiner after installation and ensure profile is `CapsLock AI Lite`.
- If JSON formatting breaks the app:

```bash
python3 -m json.tool home/.config/karabiner/karabiner.json
```

- Restart Karabiner-Elements and reselect profile if needed.

### Hammerspoon

- If no hotkeys trigger, confirm Hammerspoon is running:

```bash
open -a Hammerspoon
```

- Test syntax:

```bash
lua -e "assert(loadfile('home/.hammerspoon/init.lua'))"
lua -e "assert(loadfile('home/.hammerspoon/ai_hotkeys.lua'))"
```

### AI Router

- If exports drift:

```bash
HOME="$PWD/home" bash home/.config/ai-router/tests/run.sh
bash tests/smoke/ai_router_exports_smoke.sh
```

- Rebuild catalogs and snippets:

```bash
~/.config/ai-router/ai-router.sh index
~/.config/ai-router/ai-router.sh export-snippets all
```

### Terminal (Kaku / Warp / Yazi)

- If `yazi` plugin install fails, verify network and rerun:

```bash
./bootstrap/install/yazi.sh
```

- Rebuild key mappings by restarting Yazi.

### mpv

- ModernX references `material-design-iconic-font` style glyphs.
  If icons are missing, run mpv install script again for best-effort font install:

```bash
./bootstrap/install/mpv.sh
```

- You can also install a public Nerd/Material font manually and reopen mpv.

## If still broken

1. Re-run the three smoke checks listed above.
2. Re-run the module installer for the failing component.
3. Check for local `.local`, `private.zsh`, `.env*`, or private overlays that may override defaults.
4. Confirm no paths like `/Users/USERNAME/...` from your private setup are accidentally added to tracked docs.

If a reproducibility gap remains, document it in `docs/troubleshooting.md` with exact command output.
