#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_GLOW_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_GLOW_LOADED=1
has "glow" || return 0
log_debug "Configuring glow"


function readme() { local f; f=$(find . -maxdepth 1 -iname "readme*" | head -1); [[ -n "$f" ]] && glow "$f" || log_warn "No README found"; }

log_debug "glow configured"
