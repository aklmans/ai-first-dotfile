#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="${1:-$HOME/.aerospace.toml}"
RULES_FILE="$(mktemp)"
OUTPUT_FILE="$(mktemp)"

cleanup() {
    rm -f "$RULES_FILE" "$OUTPUT_FILE"
}
trap cleanup EXIT

"$SCRIPT_DIR/app-defaults.sh" --toml > "$RULES_FILE"

awk -v rules_file="$RULES_FILE" '
BEGIN {
    while ((getline line < rules_file) > 0) {
        rules = rules line ORS
    }
}
/^# Application placement and floating rules\./ {
    printf "%s\n", rules
    skip = 1
    next
}
/^\[mode\.main\.binding\]/ {
    skip = 0
}
!skip {
    print
}
' "$CONFIG_PATH" > "$OUTPUT_FILE"

python3 -c 'import pathlib, sys, tomllib; tomllib.loads(pathlib.Path(sys.argv[1]).read_text())' "$OUTPUT_FILE"

stamp="$(date +%Y%m%d-%H%M%S)"
cp "$CONFIG_PATH" "$CONFIG_PATH.bak-$stamp-render-app-rules"
cp "$OUTPUT_FILE" "$CONFIG_PATH"

if [ "$CONFIG_PATH" = "$HOME/.aerospace.toml" ]; then
    aerospace reload-config --dry-run --no-gui
fi
