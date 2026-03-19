#!/usr/bin/env zsh
# ============================================================================
# @file        tools/topgrade.zsh
# @description Topgrade integration. Auto-symlinks config from dotfiles repo.
#              Config files are versioned in config/topgrade/ — NOT generated.
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     3.0.0
#
# @depends     lib/logging.zsh, lib/tool-check.zsh, lib/platform-detect.zsh
# ============================================================================

[[ -n "${_ZSH_TOOLS_TOPGRADE_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_TOPGRADE_LOADED=1

has "topgrade" || return 0

log_debug "Configuring topgrade"

# ============================================================================
# Constants
# ============================================================================

readonly TOPGRADE_SRC_DIR="${DOTFILES_DIR}/config/topgrade"
readonly TOPGRADE_DST_TOML="${XDG_CONFIG_HOME:-${HOME}/.config}/topgrade.toml"
readonly TOPGRADE_DST_D="${XDG_CONFIG_HOME:-${HOME}/.config}/topgrade.d"

# ============================================================================
# Auto-Setup — Symlinks
# ============================================================================

function _topgrade_auto_setup() {

  # ── 1. Symlink topgrade.toml ────────────────────────────────────────
  local src_toml="${TOPGRADE_SRC_DIR}/topgrade.toml"
  if [[ -f "$src_toml" ]]; then
    if [[ -f "$TOPGRADE_DST_TOML" ]] && [[ ! -L "$TOPGRADE_DST_TOML" ]]; then
      mv "$TOPGRADE_DST_TOML" "${TOPGRADE_DST_TOML}.bak.$(date +%s)" >/dev/null 2>&1
    fi
    if [[ ! -L "$TOPGRADE_DST_TOML" ]] || [[ "$(readlink "$TOPGRADE_DST_TOML" 2>/dev/null)" != "$src_toml" ]]; then
      ln -sf "$src_toml" "$TOPGRADE_DST_TOML" >/dev/null 2>&1
    fi
  fi

  # ── 2. Symlink topgrade.d/ ──────────────────────────────────────────
  local src_d="${TOPGRADE_SRC_DIR}/topgrade.d"
  if [[ -d "$src_d" ]]; then
    if [[ -d "$TOPGRADE_DST_D" ]] && [[ ! -L "$TOPGRADE_DST_D" ]]; then
      mv "$TOPGRADE_DST_D" "${TOPGRADE_DST_D}.bak.$(date +%s)" >/dev/null 2>&1
    fi
    if [[ ! -L "$TOPGRADE_DST_D" ]] || [[ "$(readlink "$TOPGRADE_DST_D" 2>/dev/null)" != "$src_d" ]]; then
      ln -sf "$src_d" "$TOPGRADE_DST_D" >/dev/null 2>&1
    fi
  fi
}

_topgrade_auto_setup

# ============================================================================
# Aliases
# ============================================================================

alias upgrade="topgrade"
alias upgrade-yes="topgrade --yes"
alias upgrade-dry="topgrade --dry-run"
alias upgrade-clean="topgrade --cleanup"

# ============================================================================
# Functions
# ============================================================================

# @description  Run topgrade with only specific steps
function upgrade-only() {
  [[ $# -eq 0 ]] && { log_error "Usage: upgrade-only <step1> [step2] ..."; return 1; }
  topgrade --only "$@"
}

# @description  Run topgrade excluding specific steps
function upgrade-skip() {
  [[ $# -eq 0 ]] && { log_error "Usage: upgrade-skip <step1> [step2] ..."; return 1; }
  topgrade --disable "$@"
}

# @description  Edit topgrade config
function upgrade-config() {
  "${EDITOR:-nvim}" "${TOPGRADE_SRC_DIR}/topgrade.toml"
}

# @description  Show what topgrade would update
function upgrade-check() {
  topgrade --dry-run 2>&1 | head -50
}

# @description  Show topgrade config info
function topgrade-info() {
  printf "\n  ⬆️  Topgrade\n"
  printf "  ─────────────────────────────────\n"
  printf "  Source:   %s\n" "$TOPGRADE_SRC_DIR"
  printf "  Version:  %s\n" "$(topgrade --version 2>/dev/null | head -1)"
  printf "  Platform: %s (%s)\n" "$ZSH_PLATFORM" "${ZSH_DISTRO:-unknown}"

  if [[ -L "$TOPGRADE_DST_TOML" ]]; then
    printf "  Config:   ✅ ~/.config/topgrade.toml → %s\n" "$(readlink "$TOPGRADE_DST_TOML" | sed "s|${DOTFILES_DIR}|dotfiles|")"
  else
    printf "  Config:   ❌ ~/.config/topgrade.toml not linked\n"
  fi

  if [[ -L "$TOPGRADE_DST_D" ]]; then
    printf "  Extra:    ✅ ~/.config/topgrade.d/ → %s\n" "$(readlink "$TOPGRADE_DST_D" | sed "s|${DOTFILES_DIR}|dotfiles|")"
  else
    printf "  Extra:    ❌ ~/.config/topgrade.d/ not linked\n"
  fi

  if [[ -f "$TOPGRADE_DST_TOML" ]]; then
    local cmds
    cmds=$(grep -E '^\s*"' "$TOPGRADE_DST_TOML" 2>/dev/null)
    [[ -n "$cmds" ]] && { printf "  Commands:\n"; echo "$cmds" | sed 's/^/    /'; }
  fi

  printf "  ─────────────────────────────────\n\n"
}

# @description  Quick package manager update only
function pkg-update() {
  case "${ZSH_PKG_MANAGER:-}" in
    brew)   brew update && brew upgrade && brew cleanup ;;
    apt)    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y ;;
    dnf)    sudo dnf upgrade -y --refresh ;;
    pacman)
      if has "paru"; then paru -Syu --noconfirm
      elif has "yay"; then yay -Syu --noconfirm
      else sudo pacman -Syu --noconfirm; fi ;;
    nix)    nix-channel --update && nix-env --upgrade ;;
    *)      log_warn "Unknown: %s" "${ZSH_PKG_MANAGER:-}" ;;
  esac
}

log_debug "topgrade configured"
