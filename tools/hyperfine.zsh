#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_HYPERFINE_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_HYPERFINE_LOADED=1
has "hyperfine" || return 0
log_debug "Configuring hyperfine"


log_debug "hyperfine configured"
