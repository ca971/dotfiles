#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_LNAV_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_LNAV_LOADED=1
has "lnav" || return 0
log_debug "Configuring lnav"

[[ -f "${DOTFILES_DIR}/config/tools.d/lnav.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/lnav.zsh"

function lnav-sys() { lnav /var/log/system.log 2>/dev/null || lnav /var/log/syslog 2>/dev/null; }

log_debug "lnav configured"
