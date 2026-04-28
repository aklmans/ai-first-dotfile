#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

echo "Installing AI Workflow Router"

deploy_repo_path "$repo_root" "home/.config/ai-router" "$HOME/.config/ai-router" "$stamp"

chmod +x "$HOME/.config/ai-router/ai-router.sh"
find "$HOME/.config/ai-router/providers" "$HOME/.config/ai-router/tests" -type f -name '*.sh' -exec chmod +x {} \;

"$HOME/.config/ai-router/ai-router.sh" index
"$HOME/.config/ai-router/ai-router.sh" export-snippets all

echo "Finished installing AI Workflow Router"
