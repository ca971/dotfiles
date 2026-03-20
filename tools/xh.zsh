#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_XH_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_XH_LOADED=1
has "xh" || return 0
log_debug "Configuring xh"


log_debug "xh configured"
