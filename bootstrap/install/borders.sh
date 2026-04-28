#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

target_path="$HOME/.config/borders"

brew install borders
deploy_repo_path "$repo_root" "home/.config/borders" "$target_path" "$stamp"

# Start Borders after the tracked config is in place.
brew services start borders
