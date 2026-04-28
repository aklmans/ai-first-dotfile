#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

echo "Installing Starship"
brew install starship

echo "Setting up Starship"
deploy_repo_path "$repo_root" "home/.config/starship.toml" "$HOME/.config/starship.toml" "$stamp"

echo "Finished installing Starship"
