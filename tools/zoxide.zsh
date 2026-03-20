#!/usr/bin/env zsh
# ============================================================================
# @file        tools/zoxide.zsh
# @description Zoxide (smart cd) — init + functions.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_ZOXIDE_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_ZOXIDE_LOADED=1

has "zoxide" || return 0
log_debug "Configuring zoxide"


export _ZO_FZF_OPTS="${FZF_DEFAULT_OPTS:-} \
  --preview='eza --icons --tree --level=1 --color=always {2..} 2>/dev/null || ls -la {2..}' \
  --preview-window='right:40%' --height=60% --no-sort"

eval "$(zoxide init zsh --cmd cd)"

function zz()     { cdi "$@"; }
function ztop()   { local n="${1:-20}"; zoxide query --list --score | head -"$n" | awk '{printf "  %8.1f  %s\n", $1, $2}'; }
function zclean() { local b=$(zoxide query --list | wc -l | tr -d ' '); zoxide query --list | while read -r d; do [[ -d "$d" ]] || zoxide remove "$d" 2>/dev/null; done; local a=$(zoxide query --list | wc -l | tr -d ' '); log_info "Cleanup: %s → %s entries" "$b" "$a"; }
function zmark()  { zoxide add "$PWD"; log_info "Marked: %s" "$PWD"; }

log_debug "zoxide configured"
