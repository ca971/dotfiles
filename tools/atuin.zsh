#!/usr/bin/env zsh
# ============================================================================
# @file        tools/atuin.zsh
# @description Atuin (shell history engine).
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_ATUIN_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_ATUIN_LOADED=1

has "atuin" || return 0
log_debug "Configuring atuin"


eval "$(atuin init zsh --disable-up-arrow)"

function atuin-status() { printf "\n  📜 Atuin\n  ─────────────────────\n"; local t=$(atuin history list --format '{id}' 2>/dev/null | wc -l | tr -d ' '); printf "  Entries: %s\n  Config:  %s\n  ─────────────────────\n\n" "$t" "${ATUIN_CONFIG_DIR}"; }
function asearch()      { atuin search "$@"; }
function atop()         { atuin stats; }
function atuin-import() { log_info "Importing..."; atuin import auto; }
function atuin-sync()   { log_info "Syncing..."; atuin sync; }

log_debug "atuin configured"
