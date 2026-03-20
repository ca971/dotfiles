#!/usr/bin/env zsh
# ============================================================================
# @file        tools/alacritty.zsh
# @description Alacritty — auto-clone config + functions.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_ALACRITTY_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_ALACRITTY_LOADED=1

[[ -n "${ALACRITTY_SOCKET:-}" ]] || [[ "${TERM_PROGRAM:-}" == "Alacritty" ]] || has "alacritty" || return 0
log_debug "Configuring alacritty"

readonly ALACRITTY_CONFIG_REPO="https://github.com/ca971/alacritty.git"
readonly ALACRITTY_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/alacritty"


# ── Auto-clone config ───────────────────────────────────────────────────────
function _alacritty_auto_setup() {
  if [[ ! -d "${ALACRITTY_CONFIG_DIR}/.git" ]]; then
    if [[ -d "$ALACRITTY_CONFIG_DIR" ]] && [[ -n "$(ls -A "$ALACRITTY_CONFIG_DIR" 2>/dev/null)" ]]; then
      mv "$ALACRITTY_CONFIG_DIR" "${ALACRITTY_CONFIG_DIR}.bak.$(date +%s)" >/dev/null 2>&1
    fi
    log_info "Cloning alacritty config..."
    git clone --depth=1 "$ALACRITTY_CONFIG_REPO" "$ALACRITTY_CONFIG_DIR" >/dev/null 2>&1 && \
      log_info "alacritty config installed" || \
      log_warn "alacritty config clone failed"
  else
    { git -C "$ALACRITTY_CONFIG_DIR" pull --rebase --quiet 2>/dev/null } &!
  fi
}
# _alacritty_auto_setup

# ── Functions ────────────────────────────────────────────────────────────────
function alacritty-info() {
  printf "\n  ⬛ Alacritty Config\n"
  printf "  ─────────────────────────────────\n"
  printf "  Repo:    %s\n" "$ALACRITTY_CONFIG_REPO"
  printf "  Local:   %s\n" "$ALACRITTY_CONFIG_DIR"
  if [[ -d "${ALACRITTY_CONFIG_DIR}/.git" ]]; then
    printf "  Status:  ✅ installed\n"
    printf "  Commit:  %s\n" "$(git -C "$ALACRITTY_CONFIG_DIR" rev-parse --short HEAD 2>/dev/null)"
    printf "  Updated: %s\n" "$(git -C "$ALACRITTY_CONFIG_DIR" log -1 --format='%ar' 2>/dev/null)"
  else
    printf "  Status:  ❌ not installed\n"
  fi
  printf "  Version: %s\n" "$(alacritty --version 2>/dev/null | head -1 || echo 'N/A')"
  printf "  ─────────────────────────────────\n\n"
}

function alacritty-update() {
  if [[ -d "${ALACRITTY_CONFIG_DIR}/.git" ]]; then
    log_info "Updating alacritty config..."
    git -C "$ALACRITTY_CONFIG_DIR" pull --rebase
  else
    _alacritty_auto_setup
  fi
}

function alacritty-reinstall() {
  printf "  ⚠️  Remove and reclone? [y/N]: "
  read -rk1 c; echo
  [[ "${c:l}" == "y" ]] && { rm -rf "$ALACRITTY_CONFIG_DIR"; _alacritty_auto_setup; }
}

function alacritty-edit() {
  "${EDITOR:-nvim}" "${ALACRITTY_CONFIG_DIR}/alacritty.toml"
}

function alacritty-reload() {
  local config="${ALACRITTY_CONFIG_DIR}/alacritty.toml"
  [[ -f "$config" ]] && { touch "$config"; log_info "Live-reload triggered"; } || log_warn "Config not found"
}

# ── Image fallback (no image protocol) ───────────────────────────────────────
function icat() {
  if has "chafa"; then chafa "$@"
  elif has "catimg"; then catimg "$@"
  else log_warn "No image viewer (install chafa)"; file "$@"; fi
}

log_debug "alacritty configured"
