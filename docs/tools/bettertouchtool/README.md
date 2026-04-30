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

The installer copies the tracked gesture preset script but does not start BetterTouchTool by default.
This keeps the base setup stable on multi-display systems where BTT can occasionally hold stale mouse/drag state after display changes.

To start BetterTouchTool and apply the gesture preset explicitly:

```bash
./bootstrap/install/bettertouchtool.sh --deploy-only --start
```

To stop BetterTouchTool during troubleshooting:

```bash
osascript -e 'tell application "BetterTouchTool" to quit'
```

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

If mouse selection or dragging stops working, quit BetterTouchTool first.
The tracked Hammerspoon config does not listen to mouse down/drag/up events, so BTT is the higher-risk event layer for that symptom.
