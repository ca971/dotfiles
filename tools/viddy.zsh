#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_VIDDY_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_VIDDY_LOADED=1
has "viddy" || return 0
log_debug "Configuring viddy"

[[ -f "${DOTFILES_DIR}/config/tools.d/viddy.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/viddy.zsh"

log_debug "viddy configured"
