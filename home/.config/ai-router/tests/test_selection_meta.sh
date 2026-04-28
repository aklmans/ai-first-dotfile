#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/_lib.sh"
setup_router_home

cat > "$AI_ROUTER_HOME/prompts/summarize.md" <<'PROMPT'
---
id: summarize
title: Summarize Selection
default_provider: kimi
output: clipboard
---

Input:
{{selection}}
PROMPT

output="$(AI_ROUTER_SELECTION='meta selection' "$router" render summarize)"

assert_contains "$output" "meta selection" "rendered selection"
assert_file "$AI_ROUTER_HOME/cache/selection-meta.env"
assert_file "$AI_ROUTER_HOME/logs/events.jsonl"

assert_contains "$(cat "$AI_ROUTER_HOME/cache/selection-meta.env")" "source=env" "selection source"

python3 - "$AI_ROUTER_HOME/logs/events.jsonl" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as file:
    event = json.loads(file.readlines()[-1])

assert event["input_source"] == "selection", event
assert event["selection_source"] == "env", event
assert event["selection_ms"] == 0, event
assert event["selection_attempts"] == 0, event
PY

printf 'ok - selection metadata\n'
