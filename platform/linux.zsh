#!/usr/bin/env zsh
# ============================================================================
# @file        platform/linux.zsh
# @description Generic Linux configuration. Sets up Linux-specific aliases,
#              systemd integration, clipboard handling, and common utilities
#              shared across all Linux distributions.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_PLATFORM_LINUX_LOADED:-}" ]] && return 0
readonly _ZSH_PLATFORM_LINUX_LOADED=1

[[ "$ZSH_PLATFORM" == "linux" ]] || return 0

log_debug "Loading Linux platform configuration"

# ============================================================================
# Clipboard — Detect and configure clipboard tool
# ============================================================================

if has "wl-copy"; then
  # -- Wayland
  alias pbcopy="wl-copy"
  alias pbpaste="wl-paste"
elif has "xclip"; then
  # -- X11 / Xclip
  alias pbcopy="xclip -selection clipboard"
  alias pbpaste="xclip -selection clipboard -o"
elif has "xsel"; then
  # -- X11 / Xsel
  alias pbcopy="xsel --clipboard --input"
  alias pbpaste="xsel --clipboard --output"
fi

# ============================================================================
# Open Command — xdg-open as macOS-like "open"
# ============================================================================

if has "xdg-open"; then
  alias open="xdg-open"

  # @description  Open file manager in current directory
  # @param  $1    string  (optional) Path to open
  # @return       void
  function o() {
    xdg-open "${1:-.}" &>/dev/null &!
  }
fi

# ============================================================================
# Systemd — Service management shortcuts
# ============================================================================

if has "systemctl"; then
  # @description  Service management aliases
  alias sc="sudo systemctl"
  alias scu="systemctl --user"
  alias scs="sudo systemctl status"
  alias scr="sudo systemctl restart"
  alias sce="sudo systemctl enable"
  alias scd="sudo systemctl disable"
  alias scstart="sudo systemctl start"
  alias scstop="sudo systemctl stop"

  # @description  Journal / logs
  alias journal="journalctl -xe"
  alias journal-f="journalctl -f"
  alias journal-boot="journalctl -b"

  # @description  Interactive service manager via FZF
  # @return       void
  function sc-manage() {
    if ! has "fzf"; then
      systemctl list-units --type=service
      return
    fi

    local unit
    unit=$(systemctl list-units --type=service --no-pager --no-legend | \
      fzf --header='⚙️  Select systemd service' \
          --preview='systemctl status {1} 2>/dev/null' \
          --preview-window='right:60%:wrap' | \
      awk '{print $1}')

    if [[ -n "$unit" ]]; then
      printf "\n  Service: %s\n" "$unit"
      printf "  [s]tatus | [r]estart | s[t]op | [e]nable | [d]isable | [l]ogs? "
      read -rk1 action
      echo
      case "${action:l}" in
        s) sudo systemctl status "$unit" ;;
        r) sudo systemctl restart "$unit" && log_info "Restarted: %s" "$unit" ;;
        t) sudo systemctl stop "$unit" && log_info "Stopped: %s" "$unit" ;;
        e) sudo systemctl enable "$unit" && log_info "Enabled: %s" "$unit" ;;
        d) sudo systemctl disable "$unit" && log_info "Disabled: %s" "$unit" ;;
        l) journalctl -u "$unit" -f ;;
        *) log_info "Cancelled" ;;
      esac
    fi
  }

  # @description  Show failed systemd units
  # @return       void
  function sc-failed() {
    printf "\n  ❌ Failed Systemd Units\n\n"
    systemctl --failed --no-pager
    printf "\n"
  fi
fi

# ============================================================================
# Linux System Aliases
# ============================================================================

# @description  Free memory (human-readable)
alias free="free -h"

# @description  DNS flush (systemd-resolved)
if has "resolvectl"; then
  alias flushdns="sudo resolvectl flush-caches && log_info 'DNS cache flushed'"
elif has "systemd-resolve"; then
  alias flushdns="sudo systemd-resolve --flush-caches && log_info 'DNS cache flushed'"
fi

# @description  Show distro info
alias distro="cat /etc/os-release"

# @description  Hardware info
alias lscpu="lscpu"
alias lsmem="lsmem 2>/dev/null || free -h"
alias lsblk="lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,UUID"

# ============================================================================
# Linux Functions
# ============================================================================

# @description  Show Linux system information summary
# @return       void
function linuxinfo() {
  printf "\n  🐧 Linux System Info\n"
  printf "  ─────────────────────────────────\n"

  if [[ -f /etc/os-release ]]; then
    source /etc/os-release 2>/dev/null
    printf "  Distro:    %s %s\n" "${PRETTY_NAME:-$NAME}" "${VERSION_ID:-}"
  fi

  printf "  Kernel:    %s\n" "$(uname -r)"
  printf "  Arch:      %s\n" "$(uname -m)"
  printf "  Hostname:  %s\n" "$(hostname)"
  printf "  CPU:       %s (%s cores)\n" \
    "$(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs)" \
    "$(nproc 2>/dev/null || echo 'N/A')"
  printf "  Memory:    %s\n" "$(free -h | awk '/^Mem:/{print $3 " / " $2}')"
  printf "  Disk (/):  %s\n" "$(df -h / | awk 'NR==2{print $3 " / " $2 " (" $5 " used)"}')"
  printf "  Uptime:    %s\n" "$(uptime -p 2>/dev/null || uptime)"
  printf "  ─────────────────────────────────\n\n"
}

# @description  Show active network interfaces with IP addresses
# @return       void
function netinfo() {
  printf "\n  🌐 Network Interfaces\n\n"
  ip -4 -o addr show scope global 2>/dev/null | \
    awk '{printf "  %-12s %s\n", $2, $4}' || \
    ifconfig 2>/dev/null | grep -E 'inet |Link' | awk '{print "  "$0}'
  printf "\n"
}

# @description  Notify via desktop notification (libnotify)
# @param  $1    string  Title
# @param  $2    string  Message body
# @return       void
function notify() {
  local title="${1:?Usage: notify <title> <message>}"
  local message="${2:-}"

  if has "notify-send"; then
    notify-send "$title" "$message"
  else
    log_warn "notify-send not available (install libnotify)"
  fi
}

log_debug "Linux platform configured"
