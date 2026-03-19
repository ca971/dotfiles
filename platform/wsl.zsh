#!/usr/bin/env zsh
# ============================================================================
# @file        platform/wsl.zsh
# @description Windows Subsystem for Linux (WSL) configuration. Handles
#              Windows interop, path translation, browser delegation,
#              clipboard bridging, and WSL-specific optimizations.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_PLATFORM_WSL_LOADED:-}" ]] && return 0
readonly _ZSH_PLATFORM_WSL_LOADED=1

[[ "$ZSH_PLATFORM" == "wsl" ]] || return 0

log_debug "Loading WSL platform configuration"

# ============================================================================
# Environment Variables
# ============================================================================

# @description  Suppress WSL install prompts for Windows tools
export DONT_PROMPT_WSL_INSTALL=1

# @description  Set browser to wslview (opens URLs in Windows default browser)
if has "wslview"; then
  export BROWSER="wslview"
fi

# @description  WSL distribution name
export WSL_DISTRO_NAME="${WSL_DISTRO_NAME:-$(cat /proc/version 2>/dev/null | grep -oP 'Microsoft|WSL' | head -1)}"

# ============================================================================
# Windows Interop — Path Translation
# ============================================================================

# @description  Detect the Windows user home directory
typeset -g WIN_HOME=""
if [[ -d "/mnt/c/Users" ]]; then
  local _win_user
  _win_user=$(cmd.exe /C "echo %USERNAME%" 2>/dev/null | tr -d '\r\n' || echo "")
  if [[ -n "$_win_user" ]] && [[ -d "/mnt/c/Users/${_win_user}" ]]; then
    WIN_HOME="/mnt/c/Users/${_win_user}"
  fi
  unset _win_user
fi

# @description  Convert a WSL path to a Windows path
# @param  $1    string  WSL/Linux path
# @return       Windows path (printed to stdout)
function wslpath_win() {
  if has "wslpath"; then
    wslpath -w "${1:-$PWD}"
  else
    local p="${1:-$PWD}"
    p="${p/#\/mnt\//}"
    local drive="${p%%/*}"
    p="${p#*/}"
    printf "%s:\\%s" "${drive:u}" "${p//\//\\}"
  fi
}

# @description  Convert a Windows path to a WSL path
# @param  $1    string  Windows path
# @return       WSL path (printed to stdout)
function wslpath_linux() {
  if has "wslpath"; then
    wslpath -u "$1"
  else
    local p="$1"
    p="${p//\\//}"
    local drive="${p%%:*}"
    p="${p#*:/}"
    printf "/mnt/%s/%s" "${drive:l}" "$p"
  fi
}

# ============================================================================
# Clipboard — Bridge to Windows clipboard
# ============================================================================

# @description  Copy to Windows clipboard
alias pbcopy="clip.exe"

# @description  Paste from Windows clipboard
alias pbpaste="powershell.exe -NoProfile -Command Get-Clipboard | tr -d '\r'"

# @description  Open a file or URL in Windows
# @param  $1    string  Path or URL to open
# @return       void
function open() {
  local target="${1:-.}"

  if [[ "$target" =~ ^https?:// ]]; then
    # -- URL: open in Windows browser
    cmd.exe /C "start ${target}" &>/dev/null
  elif [[ -e "$target" ]]; then
    # -- File/directory: convert path and open
    local win_path
    win_path=$(wslpath_win "$(realpath "$target")")
    explorer.exe "$win_path" &>/dev/null
  else
    explorer.exe "$target" &>/dev/null
  fi
}

# @description  Open Windows Explorer in the current directory
# @param  $1    string  (optional) Path to open
# @return       void
function o() {
  local target="${1:-.}"
  explorer.exe "$(wslpath_win "$(realpath "$target")")" &>/dev/null
}

# ============================================================================
# WSL-Specific Aliases
# ============================================================================

# @description  Shutdown WSL (from inside WSL)
alias wsl-shutdown="wsl.exe --shutdown"

# @description  List WSL distributions
alias wsl-list="wsl.exe --list --verbose"

# @description  Quick access to Windows home
if [[ -n "$WIN_HOME" ]]; then
  alias cdwin="cd '$WIN_HOME'"
  alias cdwindesk="cd '${WIN_HOME}/Desktop'"
  alias cdwindown="cd '${WIN_HOME}/Downloads'"
fi

# ============================================================================
# WSL Performance Optimizations
# ============================================================================

# @description  Reduce PATH pollution from Windows.
#               Windows directories in PATH slow down command resolution
#               significantly in WSL. Keep only essential ones.
function _wsl_clean_path() {
  local -a clean_path=()
  local entry
  for entry in "${path[@]}"; do
    case "$entry" in
      /mnt/c/Windows/System32)
        clean_path+=("$entry")  # Keep for basic interop
        ;;
      /mnt/c/Windows)
        clean_path+=("$entry")
        ;;
      /mnt/*)
        # -- Skip other Windows paths (slow)
        ;;
      *)
        clean_path+=("$entry")
        ;;
    esac
  done
  path=("${clean_path[@]}")
}

# -- Apply PATH cleaning (opt-in: set WSL_CLEAN_PATH=1)
if [[ "${WSL_CLEAN_PATH:-1}" -eq 1 ]]; then
  _wsl_clean_path
fi

# ============================================================================
# WSL Functions
# ============================================================================

# @description  Show WSL environment information
# @return       void
function wslinfo() {
  printf "\n  🪟 WSL Environment\n"
  printf "  ─────────────────────────────────\n"
  printf "  Distro:    %s\n" "$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
  printf "  Kernel:    %s\n" "$(uname -r)"
  printf "  WSL ver:   %s\n" "$(uname -r | grep -oP 'WSL\d?' || echo 'WSL2')"
  printf "  Win Home:  %s\n" "${WIN_HOME:-N/A}"
  printf "  Interop:   %s\n" "$(cat /proc/sys/fs/binaryFmt_misc/WSLInterop 2>/dev/null && echo 'enabled' || echo 'enabled')"
  printf "  ─────────────────────────────────\n\n"
}

# @description  Run a Windows command from WSL
# @param  $@    Command and arguments
# @return       void
function winrun() {
  cmd.exe /C "$@" 2>/dev/null | tr -d '\r'
}

# @description  Open Windows Terminal settings
function wt-settings() {
  if [[ -n "$WIN_HOME" ]]; then
    local settings="${WIN_HOME}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
    if [[ -f "$settings" ]]; then
      "${EDITOR:-nvim}" "$settings"
    else
      log_warn "Windows Terminal settings not found"
    fi
  fi
}

log_debug "WSL platform configured"
