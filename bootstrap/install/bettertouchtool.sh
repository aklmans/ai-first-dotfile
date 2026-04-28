#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

brew install --cask bettertouchtool

deploy_repo_path "$repo_root" "home/.config/bettertouchtool" "$HOME/.config/bettertouchtool" "$stamp"

"$HOME/.config/bettertouchtool/aerospace-gestures.sh"
