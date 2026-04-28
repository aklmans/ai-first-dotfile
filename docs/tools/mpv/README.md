# mpv Player

`mpv` is a media playback helper with reproducible config and plugin scripts.

## Installed files

- `home/.config/mpv/mpv.conf`
- `home/.config/mpv/input.conf`
- `home/.config/mpv/scripts/` (including `modernx.lua`)
- `bootstrap/install/mpv.sh`

## Install

```bash
./bootstrap/install/mpv.sh
```

`bootstrap/install/mpv.sh` installs mpv and performs best-effort public-font setup.

## Font and rendering note

`modernx.lua` uses Material-style icons for OSC widgets:

- icon names are in runtime text style strings;
- the corresponding font is a public dependency and not committed in the repo.

For reproducible screenshots and demo setups:

- run installer (best-effort) to install a public font package, or
- install a compatible Material icon font manually.

## What is tracked

- Config and scripts are tracked.
- Downloaded runtime media assets, cache, and personal playback history are not tracked.

## Related config

- `home/.config/mpv/scripts/modernx.lua`
- `home/.config/mpv/input.conf`
- `home/.config/mpv/mpv.conf`

## Notes

`Material Design Iconic Font` is used as a UI style reference.
It is installed at setup time only when available from public sources.
