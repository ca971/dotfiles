#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_GUM_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_GUM_LOADED=1
has "gum" || return 0
log_debug "Configuring gum"

[[ -f "${DOTFILES_DIR}/config/tools.d/gum.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/gum.zsh"

log_debug "gum configured"
