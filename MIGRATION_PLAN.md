# Migration Plan: wow-dotfile-v2 -> ai-first-dotfile

## Source and target
- Source (old): `$HOME/Workspace/Projects/workflow/wow-dotfile-v2`
- Target (new): `$HOME/Workspace/Projects/workflow/ai-first-dotfile`

## Why create a new history
- Do not import old `.git` objects or commit graph.
- The goal is a clean, audit-friendly baseline in the public repo that demonstrates explicit module-by-module migration decisions.
- Sensitive and runtime artifacts in the old history are excluded regardless of whether they were ever tracked on older commits.

## Migration scope and module order
1. Base repository layout and documentation scaffolding.
2. Bootstrap and manifests + macOS installer entrypoints.
3. Shell environment.
4. Terminal and CLI tools (Kaku / Warp / Yazi).
5. AeroSpace workspace management.
6. SketchyBar and Borders desktop UI.
7. BetterTouchTool gestures.
8. Hammerspoon automation.
9. Karabiner profile.
10. AI Router core runtime scripts and config.
11. AI Router prompts, snippets, exports, and smoke tests.
12. Editor / media / app configs.
13. High-level docs rewrite.
14. Repository smoke and privacy checks.

## Privacy exclusion rules
- Do not copy: `.git/**`, `.env*`, secrets, tokens, API keys, passwords, cookies, sessions, private keys.
- Do not copy: caches/logs/state/runtime/backups/temporary files (`.cache`, `.logs`, `.state`, `catalogs/`, `cache/`, `logs/`, `state/`, `*.bak`, `*backup*`, `*.backup-*`).
- Exclude machine-bound absolute paths and replace with portable equivalents (`$HOME`, `~`, `~/.config/...`) where feasible.
- Obsidian: do not migrate workspace/session/runtime bundles.
- No private font binaries or other machine-owned license assets unless explicitly public.

## Per-module checks
- Base: `bash -n bootstrap/lib/common.sh`; check `.gitignore` includes privacy/caching/runtime exclusions.
- Bootstrap: `bash -n` for all new `bootstrap/*.sh`; confirm no append operations (`>>`/`tee -a`) in install scripts.
- Shell: `zsh -n` for all shell files, `rg` scan for hard-coded absolute path and sensitive tokens.
- Terminal tools: Lua syntax check for Kaku/Yazi scripts where applicable.
- AeroSpace: `bash -n` on helper scripts + `home/.config/aerospace/app-defaults.sh --toml` + `aerospace reload-config --dry-run --no-gui` if command exists.
- SketchyBar/Borders: `bash -n` all shell/plugin files.
- BTT/Hammerspoon: `bash -n` install scripts and `lua -e "assert(loadfile(...))"` on Lua files.
- Karabiner: `python3 -m json.tool home/.config/karabiner/karabiner.json`; selected profile exists; required parameters exist.
- AI Router: `bash -n home/.config/ai-router/ai-router.sh`; python syntax compile for `home/.config/ai-router/lib/router_tools.py`; exports should avoid private `source_path`.
- AI prompts/snippets: run AI Router smoke exports after copy.
- Editors/media: json/toml/yaml/markdown sanity checks by file type; extra manual scan for sensitive text.
- Final: full smoke suite and global privacy scan.

## Files to defer / review (manual confirmation)
- `docs/superpowers/*` and old planning artifacts: keep references only if still useful.
- `apps/obsidian/vault/.obsidian/plugins/*` runtime artifacts: migrate only stable metadata/settings.
- Any absolute-path items in scripts that can only be made portable by introducing wrappers or docs.

## Notes before implementation
- Stage-by-stage commits only; avoid a single giant initial import commit.
- Verify each module for sensitive issues before committing and record decisions in `MIGRATION_REPORT.md`.
