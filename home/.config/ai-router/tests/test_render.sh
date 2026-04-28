#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/_lib.sh"
setup_router_home

cat > "$AI_ROUTER_HOME/prompts/summarize.md" <<'PROMPT'
---
id: summarize
title: Summarize Selection
description: Test summarize prompt
category: reading
hotkey: s
priority: 10
default_provider: kimi
fallback_provider: gemini
input: selection
output: clipboard
allow_replace: false
aliases:
  - 总结
tags:
  - summary
---

请总结：

{{selection}}
PROMPT

output="$(AI_ROUTER_SELECTION='你好 world' "$router" render summarize)"

assert_contains "$output" "请总结：" "rendered prompt"
assert_contains "$output" "你好 world" "rendered selection"
assert_file "$AI_ROUTER_HOME/cache/last-output.md"
assert_file "$AI_ROUTER_HOME/state/usage.json"

printf 'ok - render prompt\n'
