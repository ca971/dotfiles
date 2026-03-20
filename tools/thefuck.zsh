#!/usr/bin/env zsh
# ============================================================================
# @file        tools/thefuck.zsh
# @description TheFuck (command correction) — lazy-loaded.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_THEFUCK_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_THEFUCK_LOADED=1

has "thefuck" || return 0
log_debug "Configuring thefuck (lazy)"


# Lazy init — thefuck eval is slow (~300ms)
function fuck() {
  unfunction fuck 2>/dev/null
  eval "$(thefuck --alias)"
  fuck "$@"
}

log_debug "thefuck configured"
