function zen() {
     ~/.config/sketchybar/plugins/zen.sh $1
}

function kill() {
	if [[ $# -eq 1 && $1 != -* && $1 != %* && $1 != <-> && -n "$1" ]]; then
		if command -v pkill >/dev/null 2>&1; then
			command pkill -x "$1"
			return
		fi
	fi

	builtin kill "$@"
}

function yy() {
	if [ -n "$YAZI_LEVEL" ]; then
		exit
	fi

	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Codex task profiles. Functions keep non-interactive compatibility; aliases below
# shadow them in interactive shells so Warp can identify Codex sessions.
cx() {
	codex "$@"
}

cxgh() {
	codex -c 'plugins."github@openai-curated".enabled=true' "$@"
}


cxg() {
	local gbrain_bin="${GBRAIN_BIN:-$HOME/.local/bin/gbrain}"
	local gbrain_command_config="mcp_servers.gbrain.command=$gbrain_bin"
	codex \
		-c "$gbrain_command_config" \
		-c 'mcp_servers.gbrain.args=["serve"]' \
		-c 'mcp_servers.gbrain.enabled_tools=["search","get","query"]' \
		"$@"
}

cxweb() {
	codex \
		-c 'plugins."build-web-apps@openai-curated".enabled=true' \
		-c 'plugins."browser-use@openai-bundled".enabled=true' \
		"$@"
}

cxdesign() {
	codex -c 'plugins."figma@openai-curated".enabled=true' "$@"
}

cxppt() {
	codex -c 'plugins."presentations@openai-primary-runtime".enabled=true' "$@"
}

cxdata() {
	codex -c 'plugins."spreadsheets@openai-primary-runtime".enabled=true' "$@"
}

cxmac() {
	codex \
		-c 'plugins."build-macos-apps@openai-curated".enabled=true' \
		-c 'plugins."build-ios-apps@openai-curated".enabled=true' \
		"$@"
}

cxgui() {
	codex -c 'plugins."computer-use@openai-bundled".enabled=true' "$@"
}

alias cx='codex'
alias cxgh='codex -c '\''plugins."github@openai-curated".enabled=true'\'''
alias cxg='codex -c "mcp_servers.gbrain.command=${GBRAIN_BIN:-$HOME/.local/bin/gbrain}" -c '\''mcp_servers.gbrain.args=["serve"]'\'' -c '\''mcp_servers.gbrain.enabled_tools=["search","get","query"]'\'''
alias cxweb='codex -c '\''plugins."build-web-apps@openai-curated".enabled=true'\'' -c '\''plugins."browser-use@openai-bundled".enabled=true'\'''
alias cxdesign='codex -c '\''plugins."figma@openai-curated".enabled=true'\'''
alias cxppt='codex -c '\''plugins."presentations@openai-primary-runtime".enabled=true'\'''
alias cxdata='codex -c '\''plugins."spreadsheets@openai-primary-runtime".enabled=true'\'''
alias cxmac='codex -c '\''plugins."build-macos-apps@openai-curated".enabled=true'\'' -c '\''plugins."build-ios-apps@openai-curated".enabled=true'\'''
alias cxgui='codex -c '\''plugins."computer-use@openai-bundled".enabled=true'\'''
