#!/usr/bin/env bash
set -euo pipefail

# Disable quarantine for downloaded apps
defaults write com.apple.LaunchServices LSQuarantine -bool false
