#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_STARSHIP_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_STARSHIP_LOADED=1

local _starship_bin=""
if has "starship"; then _starship_bin="starship"
elif [[ -x "${HOMEBREW_PREFIX:-/opt/homebrew}/bin/starship" ]]; then _starship_bin="${HOMEBREW_PREFIX:-/opt/homebrew}/bin/starship"
elif [[ -x "${HOME}/.local/bin/starship" ]]; then _starship_bin="${HOME}/.local/bin/starship"
elif [[ -x "${CARGO_HOME:-${HOME}/.cargo}/bin/starship" ]]; then _starship_bin="${CARGO_HOME:-${HOME}/.cargo}/bin/starship"
fi
[[ -z "$_starship_bin" ]] && return 0
log_debug "Configuring starship"


export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${DOTFILES_DIR}/themes/starship-powerline.toml}"

eval "$("$_starship_bin" init zsh)"

case "${ZSH_TERMINAL:-}" in
  ghostty|wezterm|kitty|iterm|alacritty|xterm*|tmux)
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd  _set_terminal_title_precmd
    add-zsh-hook preexec _set_terminal_title_preexec ;;
esac
function _set_terminal_title_precmd()  { printf '\033]0;%s\007' "${PWD/#$HOME/~}"; }
function _set_terminal_title_preexec() { local t="$1"; (( ${#t} > 50 )) && t="${t:0:47}..."; printf '\033]0;%s\007' "$t"; }

function starship-explain()  { "$_starship_bin" explain; }
function starship-timings()  { "$_starship_bin" timings; }
function starship-edit()     { "${EDITOR:-nvim}" "$STARSHIP_CONFIG"; }

unset _starship_bin
log_debug "starship configured"
