#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

brew install --cask mpv

install_osc_font() {
  if ! command -v brew >/dev/null 2>&1; then
    printf 'brew not found; skip optional font install for mpv OSC graphics.\n'
    return 0
  fi

  brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
  if brew list --cask --versions font-material-design-icons-webfont >/dev/null 2>&1; then
    return 0
  fi

  # Optional, best-effort: install public font used by ModernX icon glyphs.
  brew install --cask font-material-design-icons-webfont || \
    brew install --cask font-material-icons || true
}

deploy_repo_path "$repo_root" "home/.config/mpv" "$HOME/.config/mpv" "$stamp"

install_osc_font
