#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"
parse_install_args "$@"

ensure_brew_tap nikitabobko/tap
brew_install_cask nikitabobko/tap/aerospace

if should_deploy; then
  deploy_repo_path "$repo_root" "home/.aerospace.toml" "$HOME/.aerospace.toml" "$stamp"
  deploy_repo_path "$repo_root" "home/.config/aerospace" "$HOME/.config/aerospace" "$stamp"

  # Enable macOS native Ctrl+Cmd window dragging. Some apps need restart to pick it up.
  defaults write -g NSWindowShouldDragOnGesture -bool true
fi

if should_install || should_deploy; then
  open -a AeroSpace

  if command -v aerospace >/dev/null 2>&1; then
    aerospace reload-config --dry-run --no-gui
    aerospace reload-config || true
  fi
fi
