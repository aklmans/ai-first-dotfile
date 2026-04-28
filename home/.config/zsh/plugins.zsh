# Completion directories: autoload on demand instead of sourcing large scripts up front.
typeset -gU fpath
fpath=(
  "$ZDOTDIR/completions"
  "$HOME/.bun"
  "$HOME/.docker/completions"
  /opt/homebrew/share/zsh/site-functions
  $fpath
)

typeset -g bun_completion="${BUN_INSTALL:-$HOME/.bun}/_bun"

autoload -Uz compinit
_zcompdump="$ZDOTDIR/.zcompdump"
if [[ ! -s "$_zcompdump" || "$ZDOTDIR/completions/_openclaw" -nt "$_zcompdump" || ( -s "$bun_completion" && "$bun_completion" -nt "$_zcompdump" ) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

if [[ -z "${KAKU_ZSH_DIR:-}" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

[[ -f "$ZDOTDIR/codex-widget.zsh" ]] && source "$ZDOTDIR/codex-widget.zsh"
