#!/usr/bin/env zsh
# ============================================================================
# @file        tools/wezterm.zsh
# @description WezTerm integration. Auto-clones wezterm-enterprise config,
#              provides CLI shortcuts and configuration management.
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-17
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/tool-check.zsh
# ============================================================================

[[ -n "${_ZSH_TOOLS_WEZTERM_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_WEZTERM_LOADED=1

has "wezterm" || return 0

log_debug "Configuring wezterm"

# ============================================================================
# Constants
# ============================================================================

readonly WEZTERM_CONFIG_REPO="https://github.com/ca971/wezterm-enterprise.git"
readonly WEZTERM_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/wezterm"

# ============================================================================
# Auto-Setup
# ============================================================================

function _wezterm_auto_setup() {
  if [[ ! -d "${WEZTERM_CONFIG_DIR}/.git" ]]; then
    if [[ -d "$WEZTERM_CONFIG_DIR" ]] && [[ -n "$(ls -A "$WEZTERM_CONFIG_DIR" 2>/dev/null)" ]]; then
      mv "$WEZTERM_CONFIG_DIR" "${WEZTERM_CONFIG_DIR}.bak.$(date +%s)" >/dev/null 2>&1
    fi
    log_info "Cloning wezterm-enterprise..."
    git clone --depth=1 "$WEZTERM_CONFIG_REPO" "$WEZTERM_CONFIG_DIR" >/dev/null 2>&1 && \
      log_info "wezterm-enterprise installed" || \
      log_warn "wezterm-enterprise clone failed"
  else
    { git -C "$WEZTERM_CONFIG_DIR" pull --rebase --quiet 2>/dev/null } &!
  fi
}

_wezterm_auto_setup

# ============================================================================
# Aliases & Functions
# ============================================================================

if has "wezterm"; then
  alias wt-tab="wezterm cli spawn"
  alias wt-split-h="wezterm cli split-pane --horizontal"
  alias wt-split-v="wezterm cli split-pane --bottom"
  alias wt-panes="wezterm cli list"
fi

# @description  Display image inline (WezTerm imgcat)
function icat() {
  if has "wezterm"; then
    wezterm imgcat "$@"
  else
    log_warn "wezterm CLI not available"
  fi
}

# @description  Show wezterm-enterprise config info
function wezterm-info() {
  printf "\n  🔲 WezTerm Config\n"
  printf "  ─────────────────────────────────\n"
  printf "  Repo:    %s\n" "$WEZTERM_CONFIG_REPO"
  printf "  Local:   %s\n" "$WEZTERM_CONFIG_DIR"
  if [[ -d "${WEZTERM_CONFIG_DIR}/.git" ]]; then
    printf "  Status:  ✅ installed\n"
    printf "  Commit:  %s\n" "$(git -C "$WEZTERM_CONFIG_DIR" rev-parse --short HEAD 2>/dev/null)"
    printf "  Updated: %s\n" "$(git -C "$WEZTERM_CONFIG_DIR" log -1 --format='%ar' 2>/dev/null)"
  else
    printf "  Status:  ❌ not installed\n"
  fi
  printf "  ─────────────────────────────────\n\n"
}

# @description  Update wezterm-enterprise config
function wezterm-update() {
  if [[ -d "${WEZTERM_CONFIG_DIR}/.git" ]]; then
    log_info "Updating wezterm-enterprise..."
    git -C "$WEZTERM_CONFIG_DIR" pull --rebase
  else
    _wezterm_auto_setup
  fi
}

# @description  Reinstall wezterm-enterprise from scratch
function wezterm-reinstall() {
  printf "  ⚠️  Remove and reclone? [y/N]: "
  read -rk1 confirm; echo
  if [[ "${confirm:l}" == "y" ]]; then
    rm -rf "$WEZTERM_CONFIG_DIR"
    _wezterm_auto_setup
  fi
}

export COLORTERM="truecolor"

log_debug "wezterm configured"
