#!/usr/bin/env zsh
# ============================================================================
# @file        core/01-platform.zsh
# @description Platform-specific initialization and PATH configuration.
#              Sources the appropriate platform module (darwin, linux, wsl)
#              and configures platform-dependent environment variables.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_CORE_PLATFORM_LOADED:-}" ]] && return 0
readonly _ZSH_CORE_PLATFORM_LOADED=1

log_section "Platform Configuration"

# ============================================================================
# PATH Construction — Unified, platform-aware
# ============================================================================

# @description Build PATH in priority order (first match wins)
# @type array → converted to PATH string
typeset -gU path  # -U ensures unique entries (deduplication)

# -- User-local binaries (highest priority)
path=(
  "${XDG_BIN_HOME}"                           # ~/.local/bin
  "${HOME}/bin"                                # ~/bin (legacy compat)
  "${CARGO_HOME}/bin"                          # Rust binaries
  "${GOPATH}/bin"                              # Go binaries
  "${GEM_HOME}/bin"                            # Ruby binaries
  $path                                        # System PATH
)

# ============================================================================
# Platform-Specific PATH & Environment
# ============================================================================

case "$ZSH_PLATFORM" in
  darwin)
    log_step "Configuring macOS environment"

    # -- Homebrew (Apple Silicon vs Intel)
    if [[ -d "/opt/homebrew" ]]; then
      # Apple Silicon (M1+)
      export HOMEBREW_PREFIX="/opt/homebrew"
    elif [[ -d "/usr/local/Homebrew" ]]; then
      # Intel Mac
      export HOMEBREW_PREFIX="/usr/local"
    fi

    if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
      export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"
      export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
      path=(
        "${HOMEBREW_PREFIX}/bin"
        "${HOMEBREW_PREFIX}/sbin"
        "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
        "${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin"
        "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
        "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
        $path
      )
      export MANPATH="${HOMEBREW_PREFIX}/share/man:${MANPATH:-}"
      export INFOPATH="${HOMEBREW_PREFIX}/share/info:${INFOPATH:-}"

      # -- Homebrew settings
      export HOMEBREW_NO_ANALYTICS=1
      export HOMEBREW_NO_AUTO_UPDATE=1
      export HOMEBREW_AUTOREMOVE=1
    fi
    ;;

  linux)
    log_step "Configuring Linux environment"

    # -- Linuxbrew (if installed)
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
      export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
      path=(
        "${HOMEBREW_PREFIX}/bin"
        "${HOMEBREW_PREFIX}/sbin"
        $path
      )
    fi

    # -- Snap (if available)
    [[ -d "/snap/bin" ]] && path=($path "/snap/bin")

    # -- Flatpak exports
    [[ -d "/var/lib/flatpak/exports/bin" ]] && path=($path "/var/lib/flatpak/exports/bin")
    ;;

  wsl)
    log_step "Configuring WSL environment"

    # -- Windows interop settings
    export BROWSER="wslview"
    export DONT_PROMPT_WSL_INSTALL=1

    # -- Access to Windows executables (optional, can slow PATH)
    # Uncomment if you need Windows tools from WSL:
    # [[ -d "/mnt/c/Windows/System32" ]] && path=($path "/mnt/c/Windows/System32")

    # -- Linuxbrew on WSL (if installed)
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
      export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
      path=(
        "${HOMEBREW_PREFIX}/bin"
        "${HOMEBREW_PREFIX}/sbin"
        $path
      )
    fi
    ;;
esac

# ============================================================================
# Nix Package Manager (cross-platform)
# ============================================================================

if [[ -d "/nix" ]]; then
  # -- Single-user Nix
  [[ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]] && \
    source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
  # -- Multi-user Nix
  [[ -f "/etc/profiles/per-user/${USER}/etc/profile.d/nix.sh" ]] && \
    source "/etc/profiles/per-user/${USER}/etc/profile.d/nix.sh"
  # -- Nix darwin (nix-darwin)
  [[ -f "/run/current-system/sw/etc/profile.d/nix.sh" ]] && \
    source "/run/current-system/sw/etc/profile.d/nix.sh"
fi

# ============================================================================
# Source Platform-Specific Module
# ============================================================================

local _platform_file="${ZDOTDIR}/platform/${ZSH_PLATFORM}.zsh"
if [[ -f "$_platform_file" ]]; then
  log_step "Loading platform module: ${ZSH_PLATFORM}.zsh"
  source "$_platform_file"
fi

# -- Distro-specific (Linux/WSL only)
if [[ "$ZSH_PLATFORM" == "linux" || "$ZSH_PLATFORM" == "wsl" ]]; then
  local _distro_file="${ZDOTDIR}/platform/${ZSH_DISTRO}.zsh"
  if [[ -f "$_distro_file" ]]; then
    log_step "Loading distro module: ${ZSH_DISTRO}.zsh"
    source "$_distro_file"
  fi
fi

# ============================================================================
# Universal Environment Variables
# ============================================================================

# -- Default editor (prefer nvim → vim → vi)
if has "nvim"; then
  export EDITOR="nvim"
  export VISUAL="nvim"
elif has "vim"; then
  export EDITOR="vim"
  export VISUAL="vim"
else
  export EDITOR="vi"
  export VISUAL="vi"
fi

# -- Pager configuration
if has "most"; then
  export PAGER="most"
elif has "bat"; then
  export PAGER="bat --plain"
else
  export PAGER="less"
fi
export MANPAGER="${PAGER}"

# -- Less configuration
export LESS="-R -F -X -i -M -S --tabs=2"
export LESSCHARSET="utf-8"

# -- Default language / locale
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# -- Color support
export CLICOLOR=1
export COLORTERM="${COLORTERM:-truecolor}"

log_debug "Platform configuration complete (platform=%s, distro=%s)" \
  "$ZSH_PLATFORM" "$ZSH_DISTRO"
