#!/usr/bin/env zsh
# ============================================================================
# @file        tools/kitty.zsh
# @description Kitty — auto-clone config + shell integration + functions.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_KITTY_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_KITTY_LOADED=1

[[ "${TERM:-}" == "xterm-kitty" ]] || [[ -n "${KITTY_PID:-}" ]] || has "kitty" || return 0
log_debug "Configuring kitty"

readonly KITTY_CONFIG_REPO="https://github.com/ca971/kitty.git"
readonly KITTY_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/kitty"

[[ -f "${DOTFILES_DIR}/config/tools.d/kitty.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/kitty.zsh"

# ── Auto-clone config ───────────────────────────────────────────────────────
function _kitty_auto_setup() {
  if [[ ! -d "${KITTY_CONFIG_DIR}/.git" ]]; then
    if [[ -d "$KITTY_CONFIG_DIR" ]] && [[ -n "$(ls -A "$KITTY_CONFIG_DIR" 2>/dev/null)" ]]; then
      mv "$KITTY_CONFIG_DIR" "${KITTY_CONFIG_DIR}.bak.$(date +%s)" >/dev/null 2>&1
    fi
    log_info "Cloning kitty config..."
    git clone --depth=1 "$KITTY_CONFIG_REPO" "$KITTY_CONFIG_DIR" >/dev/null 2>&1 && \
      log_info "kitty config installed" || \
      log_warn "kitty config clone failed"
  else
    { git -C "$KITTY_CONFIG_DIR" pull --rebase --quiet 2>/dev/null } &!
  fi
}

# _kitty_auto_setup

# ── Shell integration ────────────────────────────────────────────────────────
if [[ -n "${KITTY_INSTALLATION_DIR:-}" ]]; then
  local _ki="${KITTY_INSTALLATION_DIR}/shell-integration/zsh/kitty.zsh"
  [[ -f "$_ki" ]] && source "$_ki"
fi

# ── Kitten detection ─────────────────────────────────────────────────────────
if ! has "kitten"; then
  has "kitty" && alias kitten="kitty +kitten"
fi

# ── Functions ────────────────────────────────────────────────────────────────
function kitty-info() {
  printf "\n  🐱 Kitty Config\n"
  printf "  ─────────────────────────────────\n"
  printf "  Repo:    %s\n" "$KITTY_CONFIG_REPO"
  printf "  Local:   %s\n" "$KITTY_CONFIG_DIR"
  if [[ -d "${KITTY_CONFIG_DIR}/.git" ]]; then
    printf "  Status:  ✅ installed\n"
    printf "  Commit:  %s\n" "$(git -C "$KITTY_CONFIG_DIR" rev-parse --short HEAD 2>/dev/null)"
    printf "  Updated: %s\n" "$(git -C "$KITTY_CONFIG_DIR" log -1 --format='%ar' 2>/dev/null)"
  else
    printf "  Status:  ❌ not installed\n"
  fi
  printf "  PID:     %s\n" "${KITTY_PID:-N/A}"
  printf "  Version: %s\n" "$(kitty --version 2>/dev/null | head -1 || echo 'N/A')"
  printf "  Listen:  %s\n" "${KITTY_LISTEN_ON:-not set}"
  printf "  ─────────────────────────────────\n\n"
}

function kitty-update() {
  if [[ -d "${KITTY_CONFIG_DIR}/.git" ]]; then
    log_info "Updating kitty config..."
    git -C "$KITTY_CONFIG_DIR" pull --rebase
  else
    _kitty_auto_setup
  fi
}

function kitty-reinstall() {
  printf "  ⚠️  Remove and reclone? [y/N]: "
  read -rk1 c; echo
  [[ "${c:l}" == "y" ]] && { rm -rf "$KITTY_CONFIG_DIR"; _kitty_auto_setup; }
}

function kitty-edit() {
  "${EDITOR:-nvim}" "${KITTY_CONFIG_DIR}/kitty.conf"
}

function kitty-reload() {
  kill -SIGUSR1 "${KITTY_PID:-0}" 2>/dev/null && log_info "Kitty reloaded" || log_warn "Kitty not running"
}

function kitty-theme() {
  if has "kitten"; then kitten themes
  else log_warn "kitten not available"; fi
}

# ── Image display (Kitty protocol) ──────────────────────────────────────────
function icat() {
  [[ ! -f "${1:-}" ]] && { log_error "File not found: %s" "${1:-}"; return 1; }
  if has "kitten"; then
    kitten icat "$@"
  else
    local data; data=$(base64 < "$1")
    printf '\e_Ga=T,f=100,t=f;%s\e\\' "$data"
  fi
}

log_debug "kitty configured"
