#!/usr/bin/env zsh
# ============================================================================
# @file        tools/yazi.zsh
# @description Yazi (file manager) — cd-on-exit + functions.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_YAZI_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_YAZI_LOADED=1

has "yazi" || return 0
log_debug "Configuring yazi"


function y() {
  local tmp; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  local cwd; cwd="$(cat -- "$tmp" 2>/dev/null)"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

function yy() { y "${1:-.}"; }
function yh() { y "$HOME"; }
function yc() { y "${XDG_CONFIG_HOME:-${HOME}/.config}"; }
function yg() { local r; r=$(git rev-parse --show-toplevel 2>/dev/null); y "${r:-.}"; }

log_debug "yazi configured"
