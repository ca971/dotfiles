#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_DELTA_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_DELTA_LOADED=1
has "delta" || return 0
log_debug "Configuring delta"

[[ -f "${DOTFILES_DIR}/config/tools.d/delta.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/delta.zsh"

function gdelta() { git diff "$@" | delta --side-by-side; }
function ddiff()  { delta "$1" "$2"; }
function dshow()  { git show "${1:-HEAD}" | delta --side-by-side; }

log_debug "delta configured"
