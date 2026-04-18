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

# Skip eval if already initialized by tools-init.sh
if [[ -z "${_ATUIN_INITIALIZED:-}" ]]; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# ============================================================================
# Constants
# ============================================================================

readonly ATUIN_SRC_DIR="${DOTFILES_DIR}/config/atuin"
readonly ATUIN_DST_D="${XDG_CONFIG_HOME:-${HOME}/.config}/atuin"

# ============================================================================
# Auto-Setup — Symlinks
# ============================================================================

function _atuin_auto_setup() {

  # ── 1. Symlink atuin/ ────────────────────────────────────────────
  local src_d="${ATUIN_SRC_DIR}"
  if [[ -d "$src_d" ]]; then
    if [[ -d "$ATUIN_DST_D" ]] && [[ ! -L "$ATUIN_DST_D" ]]; then
      mv "$ATUIN_DST_D" "${ATUIN_DST_D}.bak.$(date +%s)" >/dev/null 2>&1
    fi
    if [[ ! -L "$ATUIN_DST_D" ]] || [[ "$(readlink "$ATUIN_DST_D" 2>/dev/null)" != "$src_d" ]]; then
      ln -sf "$src_d" "$ATUIN_DST_D" >/dev/null 2>&1
    fi
  fi
}

_atuin_auto_setup

# ============================================================================
# Functions
# ============================================================================

function atuin-status() { printf "\n  📜 Atuin\n  ─────────────────────\n"; local t=$(atuin history list --format '{id}' 2>/dev/null | wc -l | tr -d ' '); printf "  Entries: %s\n  Config:  %s\n  ─────────────────────\n\n" "$t" "${ATUIN_CONFIG_DIR}"; }
function asearch()      { atuin search "$@"; }
function atop()         { atuin stats; }
function atuin-import() { log_info "Importing..."; atuin import auto; }
function atuin-sync()   { log_info "Syncing..."; atuin sync; }

log_debug "atuin configured"
