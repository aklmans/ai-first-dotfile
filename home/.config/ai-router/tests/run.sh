#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

for test_script in test_*.sh; do
  bash "$test_script"
done
