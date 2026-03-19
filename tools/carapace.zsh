#!/usr/bin/env zsh
# ============================================================================
# @file        tools/carapace.zsh
# @description Carapace (multi-shell completions).
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_CARAPACE_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_CARAPACE_LOADED=1

has "carapace" || return 0
log_debug "Configuring carapace"

[[ -f "${DOTFILES_DIR}/config/tools.d/carapace.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/carapace.zsh"

export CARAPACE_CACHE="${XDG_CACHE_HOME:-${HOME}/.cache}/carapace"
local _bridges="zsh"; has "fish" && _bridges+=",fish"; has "bash" && _bridges+=",bash"
export CARAPACE_BRIDGES="$_bridges"

eval "$(carapace _carapace zsh)"

function carapace-list()  { has "fzf" && carapace --list | fzf --header='Completions' || carapace --list; }
function carapace-info()  { printf "\n  🐢 Carapace\n  ─────────────────\n  Completers: %s\n  Bridges: %s\n  ─────────────────\n\n" "$(carapace --list 2>/dev/null | wc -l | tr -d ' ')" "$CARAPACE_BRIDGES"; }
function carapace-clear() { [[ -d "$CARAPACE_CACHE" ]] && rm -rf "${CARAPACE_CACHE:?}"/* && log_info "Cache cleared"; }

log_debug "carapace configured"
