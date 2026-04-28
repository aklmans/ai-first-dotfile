#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

echo "Installing Kaku"
brew install tw93/tap/kakuku

echo "Setting up Kaku"
deploy_repo_path "$repo_root" "home/.config/kaku/kaku.lua" "$HOME/.config/kaku/kaku.lua" "$stamp"
deploy_repo_path "$repo_root" "home/.config/kaku/assistant.toml" "$HOME/.config/kaku/assistant.toml" "$stamp"

echo "Kaku generates shell integration under ~/.config/kaku/zsh on first launch."
echo "Finished installing Kaku"
