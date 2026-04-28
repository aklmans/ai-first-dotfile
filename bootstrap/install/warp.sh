#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

brew install --cask warp
brew tap homebrew/cask-fonts
brew install --cask font-fantasque-sans-mono-nerd-font

backup_target "$HOME/.warp" "$stamp"
deploy_repo_path "$repo_root" "home/.config/warp" "$HOME/.config/warp" "$stamp"
