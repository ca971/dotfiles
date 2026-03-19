#!/usr/bin/env zsh
# ============================================================================
# @file        platform/arch.zsh
# @description Arch Linux specific configuration. Configures pacman, AUR
#              helpers (paru/yay), and Arch-specific system utilities.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_PLATFORM_ARCH_LOADED:-}" ]] && return 0
readonly _ZSH_PLATFORM_ARCH_LOADED=1

# -- Match Arch-based distros
case "$ZSH_DISTRO" in
  arch|manjaro|endeavouros|garuda|artix|cachyos) ;;
  *) return 0 ;;
esac

log_debug "Loading Arch Linux platform configuration"

# ============================================================================
# AUR Helper Detection
# ============================================================================

# @type  string
# @description  Detected AUR helper command
typeset -g AUR_HELPER=""

if has "paru"; then
  AUR_HELPER="paru"
elif has "yay"; then
  AUR_HELPER="yay"
elif has "pikaur"; then
  AUR_HELPER="pikaur"
fi

# @description  Unified package manager command (AUR helper or pacman)
typeset -g PKG_CMD="${AUR_HELPER:-sudo pacman}"

# ============================================================================
# Package Management Aliases
# ============================================================================

# @description  Install packages
alias paci="${PKG_CMD} -S"

# @description  Install packages without confirmation
alias paciy="${PKG_CMD} -S --noconfirm"

# @description  Remove packages with dependencies
alias pacr="${PKG_CMD} -Rns"

# @description  Update system (full sync + upgrade)
alias pacu="${PKG_CMD} -Syu"

# @description  Search packages
alias pacs="${PKG_CMD} -Ss"

# @description  Show package info
alias pacinfo="${PKG_CMD} -Si"

# @description  List installed packages
alias pacls="pacman -Qe"

# @description  List explicitly installed packages (not dependencies)
alias pacexplicit="pacman -Qet"

# @description  List orphaned packages (no longer needed as dependencies)
alias pacorphans="pacman -Qdt"

# @description  Clean package cache
alias paccache="sudo pacman -Sc"

# @description  Which package owns a file
alias pacown="pacman -Qo"

# @description  List files owned by a package
alias pacfiles="pacman -Ql"

# ============================================================================
# Functions
# ============================================================================

# @description  Interactive package search and install via FZF
# @return       void
function pac-install() {
  if ! has "fzf"; then
    ${PKG_CMD} -Ss "$@"
    return
  fi

  local pkg
  pkg=$(${PKG_CMD} -Sl 2>/dev/null | awk '{print $2}' | \
    fzf --multi --header='📦 Select packages to install' \
        --preview="${PKG_CMD} -Si {1} 2>/dev/null" \
        --preview-window='right:50%:wrap')

  [[ -n "$pkg" ]] && echo "$pkg" | xargs ${PKG_CMD} -S
}

# @description  Remove orphaned packages interactively
# @return       void
function pac-clean-orphans() {
  local orphans
  orphans=$(pacman -Qdt 2>/dev/null | awk '{print $1}')

  if [[ -z "$orphans" ]]; then
    log_info "No orphaned packages found"
    return 0
  fi

  printf "  Orphaned packages:\n%s\n\n" "$orphans"
  if confirm "Remove these packages?"; then
    echo "$orphans" | xargs sudo pacman -Rns --noconfirm
    log_info "Orphans removed"
  fi
}

# @description  Show recently installed/upgraded packages
# @param  $1    integer  (optional) Number of entries (default: 20)
# @return       void
function pac-recent() {
  local count="${1:-20}"
  grep -E '(installed|upgraded)' /var/log/pacman.log 2>/dev/null | \
    tail -"$count"
}

# @description  Check for .pacnew and .pacsave configuration files
# @return       void
function pac-config-check() {
  printf "\n  📋 Pacman Configuration Files\n\n"

  local pacnew
  pacnew=$(sudo find /etc -name "*.pacnew" 2>/dev/null)
  local pacsave
  pacsave=$(sudo find /etc -name "*.pacsave" 2>/dev/null)

  if [[ -n "$pacnew" ]]; then
    printf "  .pacnew files (need merging):\n"
    echo "$pacnew" | while read -r f; do
      printf "    %s\n" "$f"
    done
  else
    printf "  ✅ No .pacnew files\n"
  fi

  if [[ -n "$pacsave" ]]; then
    printf "\n  .pacsave files (old configs):\n"
    echo "$pacsave" | while read -r f; do
      printf "    %s\n" "$f"
    done
  else
    printf "  ✅ No .pacsave files\n"
  fi
  printf "\n"
}

log_debug "Arch platform configured (AUR helper: %s)" "${AUR_HELPER:-none}"
