#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_CURLIE_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_CURLIE_LOADED=1
has "curlie" || return 0
log_debug "Configuring curlie"

[[ -f "${DOTFILES_DIR}/config/tools.d/curlie.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/curlie.zsh"

log_debug "curlie configured"
