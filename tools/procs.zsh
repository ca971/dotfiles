#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_PROCS_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_PROCS_LOADED=1
has "procs" || return 0
log_debug "Configuring procs"


log_debug "procs configured"
