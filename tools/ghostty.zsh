#!/usr/bin/env zsh
# ============================================================================
# @file        tools/ghostty.zsh
# @description Ghostty config management. Auto-clones ghostty-config repo,
#              provides configuration management functions.
#              Terminal-specific features are in shells/zsh/terminal/ghostty.zsh
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-17
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/tool-check.zsh
# ============================================================================

[[ -n "${_ZSH_TOOLS_GHOSTTY_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_GHOSTTY_LOADED=1

# Only load if Ghostty is installed
[[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]] || has "ghostty" || return 0

log_debug "Configuring ghostty"

# ============================================================================
# Constants
# ============================================================================

readonly GHOSTTY_CONFIG_REPO="https://github.com/ca971/ghostty-config.git"
readonly GHOSTTY_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/ghostty"

# ============================================================================
# Auto-Setup
# ============================================================================

function _ghostty_auto_setup() {
  if [[ ! -d "${GHOSTTY_CONFIG_DIR}/.git" ]]; then
    if [[ -d "$GHOSTTY_CONFIG_DIR" ]] && [[ -n "$(ls -A "$GHOSTTY_CONFIG_DIR" 2>/dev/null)" ]]; then
      mv "$GHOSTTY_CONFIG_DIR" "${GHOSTTY_CONFIG_DIR}.bak.$(date +%s)" >/dev/null 2>&1
    fi
    log_info "Cloning ghostty-config..."
    git clone --depth=1 "$GHOSTTY_CONFIG_REPO" "$GHOSTTY_CONFIG_DIR" >/dev/null 2>&1 && \
      log_info "ghostty-config installed" || \
      log_warn "ghostty-config clone failed"
  else
    { git -C "$GHOSTTY_CONFIG_DIR" pull --rebase --quiet 2>/dev/null } &!
  fi
}

# _ghostty_auto_setup

# ============================================================================
# Functions
# ============================================================================

# @description  Show ghostty-config info
function ghostty-info() {
  printf "\n  👻 Ghostty Config\n"
  printf "  ─────────────────────────────────\n"
  printf "  Repo:    %s\n" "$GHOSTTY_CONFIG_REPO"
  printf "  Local:   %s\n" "$GHOSTTY_CONFIG_DIR"
  if [[ -d "${GHOSTTY_CONFIG_DIR}/.git" ]]; then
    printf "  Status:  ✅ installed\n"
    printf "  Commit:  %s\n" "$(git -C "$GHOSTTY_CONFIG_DIR" rev-parse --short HEAD 2>/dev/null)"
    printf "  Updated: %s\n" "$(git -C "$GHOSTTY_CONFIG_DIR" log -1 --format='%ar' 2>/dev/null)"
  else
    printf "  Status:  ❌ not installed\n"
  fi
  printf "  ─────────────────────────────────\n\n"
}

# @description  Update ghostty-config
function ghostty-update() {
  if [[ -d "${GHOSTTY_CONFIG_DIR}/.git" ]]; then
    log_info "Updating ghostty-config..."
    git -C "$GHOSTTY_CONFIG_DIR" pull --rebase
  else
    _ghostty_auto_setup
  fi
}

# @description  Reinstall ghostty-config from scratch
function ghostty-reinstall() {
  printf "  ⚠️  Remove and reclone? [y/N]: "
  read -rk1 confirm; echo
  if [[ "${confirm:l}" == "y" ]]; then
    rm -rf "$GHOSTTY_CONFIG_DIR"
    _ghostty_auto_setup
  fi
}

# @description  Edit ghostty config
function ghostty-edit() {
  "${EDITOR:-nvim}" "${GHOSTTY_CONFIG_DIR}/config"
}

export COLORTERM="truecolor"

log_debug "ghostty configured"
