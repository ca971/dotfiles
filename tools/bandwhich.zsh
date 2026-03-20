#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_BANDWHICH_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_BANDWHICH_LOADED=1
has "bandwhich" || return 0
log_debug "Configuring bandwhich"


log_debug "bandwhich configured"
