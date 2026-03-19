#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_OUCH_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_OUCH_LOADED=1
has "ouch" || return 0
log_debug "Configuring ouch"

[[ -f "${DOTFILES_DIR}/config/tools.d/ouch.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/ouch.zsh"

log_debug "ouch configured"
