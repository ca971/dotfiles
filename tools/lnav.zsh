#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_LNAV_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_LNAV_LOADED=1
has "lnav" || return 0
log_debug "Configuring lnav"


function lnav-sys() { lnav /var/log/system.log 2>/dev/null || lnav /var/log/syslog 2>/dev/null; }

log_debug "lnav configured"
