#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"
parse_install_args "$@"

ensure_parent_dir "$HOME/.config/yazi"
mkdir -p "$HOME/.local/state"

echo "Installing Yazi: "
echo "Installing Dependencies"
brew_install yazi ffmpegthumbnailer unar jq mpv poppler fd ripgrep fzf zoxide font-symbols-only-nerd-font
brew_install bat exiftool tree glow imagemagick pandoc sqlite smali miller transmission-cli woff2 rich

echo "Setting up Yazi"
if should_deploy; then
  deploy_repo_path "$repo_root" "home/.config/yazi" "$HOME/.config/yazi" "$stamp"
fi

add_yazi_package() {
  local package="$1"

  if ya pkg --help >/dev/null 2>&1; then
    ya pkg add "$package"
    return 0
  fi

  if ya pack --help >/dev/null 2>&1; then
    ya pack -a "$package"
    return 0
  fi

  printf 'No supported Yazi package command found. Expected `ya pkg` or legacy `ya pack`.\n' >&2
  return 1
}

install_preview_plugin() {
  local target="$HOME/.config/yazi/plugins/preview.yazi"

  mkdir -p "$(dirname "$target")"

  if [[ -d "$target/.git" ]]; then
    git -C "$target" pull --ff-only
    return 0
  fi

  if [[ -e "$target" ]]; then
    printf 'Yazi preview plugin path exists but is not a git checkout: %s\n' "$target" >&2
    return 1
  fi

  git clone https://github.com/Urie96/preview.yazi.git "$target"
}

if should_install; then
  # Intentional external plugin installs that fetch Yazi extensions from upstream.
  add_yazi_package AnirudhG07/rich-preview
  add_yazi_package dedukun/relative-motions
  add_yazi_package dedukun/bookmarks
  add_yazi_package Reledia/glow
  add_yazi_package Sonico98/exifaudio
  add_yazi_package ndtoan96/ouch
  add_yazi_package lpnh/fg
  add_yazi_package Rolv-Apneseth/bypass
  add_yazi_package Reledia/hexyl
  add_yazi_package kirasok/epub-preview
  add_yazi_package yazi-rs/plugins:max-preview
  add_yazi_package yazi-rs/plugins:chmod
  add_yazi_package yazi-rs/plugins:smart-filter
  add_yazi_package yazi-rs/plugins:full-border

  # Intentional external plugin checkout for a standalone preview extension.
  install_preview_plugin

  ya pkg install >/dev/null 2>&1 || true
fi

echo "Finished installing Yazi"
