# BetterTouchTool Gestures

`BetterTouchTool` is optional in this setup.
It is used for trackpad/trackpoint gestures that complement AeroSpace workspace movement.

![BetterTouchTool workspace gestures](../../../assets/screenshots/bettertouchtool-gestures.png)

## Installed files

- `home/.config/bettertouchtool/aerospace-gestures.sh`
- `home/.config/bettertouchtool/README.md`
- `bootstrap/install/bettertouchtool.sh`

## Install

```bash
./bootstrap/install/bettertouchtool.sh
```

The installer copies the tracked gesture preset script and starts BetterTouchTool.

## Gesture behavior

- 3/4-finger left and right gestures move to previous/next AeroSpace workspace groups.
- 3/4-finger up opens Mission Control.
- 3/4-finger down opens App Expose.
- The tracked configuration intentionally does not include private device IDs or account tokens.

Full shortcut map: [Shortcut Reference](../../shortcuts.md).

## What is not tracked

- BetterTouchTool full application DB or cloud state is intentionally excluded.
- You only keep portable script/gesture presets in this repository.

## Permissions

Grant Accessibility permissions for global gesture handlers.

If gestures do not trigger:

1. Restart BetterTouchTool.
2. Check macOS permissions.
3. Reload the preset script and reapply.
