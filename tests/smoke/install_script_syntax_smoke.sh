#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

check_script() {
  local script="$1"
  bash -n "$script"

  local header
  header="$(head -n 1 "$script")"
  if [[ "$header" != '#!/usr/bin/env bash' ]]; then
    printf 'Missing bash shebang: %s\n' "$script" >&2
    exit 1
  fi
}

for script_root in "$repo_root/bootstrap" "$repo_root/tests/smoke"; do
  while IFS= read -r script; do
    check_script "$script"
  done < <(find "$script_root" -type f -name '*.sh' | sort)
done

