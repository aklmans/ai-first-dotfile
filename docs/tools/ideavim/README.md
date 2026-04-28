# IdeaVim

`home/.ideavimrc` contains the reusable Vim-mode settings for JetBrains IDEs.

## Purpose

- keep key behavior consistent with terminal `zsh` and terminal text workflows
- support quick editing mode in IDEs without tracking IDE runtime data

## Installation

This file is deployed as part of `home/.ideavimrc` by default in this repository layout.

No dedicated installer writes it; it is copied when using your normal home sync flow.

## Notes

- This layer is intentionally configuration-only.
- Do not copy private workspace files or shared project snapshots into `.ideavimrc`.
- If IDE runtime behavior differs, keep your local IDE-specific plugins in per-machine overrides and avoid committing full IDE settings.
