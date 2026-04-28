# Keyboard launcher for Codex interactive sessions.
[[ -o interactive ]] || return 0

: "${CODEX_CTRLX_COMMAND:=codex}"

__codex_ctrlx_launch_session() {
  emulate -L zsh

  if ! command -v "$CODEX_CTRLX_COMMAND" >/dev/null 2>&1; then
    zle -M "codex-widget: command not found: $CODEX_CTRLX_COMMAND"
    return 1
  fi

  local prompt="$BUFFER"
  local cwd="$PWD"
  local command="${(q)CODEX_CTRLX_COMMAND} --cd ${(q)cwd}"

  if [[ -n "${prompt//[[:space:]]/}" ]]; then
    command+=" ${(q)prompt}"
  fi

  BUFFER="$command"
  CURSOR=${#BUFFER}
  zle accept-line
}

zle -N __codex_ctrlx_launch_session
bindkey -M emacs '^X' __codex_ctrlx_launch_session
bindkey -M viins '^X' __codex_ctrlx_launch_session
bindkey -M emacs '^]' __codex_ctrlx_launch_session
bindkey -M viins '^]' __codex_ctrlx_launch_session
