#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

! rg -n '(>>|tee\s+-a).*(\.zshenv|\.zprofile|\.zshrc)|printf .*>>.*(\.zshenv|\.zprofile|\.zshrc)' \
  "$repo_root/bootstrap"

