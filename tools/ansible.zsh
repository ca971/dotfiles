#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_ANSIBLE_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_ANSIBLE_LOADED=1
has "ansible" || return 0
log_debug "Configuring ansible"
log_debug "ansible configured"
