#!/usr/bin/env bash
set -euo pipefail

repo_root_dir() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  printf '%s\n' "$script_dir"
}

DOTFILES_INSTALL=1
DOTFILES_DEPLOY=1
DOTFILES_BREW=1

install_flag_usage() {
  cat <<'EOF'
Common install flags:
  --install-only   Install packages/external dependencies only; do not deploy config.
  --deploy-only    Deploy config only; skip Homebrew/package installation.
  --no-brew        Skip Homebrew commands but still run non-brew setup steps.
  --no-deploy      Skip config deployment.
  -h, --help       Show this help.
EOF
}

parse_install_args() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --install-only)
        DOTFILES_INSTALL=1
        DOTFILES_DEPLOY=0
        ;;
      --deploy-only)
        DOTFILES_INSTALL=0
        DOTFILES_DEPLOY=1
        DOTFILES_BREW=0
        ;;
      --no-brew)
        DOTFILES_BREW=0
        ;;
      --no-deploy)
        DOTFILES_DEPLOY=0
        ;;
      -h|--help)
        install_flag_usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n\n' "$1" >&2
        install_flag_usage >&2
        exit 1
        ;;
    esac
    shift
  done
}

should_install() {
  [[ "$DOTFILES_INSTALL" -eq 1 ]]
}

should_deploy() {
  [[ "$DOTFILES_DEPLOY" -eq 1 ]]
}

should_brew() {
  [[ "$DOTFILES_BREW" -eq 1 ]]
}

ensure_brew_tap() {
  local tap="$1"
  should_brew || return 0
  if ! brew tap | grep -Fx "$tap" >/dev/null 2>&1; then
    brew tap "$tap"
  fi
}

brew_install() {
  should_brew || return 0
  brew install "$@"
}

brew_install_cask() {
  should_brew || return 0
  brew install --cask "$@"
}

require_repo_path() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    printf 'Missing required path: %s\n' "$path" >&2
    exit 1
  fi
}

ensure_parent_dir() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
}

backup_target() {
  local target="$1"
  local stamp="$2"
  local backup_path suffix

  [[ -e "$target" || -L "$target" ]] || return 0

  backup_path="${target}.backup_${stamp}"
  suffix=1
  while [[ -e "$backup_path" || -L "$backup_path" ]]; do
    backup_path="${target}.backup_${stamp}_${suffix}"
    suffix=$((suffix + 1))
  done

  mv "$target" "$backup_path"
  printf 'Backed up %s -> %s\n' "$target" "$backup_path"
}

paths_match() {
  local source_path="$1"
  local target="$2"

  [[ -e "$target" || -L "$target" ]] || return 1

  if [[ -d "$source_path" && -d "$target" && ! -L "$target" ]]; then
    diff -qr "$source_path" "$target" >/dev/null 2>&1
    return $?
  fi

  if [[ -f "$source_path" && -f "$target" && ! -L "$target" ]]; then
    cmp -s "$source_path" "$target"
    return $?
  fi

  return 1
}

deploy_repo_path() {
  local repo_root="$1"
  local source_rel="$2"
  local target="$3"
  local stamp="$4"
  local source_path="$repo_root/$source_rel"

  require_repo_path "$source_path"
  ensure_parent_dir "$target"

  if paths_match "$source_path" "$target"; then
    printf 'Unchanged: %s\n' "$target"
    return 0
  fi

  backup_target "$target" "$stamp"

  if [[ -d "$source_path" ]]; then
    cp -R "$source_path" "$target"
  else
    cp "$source_path" "$target"
  fi

  printf 'Deployed: %s -> %s\n' "$source_rel" "$target"
}
