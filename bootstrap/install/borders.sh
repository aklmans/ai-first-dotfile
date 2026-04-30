#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"
parse_install_args "$@"

target_path="$HOME/.config/borders"

ensure_brew_tap felixkratz/formulae
brew_install borders

if should_deploy; then
  deploy_repo_path "$repo_root" "home/.config/borders" "$target_path" "$stamp"
fi

# Start Borders after the tracked config is in place.
if should_install || should_deploy; then
  brew services start borders
fi
