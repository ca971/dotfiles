#!/usr/bin/env zsh

# ============================================================================
# @file        tools/mise.zsh
# @description Mise — Tools and Runtimes installer.
# @version     1.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_MISE_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_MISE_LOADED=1

has "mise" || return 0
log_debug "Configuring mise"

# ── Initialize ───────────────────────────────────────────────────────────────
eval "$(mise activate zsh)"

# ── Auto-Setup Symlink ───────────────────────────────────────────────────────
readonly MISE_SRC_DIR="${DOTFILES_DIR}/config/mise"
readonly MISE_DST_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/mise"

function _mise_auto_setup() {
    local src="${MISE_SRC_DIR}"
    [[ -d "$src" ]] || return 0
    if [[ -d "$MISE_DST_DIR" && ! -L "$MISE_DST_DIR" ]]; then
        mv "$MISE_DST_DIR" "${MISE_DST_DIR}.bak.$(date +%s)" 2>/dev/null
    fi
    if [[ ! -L "$MISE_DST_DIR" ]] || \
       [[ "$(readlink "$MISE_DST_DIR" 2>/dev/null)" != "$src" ]]; then
        ln -sf "$src" "$MISE_DST_DIR" 2>/dev/null
    fi
}
_mise_auto_setup

# ── Completions ──────────────────────────────────────────────────────────────
local _comp="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME}/zsh}/mise-completions.zsh"
if [[ ! -f "$_comp" ]] || [[ "$(mise --version 2>/dev/null)" != "$(cat "${_comp}.ver" 2>/dev/null)" ]]; then
  mise completions zsh >| "$_comp" 2>/dev/null; mise --version >| "${_comp}.ver" 2>/dev/null
fi
[[ -f "$_comp" ]] && source "$_comp"

# ── Functions ────────────────────────────────────────────────────────────────
function mise-versions() { local t="${1:?Tool?}" f="${2:-}"; [[ -n "$f" ]] && mise ls-remote "$t" | grep "^${f}" || { has "fzf" && mise ls-remote "$t" | fzf --tac --header="$t versions" || mise ls-remote "$t"; }; }
function mise-install()  { local t="${1:?Tool?}" v; has "fzf" && v=$(mise ls-remote "$t" | fzf --tac --header="Install $t") || { mise ls-remote "$t" | tail -20; printf "Version: "; read -r v; }; [[ -n "$v" ]] && mise install "${t}@${v}"; }
function mise-global()   { [[ $# -lt 2 ]] && { log_error "Usage: mise-global <tool> <version>"; return 1; }; mise use --global "${1}@${2}"; }
function mise-local()    { [[ $# -lt 2 ]] && { log_error "Usage: mise-local <tool> <version>"; return 1; }; mise use "${1}@${2}"; }
function mise-doctor()   { mise doctor; }
function mise-upgrade()  { mise upgrade --yes; }
function mise-prune()    { mise prune --yes; }

log_debug "mise configured"
