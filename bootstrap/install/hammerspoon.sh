#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"
parse_install_args "$@"

brew_install_cask hammerspoon

if should_deploy; then
  deploy_repo_path "$repo_root" "home/.hammerspoon" "$HOME/.hammerspoon" "$stamp"
fi

if should_install || should_deploy; then
  open -a Hammerspoon
fi

cat <<'EOF'

Hammerspoon automation notes:
- Allow Accessibility and Automation permissions when macOS prompts.
- Hammerspoon clears SketchyBar AI attention state by writing clear requests; it does not need Full Disk Access for notification databases.
- If Hammerspoon is already running, reload its config from the menu bar icon.
EOF
