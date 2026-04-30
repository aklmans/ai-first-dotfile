#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
repo_root="$(repo_root_dir)"
stamp="$(date +%Y%m%d_%H%M%S)"
parse_install_args "$@"

SBARLUA_REPO="${SBARLUA_REPO:-https://github.com/FelixKratz/SbarLua.git}"
SBARLUA_REF="${SBARLUA_REF:-dba9cc421b868c918d5c23c408544a28aadf2f2f}"
SBARLUA_CACHE_DIR="${SBARLUA_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/Library/Caches}/dotfiles/SbarLua-$SBARLUA_REF}"
SBARLUA_INSTALL_DIR="${SBARLUA_INSTALL_DIR:-$HOME/.local/share/sketchybar_lua}"

ensure_parent_dir "$HOME/.config/sketchybar"
mkdir -p "$HOME/Library/Fonts"
mkdir -p "$HOME/Library/Caches/sketchybar"

echo "Installing Sketchybar"

# Install runtime dependencies and supporting packages.
ensure_brew_tap felixkratz/formulae
brew_install lua switchaudio-osx nowplaying-cli jq gh sketchybar

# Install font dependencies required by the bar.
brew_install_cask sf-symbols font-sf-mono font-sf-pro

install_sketchybar_app_font() {
  local target="$HOME/Library/Fonts/sketchybar-app-font.ttf"

  if [[ -f "$target" ]]; then
    printf 'SketchyBar app font already installed: %s\n' "$target"
    return 0
  fi

  # Intentional external asset fetch: this downloads the bar font from upstream.
  curl -L \
    https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.60/sketchybar-app-font.ttf \
    -o "$target"
}

install_sbarlua() {
  local ref_file="$SBARLUA_INSTALL_DIR/.sbarlua-ref"

  if [[ -f "$SBARLUA_INSTALL_DIR/sketchybar.so" && -f "$ref_file" ]] && grep -Fx "$SBARLUA_REF" "$ref_file" >/dev/null 2>&1; then
    printf 'SbarLua already installed at pinned ref: %s\n' "$SBARLUA_REF"
    return 0
  fi

  rm -rf "$SBARLUA_CACHE_DIR"
  git clone --filter=blob:none "$SBARLUA_REPO" "$SBARLUA_CACHE_DIR"
  git -C "$SBARLUA_CACHE_DIR" fetch --depth 1 origin "$SBARLUA_REF"
  git -C "$SBARLUA_CACHE_DIR" checkout --detach "$SBARLUA_REF"
  make -C "$SBARLUA_CACHE_DIR" install

  mkdir -p "$SBARLUA_INSTALL_DIR"
  printf '%s\n' "$SBARLUA_REF" >"$ref_file"
}

if should_install; then
  install_sketchybar_app_font
  install_sbarlua
fi

echo "Setting up Sketchybar"
if should_deploy; then
  deploy_repo_path "$repo_root" "home/.config/sketchybar" "$HOME/.config/sketchybar" "$stamp"
fi

echo "Starting Sketchybar"
if should_install || should_deploy; then
  brew services restart sketchybar
fi

cat <<'EOF'

SketchyBar AI notification notes:
- Runtime attention state is stored in ~/Library/Caches/sketchybar, not in ~/.config/sketchybar.
- To let SketchyBar read macOS notification metadata, grant Full Disk Access to SketchyBar:
  System Settings -> Privacy & Security -> Full Disk Access -> add /opt/homebrew/bin/sketchybar
- macOS TCC permissions cannot be granted silently by this script.
EOF

echo "Finished setting up"
