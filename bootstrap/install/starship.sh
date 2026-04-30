#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"
parse_install_args "$@"

echo "Installing Starship"
brew_install starship

echo "Setting up Starship"
if should_deploy; then
  deploy_repo_path "$repo_root" "home/.config/starship.toml" "$HOME/.config/starship.toml" "$stamp"
fi

echo "Finished installing Starship"
