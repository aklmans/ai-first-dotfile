#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/_lib.sh"
setup_router_home

cat > "$AI_ROUTER_HOME/config.json" <<'JSON'
{
  "version": 2,
  "agents": {
    "codex": {
      "label": "Codex CLI",
      "command": "codex --disable apps",
      "behavior": "paste_in_new_warp_tab",
      "priority": 501,
      "aliases": ["codex"]
    }
  }
}
JSON

cat > "$AI_ROUTER_HOME/prompts/translate-to-en.md" <<'PROMPT'
---
id: translate-to-en
title: Translate to English
description: 中文翻译成英文
category: writing
hotkey: "y"
priority: 10
default_provider: gemini
fallback_provider: kimi
aliases:
  - 中译英
keywords:
  - technical-english
  - 英文表达
tags:
  - translation
---

{{selection}}
PROMPT

cat > "$AI_ROUTER_HOME/snippets/meeting-notes.md" <<'SNIPPET'
# Meeting Notes

Agenda and actions.
SNIPPET

"$router" index

for file in prompts hotkeys palette agents snippets tools; do
  assert_file "$AI_ROUTER_HOME/catalogs/$file.json"
done

python3 - "$AI_ROUTER_HOME" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
hotkeys = json.loads((root / "catalogs/hotkeys.json").read_text())
palette = json.loads((root / "catalogs/palette.json").read_text())
assert any(item["key"] == "y" and item["prompt"] == "translate-to-en" for item in hotkeys)
assert any("technical-english" in item.get("keywords", []) for item in json.loads((root / "catalogs/prompts.json").read_text()))
assert any("中译英" in item.get("searchText", "") for item in palette)
assert any("technical-english" in item.get("searchText", "") for item in palette)
assert any(item["kind"] == "agent" and item["value"] == "codex" for item in palette)
PY

mv "$AI_ROUTER_HOME/prompts" "$AI_ROUTER_HOME/prompts.off"
palette_output="$("$router" palette)"
assert_contains "$palette_output" "prompt:translate-to-en" "cached palette prompt"
assert_contains "$palette_output" "agent:codex" "cached palette agent"

printf 'ok - index catalogs\n'
