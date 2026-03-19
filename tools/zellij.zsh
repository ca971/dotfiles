#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_ZELLIJ_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_ZELLIJ_LOADED=1
has "zellij" || return 0
log_debug "Configuring zellij"

[[ -f "${DOTFILES_DIR}/config/tools.d/zellij.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/zellij.zsh"

log_debug "zellij configured"
