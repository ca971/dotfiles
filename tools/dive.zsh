#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_DIVE_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_DIVE_LOADED=1
has "dive" || return 0
log_debug "Configuring dive"


function dive-fzf() {
  local img; img=$(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | fzf --header='Select image')
  [[ -n "$img" ]] && dive "$img"
}

log_debug "dive configured"
