#!/usr/bin/env zsh
# ============================================================================
# @file        lib/platform-detect.zsh
# @description Platform, distribution, and terminal detection library.
#              Provides reliable identification of the runtime environment
#              including OS, Linux distribution, WSL status, architecture,
#              terminal emulator, and package manager.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @exports     ZSH_PLATFORM        - "darwin" | "linux" | "wsl" | "freebsd" | "unknown"
#              ZSH_DISTRO          - "arch" | "debian" | "ubuntu" | "fedora" | "nixos" | ...
#              ZSH_ARCH            - "x86_64" | "arm64" | "aarch64" | ...
#              ZSH_PKG_MANAGER     - "brew" | "apt" | "dnf" | "pacman" | "nix" | ...
#              ZSH_TERMINAL        - "ghostty" | "wezterm" | "kitty" | "alacritty" | ...
#              ZSH_IS_SSH          - 0 | 1
#              ZSH_IS_CONTAINER    - 0 | 1
#              ZSH_IS_ROOT         - 0 | 1
#
# @depends     lib/logging.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_LIB_PLATFORM_DETECT_LOADED:-}" ]] && return 0
readonly _ZSH_LIB_PLATFORM_DETECT_LOADED=1

# ── Exported platform variables ─────────────────────────────────────────────
typeset -g ZSH_PLATFORM="unknown"
typeset -g ZSH_DISTRO="unknown"
typeset -g ZSH_ARCH="unknown"
typeset -g ZSH_PKG_MANAGER="unknown"
typeset -g ZSH_TERMINAL="unknown"
typeset -gi ZSH_IS_SSH=0
typeset -gi ZSH_IS_CONTAINER=0
typeset -gi ZSH_IS_ROOT=0

# ============================================================================
# @description  Detect the operating system platform
# @return       Sets ZSH_PLATFORM global variable
# ============================================================================
function _detect_platform() {
  local kernel
  kernel="$(uname -s 2>/dev/null)"

  case "${kernel:l}" in
    darwin)
      ZSH_PLATFORM="darwin"
      ;;
    linux)
      # -- Check for WSL before generic Linux
      if [[ -f /proc/version ]] && grep -qi 'microsoft\|wsl' /proc/version 2>/dev/null; then
        ZSH_PLATFORM="wsl"
      else
        ZSH_PLATFORM="linux"
      fi
      ;;
    freebsd)
      ZSH_PLATFORM="freebsd"
      ;;
    *)
      ZSH_PLATFORM="unknown"
      ;;
  esac

  log_debug "Platform detected: %s" "$ZSH_PLATFORM"
}

# ============================================================================
# @description  Detect the Linux distribution (or macOS version)
# @return       Sets ZSH_DISTRO global variable
# ============================================================================
function _detect_distro() {
  case "$ZSH_PLATFORM" in
    darwin)
      ZSH_DISTRO="macos"
      ;;
    linux|wsl)
      if [[ -f /etc/os-release ]]; then
        # -- Parse ID from os-release (most reliable method)
        local id
        id=$(source /etc/os-release 2>/dev/null && echo "${ID:-unknown}")
        ZSH_DISTRO="${id:l}"
      elif command -v lsb_release &>/dev/null; then
        ZSH_DISTRO="$(lsb_release -si 2>/dev/null | tr '[:upper:]' '[:lower:]')"
      elif [[ -f /etc/arch-release ]]; then
        ZSH_DISTRO="arch"
      elif [[ -f /etc/debian_version ]]; then
        ZSH_DISTRO="debian"
      elif [[ -f /etc/fedora-release ]]; then
        ZSH_DISTRO="fedora"
      elif [[ -f /etc/redhat-release ]]; then
        ZSH_DISTRO="rhel"
      else
        ZSH_DISTRO="unknown"
      fi
      ;;
    *)
      ZSH_DISTRO="unknown"
      ;;
  esac

  log_debug "Distribution detected: %s" "$ZSH_DISTRO"
}

# ============================================================================
# @description  Detect CPU architecture
# @return       Sets ZSH_ARCH global variable
# ============================================================================
function _detect_arch() {
  ZSH_ARCH="$(uname -m 2>/dev/null || echo 'unknown')"

  # -- Normalize common variants
  case "$ZSH_ARCH" in
    aarch64) ZSH_ARCH="arm64" ;;
    x86_64)  ZSH_ARCH="x86_64" ;;
  esac

  log_debug "Architecture detected: %s" "$ZSH_ARCH"
}

