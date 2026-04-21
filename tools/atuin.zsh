#!/usr/bin/env zsh
# ============================================================================
# @file        tools/atuin.zsh
# @description Atuin — shell history engine.
# @version     5.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_ATUIN_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_ATUIN_LOADED=1

has "atuin" || return 0
log_debug "Configuring atuin"

# ── Initialize ───────────────────────────────────────────────────────────────
eval "$(atuin init zsh --disable-up-arrow)"

# ── Fallback: Saves the ZLE widget if the atuin init command fails ───────────
if (( ! ${+widgets[atuin-search]} )) && (( ${+functions[_atuin_search]} )); then
    zle -N atuin-search _atuin_search
fi

# ── Auto-Setup Symlink ───────────────────────────────────────────────────────
readonly ATUIN_SRC_DIR="${DOTFILES_DIR}/config/atuin"
readonly ATUIN_DST_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/atuin"

function _atuin_auto_setup() {
    local src="${ATUIN_SRC_DIR}"
    [[ -d "$src" ]] || return 0
    if [[ -d "$ATUIN_DST_DIR" && ! -L "$ATUIN_DST_DIR" ]]; then
        mv "$ATUIN_DST_DIR" "${ATUIN_DST_DIR}.bak.$(date +%s)" 2>/dev/null
    fi
    if [[ ! -L "$ATUIN_DST_DIR" ]] || \
       [[ "$(readlink "$ATUIN_DST_DIR" 2>/dev/null)" != "$src" ]]; then
        ln -sf "$src" "$ATUIN_DST_DIR" 2>/dev/null
    fi
}
_atuin_auto_setup

# ── Functions ────────────────────────────────────────────────────────────────
function atuin-status() {
    local t
    t=$(atuin history list --format '{id}' 2>/dev/null | wc -l | tr -d ' ')
    printf "\n  📜 Atuin\n  ─────────────────────\n"
    printf "  Entries: %s\n  Config:  %s\n  ─────────────────────\n\n" \
        "$t" "${ATUIN_CONFIG_DIR}"
}
function asearch()      { atuin search "$@"; }
function atop()         { atuin stats; }
function atuin-import() { log_info "Importing..."; atuin import auto; }
function atuin-sync()   { log_info "Syncing..."; atuin sync; }

log_debug "atuin configured"
