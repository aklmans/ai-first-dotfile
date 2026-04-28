#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source_dir="$repo_root/home/.config/ai-router"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/ai-router-exports.XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT

cp -R "$source_dir" "$work_dir/ai-router"
chmod +x "$work_dir/ai-router/ai-router.sh"

AI_ROUTER_HOME="$work_dir/ai-router" "$work_dir/ai-router/ai-router.sh" export-snippets all >/dev/null

diff -u "$source_dir/exports/raycast-snippets.json" "$work_dir/ai-router/exports/raycast-snippets.json"
diff -u "$source_dir/exports/ai-router-snippets.json" "$work_dir/ai-router/exports/ai-router-snippets.json"