# ============================================================================
# @description  Detect the primary package manager available
# @return       Sets ZSH_PKG_MANAGER global variable
# ============================================================================
function _detect_pkg_manager() {
  if command -v brew &>/dev/null; then
    ZSH_PKG_MANAGER="brew"
  elif command -v nix-env &>/dev/null; then
    ZSH_PKG_MANAGER="nix"
  elif command -v pacman &>/dev/null; then
    ZSH_PKG_MANAGER="pacman"
  elif command -v apt &>/dev/null; then
    ZSH_PKG_MANAGER="apt"
  elif command -v dnf &>/dev/null; then
    ZSH_PKG_MANAGER="dnf"
  elif command -v zypper &>/dev/null; then
    ZSH_PKG_MANAGER="zypper"
  elif command -v apk &>/dev/null; then
    ZSH_PKG_MANAGER="apk"
  elif command -v xbps-install &>/dev/null; then
    ZSH_PKG_MANAGER="xbps"
  else
    ZSH_PKG_MANAGER="unknown"
  fi

  log_debug "Package manager detected: %s" "$ZSH_PKG_MANAGER"
}

# ============================================================================
# @description  Detect the current terminal emulator
# @return       Sets ZSH_TERMINAL global variable
# ============================================================================
function _detect_terminal() {
  # -- Priority: specific env vars → TERM_PROGRAM → fallback detection

  if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
    ZSH_TERMINAL="ghostty"
  elif [[ -n "${WEZTERM_EXECUTABLE:-}" ]] || [[ "${TERM_PROGRAM:-}" == "WezTerm" ]]; then
    ZSH_TERMINAL="wezterm"
  elif [[ "${TERM:-}" == "xterm-kitty" ]] || [[ -n "${KITTY_PID:-}" ]]; then
    ZSH_TERMINAL="kitty"
  elif [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then
    ZSH_TERMINAL="iterm"
  elif [[ -n "${ALACRITTY_SOCKET:-}" ]] || [[ "${TERM_PROGRAM:-}" == "Alacritty" ]]; then
    ZSH_TERMINAL="alacritty"
  elif [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then
    ZSH_TERMINAL="apple-terminal"
  elif [[ "${TERM_PROGRAM:-}" == "vscode" ]] || [[ -n "${VSCODE_INJECTION:-}" ]]; then
    ZSH_TERMINAL="vscode"
  elif [[ -n "${WT_SESSION:-}" ]]; then
    ZSH_TERMINAL="windows-terminal"
  elif [[ "${TERM_PROGRAM:-}" == "tmux" ]] || [[ -n "${TMUX:-}" ]]; then
    ZSH_TERMINAL="tmux"
  elif [[ -n "${TERM_PROGRAM:-}" ]]; then
    ZSH_TERMINAL="${TERM_PROGRAM:l}"
  else
    ZSH_TERMINAL="unknown"
  fi

  log_debug "Terminal detected: %s" "$ZSH_TERMINAL"
}

# ============================================================================
# @description  Detect runtime context (SSH, container, root)
# @return       Sets ZSH_IS_SSH, ZSH_IS_CONTAINER, ZSH_IS_ROOT
# ============================================================================
function _detect_context() {
  # -- SSH session detection
  if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]] || [[ -n "${SSH_TTY:-}" ]]; then
    ZSH_IS_SSH=1
  fi

  # -- Container detection
  if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]] || \
     grep -q 'docker\|lxc\|containerd\|podman' /proc/1/cgroup 2>/dev/null; then
    ZSH_IS_CONTAINER=1
  fi

  # -- Root user detection
  if (( EUID == 0 )); then
    ZSH_IS_ROOT=1
  fi

  log_debug "Context — SSH:%d Container:%d Root:%d" \
    "$ZSH_IS_SSH" "$ZSH_IS_CONTAINER" "$ZSH_IS_ROOT"
}

# ============================================================================
# @description  Run all detection functions. Called automatically on source.
# @return       void
# ============================================================================
function detect_platform_all() {
  _detect_platform
  _detect_distro
  _detect_arch
  _detect_pkg_manager
  _detect_terminal
  _detect_context
}

# ============================================================================
# @description  Print a summary of the detected platform environment
# @return       void (prints to stdout)
# ============================================================================
function platform_summary() {
  local separator="──────────────────────────────────────"
  printf "\n%s\n" "$separator"
  printf "  🖥  Platform:     %s\n" "$ZSH_PLATFORM"
  printf "  🐧 Distribution: %s\n" "$ZSH_DISTRO"
  printf "  ⚙️  Architecture: %s\n" "$ZSH_ARCH"
  printf "  📦 Pkg Manager:  %s\n" "$ZSH_PKG_MANAGER"
  printf "  💻 Terminal:     %s\n" "$ZSH_TERMINAL"
  printf "  🔒 SSH:          %s\n" "$( (( ZSH_IS_SSH )) && echo 'yes' || echo 'no')"
  printf "  📦 Container:    %s\n" "$( (( ZSH_IS_CONTAINER )) && echo 'yes' || echo 'no')"
  printf "  👑 Root:         %s\n" "$( (( ZSH_IS_ROOT )) && echo 'yes' || echo 'no')"
  printf "%s\n\n" "$separator"
}

# ── Auto-detect on source ───────────────────────────────────────────────────
detect_platform_all
