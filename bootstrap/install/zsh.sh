#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

deploy_repo_path "$repo_root" "home/.zshenv" "$HOME/.zshenv" "$stamp"
deploy_repo_path "$repo_root" "home/.config/zsh/.zprofile" "$HOME/.config/zsh/.zprofile" "$stamp"
deploy_repo_path "$repo_root" "home/.config/zsh/.zshrc" "$HOME/.config/zsh/.zshrc" "$stamp"
deploy_repo_path "$repo_root" "home/.config/zsh/env.zsh" "$HOME/.config/zsh/env.zsh" "$stamp"
deploy_repo_path "$repo_root" "home/.config/zsh/plugins.zsh" "$HOME/.config/zsh/plugins.zsh" "$stamp"
deploy_repo_path "$repo_root" "home/.config/zsh/codex-widget.zsh" "$HOME/.config/zsh/codex-widget.zsh" "$stamp"
deploy_repo_path "$repo_root" "home/.config/zsh/aliases.zsh" "$HOME/.config/zsh/aliases.zsh" "$stamp"
deploy_repo_path "$repo_root" "home/.config/zsh/functions.zsh" "$HOME/.config/zsh/functions.zsh" "$stamp"
deploy_repo_path "$repo_root" "home/.config/zsh/personal.zsh" "$HOME/.config/zsh/personal.zsh" "$stamp"
deploy_repo_path "$repo_root" "home/.config/zsh/completions/_openclaw" "$HOME/.config/zsh/completions/_openclaw" "$stamp"
