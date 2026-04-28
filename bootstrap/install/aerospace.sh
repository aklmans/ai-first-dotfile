#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

brew tap nikitabobko/tap
brew install --cask nikitabobko/tap/aerospace

deploy_repo_path "$repo_root" "home/.aerospace.toml" "$HOME/.aerospace.toml" "$stamp"
deploy_repo_path "$repo_root" "home/.config/aerospace" "$HOME/.config/aerospace" "$stamp"

# Enable macOS native Ctrl+Cmd window dragging. Some apps need restart to pick it up.
defaults write -g NSWindowShouldDragOnGesture -bool true

open -a AeroSpace

if command -v aerospace >/dev/null 2>&1; then
  aerospace reload-config --dry-run --no-gui
  aerospace reload-config || true
fi
