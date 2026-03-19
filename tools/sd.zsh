#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_SD_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_SD_LOADED=1
has "sd" || return 0
log_debug "Configuring sd"

[[ -f "${DOTFILES_DIR}/config/tools.d/sd.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/sd.zsh"

log_debug "sd configured"
