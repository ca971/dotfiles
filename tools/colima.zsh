#!/usr/bin/env zsh

# ============================================================================
# @file        tools/colima.zsh
# @description Colima — Container runtimes on macOS with Lima.
# @version     1.1.1
# ============================================================================

# ── Platform Check ───────────────────────────────────────────────────────────
# Only run Colima configuration on macOS
[[ "$OSTYPE" != darwin* ]] && return 0

[[ -n "${_ZSH_TOOLS_COLIMA_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_COLIMA_LOADED=1

has "colima" || return 0
log_debug "Configuring colima for macOS"

# ── Env Variables ────────────────────────────────────────────────────────────
# Force XDG compliance and prevent the creation of ~/.colima in $HOME
export COLIMA_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}/colima"

# ── Auto-Setup Symlink ───────────────────────────────────────────────────────
readonly COLIMA_SRC_DIR="${DOTFILES_DIR}/config/colima"
# Specific destination for the "default" profile
readonly COLIMA_DST_DEFAULT="${COLIMA_HOME}/default"

function _colima_auto_setup() {
    # 1. Safety check: ensure the source directory exists in dotfiles
    [[ -d "$COLIMA_SRC_DIR" ]] || return 0

    # 2. Create the parent directory tree if necessary
    [[ -d "$COLIMA_HOME" ]] || mkdir -p "$COLIMA_HOME"

    # 3. Handle the "default" profile symlink
    # If a physical directory exists instead of a symlink, back it up
    if [[ -d "$COLIMA_DST_DEFAULT" && ! -L "$COLIMA_DST_DEFAULT" ]]; then
        mv "$COLIMA_DST_DEFAULT" "${COLIMA_DST_DEFAULT}.bak.$(date +%s)" 2>/dev/null
    fi

    # 4. Create or update the directory symlink
    # Uses 'ln -sfn' to force the update if the link points to the wrong location
    if [[ "$(readlink "$COLIMA_DST_DEFAULT" 2>/dev/null)" != "$COLIMA_SRC_DIR" ]]; then
        ln -sfn "$COLIMA_SRC_DIR" "$COLIMA_DST_DEFAULT" 2>/dev/null
    fi
}
_colima_auto_setup

# ── Completions ──────────────────────────────────────────────────────────────
local _comp="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME}/zsh}/colima-completions.zsh"
if [[ ! -f "$_comp" ]] || [[ "$(colima version 2>/dev/null)" != "$(cat "${_comp}.ver" 2>/dev/null)" ]]; then
  colima completion zsh >| "$_comp" 2>/dev/null; colima version >| "${_comp}.ver" 2>/dev/null
fi
[[ -f "$_comp" ]] && source "$_comp"

# ── Functions ────────────────────────────────────────────────────────────────
function costart()   { colima start "$@"; }
function costop()    { colima stop "$@"; }
function costatus()  { colima status; }
function coedit()    { ${EDITOR:-nano} "${COLIMA_SRC_DIR}/colima.yaml"; }
function coclean()   {
    colima delete -f
    rm -rf "$COLIMA_DST_DEFAULT"
    _colima_auto_setup
    log_info "Colima environment reset and symlink restored."
}

log_debug "colima configured"
