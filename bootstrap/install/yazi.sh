#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"

ensure_parent_dir "$HOME/.config/yazi"
mkdir -p "$HOME/.local/state"

echo "Installing Yazi: "
echo "Installing Dependencies"
brew install yazi ffmpegthumbnailer unar jq mpv poppler fd ripgrep fzf zoxide font-symbols-only-nerd-font
brew install bat exiftool tree glow imagemagick pandoc sqlite smali miller transmission-cli woff2 rich

echo "Setting up Yazi"
backup_target "$HOME/.local/state/yazi" "$stamp"
deploy_repo_path "$repo_root" "home/.config/yazi" "$HOME/.config/yazi" "$stamp"

# Intentional external plugin installs that fetch Yazi extensions from upstream.
ya pack -a AnirudhG07/rich-preview
ya pack -a dedukun/relative-motions
ya pack -a dedukun/bookmarks
ya pack -a Reledia/glow
ya pack -a Sonico98/exifaudio
ya pack -a ndtoan96/ouch
ya pack -a lpnh/fg
ya pack -a Rolv-Apneseth/bypass
ya pack -a Reledia/hexyl
ya pack -a kirasok/epub-preview
ya pack -a yazi-rs/plugins:max-preview
ya pack -a yazi-rs/plugins:chmod
ya pack -a yazi-rs/plugins:smart-filter
ya pack -a yazi-rs/plugins:full-border

# Intentional external plugin checkout for a standalone preview extension.
git clone https://github.com/Urie96/preview.yazi.git "$HOME/.config/yazi/plugins/preview.yazi"

# echo "updating plugins"
# ya pack -u

echo "Finished installing Yazi"
