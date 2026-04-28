#!/usr/bin/env bash
set -euo pipefail

repo_root_dir() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  printf '%s\n' "$script_dir"
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
  [[ -e "$target" || -L "$target" ]] || return 0
  mv "$target" "${target}.backup_${stamp}"
}

deploy_repo_path() {
  local repo_root="$1"
  local source_rel="$2"
  local target="$3"
  local stamp="$4"
  local source_path="$repo_root/$source_rel"

  require_repo_path "$source_path"
  ensure_parent_dir "$target"
  backup_target "$target" "$stamp"

  if [[ -d "$source_path" ]]; then
    cp -R "$source_path" "$target"
  else
    cp "$source_path" "$target"
  fi
}
