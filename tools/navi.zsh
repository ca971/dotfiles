#!/usr/bin/env zsh
# ============================================================================
# @file        tools/navi.zsh
# @description Navi (interactive cheatsheets).
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_NAVI_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_NAVI_LOADED=1

has "navi" || return 0
log_debug "Configuring navi"


eval "$(navi widget zsh 2>/dev/null)"

function cheat-browse() { navi --tag-rules=all; }
function cheat-add()    { local repo="${1:-}"; [[ -z "$repo" ]] && navi repo browse || navi repo add "$repo"; }
function cheat-edit()   { local dir="${XDG_CONFIG_HOME:-${HOME}/.config}/navi/cheats"; mkdir -p "$dir"; "${EDITOR:-nvim}" "$dir"; }

log_debug "navi configured"
