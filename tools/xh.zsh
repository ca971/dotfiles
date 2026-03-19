#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_XH_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_XH_LOADED=1
has "xh" || return 0
log_debug "Configuring xh"

[[ -f "${DOTFILES_DIR}/config/tools.d/xh.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/xh.zsh"

log_debug "xh configured"
