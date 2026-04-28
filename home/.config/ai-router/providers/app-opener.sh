#!/usr/bin/env bash
set -euo pipefail

app_name="${1:-}"
if [ -z "$app_name" ]; then
  printf '%s\n' "Usage: app-opener.sh <App Name>" >&2
  exit 64
fi

/usr/bin/open -a "$app_name"

