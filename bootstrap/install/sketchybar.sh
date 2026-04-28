#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

ensure_parent_dir "$HOME/.config/sketchybar"
mkdir -p "$HOME/Library/Fonts"

echo "Installing Sketchybar"

# Install runtime dependencies and supporting packages.
brew install lua
brew install switchaudio-osx
brew install nowplaying-cli
brew install jq
brew install gh
brew tap FelixKratz/formulae
brew install sketchybar

# Install font dependencies required by the bar.
brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro

# Intentional external asset fetch: this downloads the bar font from upstream.
curl -L \
  https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.60/sketchybar-app-font.ttf \
  -o "$HOME/Library/Fonts/sketchybar-app-font.ttf"

# Intentional external source checkout and build step for the SbarLua runtime dependency.
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

echo "Setting up Sketchybar"
deploy_repo_path "$repo_root" "home/.config/sketchybar" "$HOME/.config/sketchybar" "$stamp"

echo "Starting Sketchybar"
brew services restart sketchybar

echo "Finished setting up"
