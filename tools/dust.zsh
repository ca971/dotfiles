#!/usr/bin/env zsh
# ============================================================================
# @file        tools/dust.zsh
# @description Dust (du replacement) + duf/dfc integration.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_DUST_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_DUST_LOADED=1

has "dust" || return 0
log_debug "Configuring dust"

[[ -f "${DOTFILES_DIR}/config/tools.d/dust.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/dust.zsh"

if has "duf"; then alias df="duf"; fi
if has "dfc"; then alias dfc="dfc -T -W -w"; fi

# ── Functions ────────────────────────────────────────────────────────────────
function disk-usage()   { dust -d "${2:-3}" "${1:-.}"; }
function disk-biggest() { local dir="${1:-.}" count="${2:-20}"; has "fd" && fd --type f . "$dir" --exec-batch ls -lhS {} + 2>/dev/null | sort -k5 -h -r | head -"$count" || find "$dir" -type f -exec ls -lhS {} + 2>/dev/null | sort -k5 -h -r | head -"$count"; }
function disk-dirs()    { dust -d 1 -n "${2:-10}" "${1:-.}"; }
function disk-total()   { dust -s -d 0 "${1:-.}"; }

log_debug "dust configured"
