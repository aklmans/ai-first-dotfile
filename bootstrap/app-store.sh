#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/lib/common.sh"
repo_root="$(repo_root_dir)"
default_manifest="$repo_root/manifests/app-store/mas-default.txt"
large_manifest="$repo_root/manifests/app-store/mas-large.txt"

require_mas() {
  if ! command -v mas >/dev/null 2>&1; then
    printf 'mas is required for App Store installs. Install it first (for example: brew install mas), then sign into the App Store and rerun this script.\n' >&2
    exit 1
  fi
}

require_manifest() {
  local manifest_path="$1"

  if [[ ! -f "$manifest_path" || ! -r "$manifest_path" ]]; then
    printf 'manifest is missing or unreadable: %s\n' "$manifest_path" >&2
    exit 1
  fi
}

install_manifest() {
  local manifest_path="$1"

  require_manifest "$manifest_path"

  while IFS=$'\t' read -r bundle_id app_name || [[ -n "${bundle_id:-}" || -n "${app_name:-}" ]]; do
    [[ -z "$bundle_id" || "$bundle_id" == \#* ]] && continue
    mas install --bundle "$bundle_id"
  done <"$manifest_path"
}

prompt_install_large_apps() {
  local reply=""

  printf 'Install large apps now? [y/N] '
  if ! read -r reply; then
    reply=""
  fi

  case "$reply" in
    [Yy]*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

main() {
  require_mas

  printf 'Make sure you are signed into the App Store before running this script.\n'
  install_manifest "$default_manifest"

  if prompt_install_large_apps; then
      install_manifest "$large_manifest"
  else
      printf 'Skipping large App Store apps.\n'
  fi
}

main "$@"
