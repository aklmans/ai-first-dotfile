# Privacy and Public Safety

This repository is designed to be public-safe.
Only public configuration and minimal bootstrap helpers are tracked.

## Public safety policy

This project does **not** import private Git history.
Only current, reviewed, public-safe files are tracked.

That means:

- Existing repository history is not exposed here.
- Contributors should rotate secrets that may still exist in the old project history.
- Runtime and private local files are intentionally excluded.

## Runtime / state exclusions

The following directories are excluded by design and are not tracked:

- `home/.config/ai-router/cache/`
- `home/.config/ai-router/logs/`
- `home/.config/ai-router/state/`
- `home/.config/ai-router/catalogs/`
- `**/cache/`, `**/logs/`, `**/state/`

## What to keep local

- API keys, tokens, passwords, or cookies.
- `*.env` and other secret-bearing credentials.
- `~/.local/bin/`, private SSH keys, personal tokens, OAuth files.
- Runtime artifacts such as:
  - IDE workspace/session files
  - Browser caches
  - Home app cache and private service state

Use private overrides:

- `home/.config/zsh/private.zsh` (private local shell vars, if needed)
- `templates/gbrain/.env.local.example` and `templates/gbrain/codex-config.example.toml` as templates only

`templates/gbrain/.env.local.example` and `templates/gbrain/codex-config.example.toml` are placeholders.
Copy and fill them to your private local location; never commit filled versions.

## Excluded legacy and deprecated modules

The following are excluded from this repository by design:

- `home/.config/skhd`
- `home/.config/yabai`
- `home/.config/wezterm`
- `home/.config/oh-my-posh`
- `bootstrap/install/warp-launch-agent.sh`
- `home/.config/aerospace/warp-launch-agent.sh`

## Screenshot safety

Any image or command output shared in docs or examples must be sanitized.
Do not include real account names, real paths, real chats, production URLs, or tokens.

## Recommended checks before sharing

- Run privacy smoke checks:
  - `bash tests/smoke/privacy_scan_smoke.sh`
  - `bash tests/smoke/repository_structure_smoke.sh`
- Keep a clean commit history and avoid adding private files by accident.
- Review diffs for unexpected machine-specific paths before publishing.
