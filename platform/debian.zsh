#!/usr/bin/env zsh
# ============================================================================
# @file        platform/debian.zsh
# @description Debian/Ubuntu specific configuration. Configures apt package
#              manager aliases, handles tool name differences (batcat, fdfind),
#              and provides Debian-specific utilities.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_PLATFORM_DEBIAN_LOADED:-}" ]] && return 0
readonly _ZSH_PLATFORM_DEBIAN_LOADED=1

# -- Match Debian-based distros
case "$ZSH_DISTRO" in
  debian|ubuntu|linuxmint|pop|elementary|zorin|kali|parrot|raspbian) ;;
  *) return 0 ;;
esac

log_debug "Loading Debian/Ubuntu platform configuration"

# ============================================================================
# Binary Name Fixes — Debian renames some tools
# ============================================================================

# @description  bat → batcat on Debian/Ubuntu
if ! has "bat" && has "batcat"; then
  alias bat="batcat"
fi

# @description  fd → fdfind on Debian/Ubuntu
if ! has "fd" && has "fdfind"; then
  alias fd="fdfind"
fi

# ============================================================================
# APT Package Management Aliases
# ============================================================================

# @description  Install packages
alias apti="sudo apt install -y"

# @description  Remove packages with config
alias aptr="sudo apt remove --purge -y"

# @description  Update package lists
alias aptu="sudo apt update"

# @description  Upgrade all packages
alias aptup="sudo apt update && sudo apt upgrade -y"

# @description  Full system upgrade (dist-upgrade)
alias aptfull="sudo apt update && sudo apt full-upgrade -y"

# @description  Search packages
alias apts="apt search"

# @description  Show package info
alias aptinfo="apt show"

# @description  List installed packages
alias aptls="apt list --installed"

# @description  Clean apt cache
alias aptclean="sudo apt autoremove -y && sudo apt autoclean"

# @description  Show package dependencies
alias aptdeps="apt-cache depends"

# @description  Show reverse dependencies
alias aptrdeps="apt-cache rdepends"

# ============================================================================
# Functions
# ============================================================================

# @description  Interactive apt package search and install via FZF
# @return       void
function apt-install() {
  if ! has "fzf"; then
    apt search "$@"
    return
  fi

  local pkg
  pkg=$(apt list 2>/dev/null | grep -v "Listing" | cut -d/ -f1 | \
    fzf --multi --header='📦 Select packages to install' \
        --preview='apt show {1} 2>/dev/null' \
        --preview-window='right:50%:wrap')

  [[ -n "$pkg" ]] && echo "$pkg" | xargs sudo apt install -y
}

# @description  Show recently installed packages
# @param  $1    integer  (optional) Number of entries (default: 20)
# @return       void
function apt-recent() {
  local count="${1:-20}"
  grep " install " /var/log/dpkg.log 2>/dev/null | tail -"$count" || \
    grep " install " /var/log/apt/history.log 2>/dev/null | tail -"$count"
}

# @description  List packages that can be upgraded
# @return       void
function apt-upgradable() {
  apt list --upgradable 2>/dev/null
}

# @description  Show which package provides a command
# @param  $1    string  Command name
# @return       void
function apt-which() {
  local cmd="${1:?Usage: apt-which <command>}"
  dpkg -S "$(which "$cmd" 2>/dev/null)" 2>/dev/null || \
    apt-file search "bin/${cmd}" 2>/dev/null || \
    log_warn "Package not found for: %s (try: sudo apt install apt-file && sudo apt-file update)" "$cmd"
}

# @description  Check for broken packages and fix
# @return       void
function apt-fix() {
  log_info "Checking for broken packages..."
  sudo apt --fix-broken install
  sudo dpkg --configure -a
  log_info "Package system check complete"
}

log_debug "Debian/Ubuntu platform configured"
