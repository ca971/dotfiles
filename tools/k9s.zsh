#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_K9S_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_K9S_LOADED=1
has "k9s" || return 0
log_debug "Configuring k9s"


log_debug "k9s configured"
