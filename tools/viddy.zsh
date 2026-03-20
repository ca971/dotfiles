#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_VIDDY_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_VIDDY_LOADED=1
has "viddy" || return 0
log_debug "Configuring viddy"


log_debug "viddy configured"
