#!/usr/bin/env bash
set -euo pipefail

left_monitor_name="24V5C2"
right_monitor_name="PHL 279C9"
left_workspaces=(1 2 3 4 5 6)
right_workspaces=(7 8 9 10 11 12)

monitor_lines="$(aerospace list-monitors --format '%{monitor-id}	%{monitor-name}')"

monitor_id_for_name() {
    local name="$1"
    awk -F '	' -v name="$name" '$2 == name { print $1; exit }' <<<"$monitor_lines"
}

workspaces_for_monitor() {
    local monitor_id="$1"
    aerospace list-workspaces --monitor "$monitor_id" --format '%{workspace}' | tr '\n' ' '
}

contains_workspace() {
    local haystack=" $1 "
    local needle="$2"
    [[ "$haystack" == *" $needle "* ]]
}

print_array() {
    local first=1
    local item
    for item in "$@"; do
        if [ "$first" -eq 1 ]; then
            printf '%s' "$item"
            first=0
        else
            printf ' %s' "$item"
        fi
    done
}

issues=0
left_monitor_id="$(monitor_id_for_name "$left_monitor_name")"
right_monitor_id="$(monitor_id_for_name "$right_monitor_name")"

printf 'Detected monitors:\n%s\n\n' "$monitor_lines"

if [ -z "$left_monitor_id" ]; then
    printf 'WARN: left monitor "%s" is not connected.\n' "$left_monitor_name"
    issues=$((issues + 1))
else
    left_actual="$(workspaces_for_monitor "$left_monitor_id")"
    printf 'Left monitor %s (%s): %s\n' "$left_monitor_name" "$left_monitor_id" "$left_actual"
    for workspace in "${left_workspaces[@]}"; do
        if ! contains_workspace "$left_actual" "$workspace"; then
            printf 'WARN: workspace %s is not on left monitor %s.\n' "$workspace" "$left_monitor_name"
            issues=$((issues + 1))
        fi
    done
fi

if [ -z "$right_monitor_id" ]; then
    printf 'WARN: right monitor "%s" is not connected.\n' "$right_monitor_name"
    issues=$((issues + 1))
else
    right_actual="$(workspaces_for_monitor "$right_monitor_id")"
    printf 'Right monitor %s (%s): %s\n' "$right_monitor_name" "$right_monitor_id" "$right_actual"
    for workspace in "${right_workspaces[@]}"; do
        if ! contains_workspace "$right_actual" "$workspace"; then
            printf 'WARN: workspace %s is not on right monitor %s.\n' "$workspace" "$right_monitor_name"
            issues=$((issues + 1))
        fi
    done
fi

printf '\nExpected: '
print_array "${left_workspaces[@]}"
printf ' on %s; ' "$left_monitor_name"
print_array "${right_workspaces[@]}"
printf ' on %s.\n' "$right_monitor_name"

if [ "$issues" -eq 0 ]; then
    printf 'OK: workspace layout matches the current monitor profile.\n'
else
    printf 'Found %s display layout issue(s).\n' "$issues"
    exit 1
fi
