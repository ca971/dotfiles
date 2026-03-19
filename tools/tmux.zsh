#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_TMUX_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_TMUX_LOADED=1
has "tmux" || return 0
log_debug "Configuring tmux"

[[ -f "${DOTFILES_DIR}/config/tools.d/tmux.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/tmux.zsh"

function tmux-fzf() { local s; s=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --header='Select session'); [[ -n "$s" ]] && tmux attach -t "$s"; }

log_debug "tmux configured"
