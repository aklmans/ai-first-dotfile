#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
router_home="$(cd "$test_dir/.." && pwd)"

router="${AI_ROUTER_TEST_ROUTER:-$router_home/ai-router.sh}"
tools="${AI_ROUTER_TEST_TOOLS:-$router_home/lib/router_tools.py}"

test_root="$(mktemp -d "${TMPDIR:-/tmp}/ai-router-test.XXXXXX")"
trap 'rm -rf "$test_root"' EXIT

fail() {
  printf 'not ok - %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="${3:-expected text}"
  [[ "$haystack" == *"$needle"* ]] || fail "$label: missing '$needle'"
}

assert_file() {
  local path="$1"
  [ -f "$path" ] || fail "missing file: $path"
}

setup_router_home() {
  export AI_ROUTER_HOME="$test_root/config"
  mkdir -p "$AI_ROUTER_HOME"/{lib,prompts,snippets,providers,catalogs,cache,state,logs/errors}
  cp "$tools" "$AI_ROUTER_HOME/lib/router_tools.py"
}
