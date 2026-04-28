#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/_lib.sh"
setup_router_home

usage="$AI_ROUTER_HOME/state/usage.json"
favorites="$AI_ROUTER_HOME/state/favorites.json"

python3 "$AI_ROUTER_HOME/lib/router_tools.py" state-record "$usage" prompt summarize "Summarize Selection"
python3 "$AI_ROUTER_HOME/lib/router_tools.py" state-record "$usage" prompt summarize "Summarize Selection"
python3 "$AI_ROUTER_HOME/lib/router_tools.py" state-favorite "$favorites" add prompt summarize "Summarize Selection" >/dev/null
python3 "$AI_ROUTER_HOME/lib/router_tools.py" state-favorite "$favorites" list > "$test_root/favorites.txt"

assert_contains "$(cat "$test_root/favorites.txt")" $'prompt\tsummarize\tSummarize Selection' "favorite list"

python3 - "$usage" "$favorites" <<'PY'
import json
import sys

usage = json.load(open(sys.argv[1]))
favorites = json.load(open(sys.argv[2]))
assert usage["items"]["prompt:summarize"]["count"] == 2
assert favorites["items"][0]["kind"] == "prompt"
assert favorites["items"][0]["value"] == "summarize"
PY

printf 'ok - state usage and favorites\n'
