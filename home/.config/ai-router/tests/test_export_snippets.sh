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
aliases:
  - 总结
keywords:
  - key-points
tags:
  - summary
---

Summarize:
{{selection}}
{{date}}
PROMPT

cat > "$AI_ROUTER_HOME/snippets/meeting-notes.md" <<'SNIPPET'
---
id: meeting-notes
title: Meeting Notes
description: Meeting note template
category: writing
aliases:
  - 会议纪要
keywords:
  - action-items
tags:
  - snippet
---

# Meeting Notes

{{selection}}
SNIPPET

"$router" export-snippets all >/dev/null

assert_file "$AI_ROUTER_HOME/exports/raycast-snippets.json"
assert_file "$AI_ROUTER_HOME/exports/ai-router-snippets.json"

python3 - "$AI_ROUTER_HOME" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
raycast = json.loads((root / "exports/raycast-snippets.json").read_text(encoding="utf-8"))
generic = json.loads((root / "exports/ai-router-snippets.json").read_text(encoding="utf-8"))

assert any(item["name"] == "AI Prompt / Summarize Selection" for item in raycast), raycast
prompt = next(item for item in raycast if item["name"] == "AI Prompt / Summarize Selection")
assert prompt["keyword"] == ";sm", prompt
assert "{clipboard}" in prompt["text"], prompt
assert "{date}" in prompt["text"], prompt

assert generic["version"] == 1, generic
assert any(item["id"] == "meeting-notes" and item["keyword"] == ";mt" for item in generic["items"]), generic
PY

printf 'ok - export snippets\n'
