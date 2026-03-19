#!/usr/bin/env zsh
# ============================================================================
# @file        platform/fedora.zsh
# @description Fedora/RHEL specific configuration. Configures dnf package
#              manager aliases and Fedora-specific utilities.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_PLATFORM_FEDORA_LOADED:-}" ]] && return 0
readonly _ZSH_PLATFORM_FEDORA_LOADED=1

# -- Match Fedora-based distros
case "$ZSH_DISTRO" in
  fedora|rhel|centos|rocky|alma|nobara) ;;
  *) return 0 ;;
esac

log_debug "Loading Fedora platform configuration"

# ============================================================================
# DNF Package Management Aliases
# ============================================================================

# @description  Install packages
alias dnfi="sudo dnf install -y"

# @description  Remove packages
alias dnfr="sudo dnf remove -y"

# @description  Update all packages
alias dnfu="sudo dnf upgrade -y --refresh"

# @description  Search packages
alias dnfs="dnf search"

# @description  Show package info
alias dnfinfo="dnf info"

# @description  List installed packages
alias dnfls="dnf list installed"

# @description  Clean dnf cache
alias dnfclean="sudo dnf clean all && sudo dnf autoremove -y"

# @description  Show package dependencies
alias dnfdeps="dnf repoquery --requires"

# @description  Show what provides a file/command
alias dnfprovides="dnf provides"

# @description  History of dnf operations
alias dnfhist="dnf history"

# ============================================================================
# Functions
# ============================================================================

# @description  Interactive dnf package search and install via FZF
# @return       void
function dnf-install() {
  if ! has "fzf"; then
    dnf search "$@"
    return
  fi

  local pkg
  pkg=$(dnf list available 2>/dev/null | awk 'NR>1{print $1}' | cut -d. -f1 | sort -u | \
    fzf --multi --header='📦 Select packages to install' \
        --preview='dnf info {1} 2>/dev/null' \
        --preview-window='right:50%:wrap')

  [[ -n "$pkg" ]] && echo "$pkg" | xargs sudo dnf install -y
}

# @description  List packages that can be upgraded
# @return       void
function dnf-upgradable() {
  dnf check-update 2>/dev/null
}

# @description  Show recently installed packages
# @param  $1    integer  (optional) Number of entries (default: 20)
# @return       void
function dnf-recent() {
  local count="${1:-20}"
  dnf history list --reverse 2>/dev/null | tail -"$count"
}

# @description  Show which package provides a command
# @param  $1    string  Command name
# @return       void
function dnf-which() {
  local cmd="${1:?Usage: dnf-which <command>}"
  dnf provides "*bin/${cmd}" 2>/dev/null
}

# @description  Enable a COPR repository
# @param  $1    string  COPR repo (format: "user/repo")
# @return       void
function copr-enable() {
  local repo="${1:?Usage: copr-enable <user/repo>}"
  sudo dnf copr enable "$repo" -y
  log_info "COPR repo enabled: %s" "$repo"
}

log_debug "Fedora platform configured"
