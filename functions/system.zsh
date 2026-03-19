#!/usr/bin/env zsh
# ============================================================================
# @file        functions/system.zsh
# @description System information and management functions. Provides
#              cross-platform utilities for process management, resource
#              monitoring, and system diagnostics.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_SYSTEM_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_SYSTEM_LOADED=1

# ============================================================================
# Process Management
# ============================================================================

# @description  Find processes by name (case-insensitive)
# @param  $1    string  Process name pattern
# @return       void
function psfind() {
  local pattern="${1:?Usage: psfind <pattern>}"
  ps aux | head -1
  ps aux | grep -iv "grep" | grep -i "$pattern"
}

# @description  Kill processes by name (with confirmation)
# @param  $1    string  Process name pattern
# @param  $2    integer (optional) Signal number (default: 15/TERM)
# @return       void
function pskill() {
  local pattern="${1:?Usage: pskill <pattern> [signal]}"
  local signal="${2:-15}"

  local pids
  pids=$(pgrep -if "$pattern" 2>/dev/null)

  if [[ -z "$pids" ]]; then
    log_info "No processes matching: %s" "$pattern"
    return 0
  fi

  printf "  Processes matching '%s':\n\n" "$pattern"
  ps -p "$(echo "$pids" | tr '\n' ',')" -o pid,user,%cpu,%mem,comm 2>/dev/null

  if confirm "\nKill these processes (signal ${signal})?"; then
    echo "$pids" | xargs kill -"$signal"
    log_info "Sent signal %s to matching processes" "$signal"
  fi
}

# @description  Show the top resource-consuming processes
# @param  $1    string  (optional) Sort by: "cpu" or "mem" (default: "cpu")
# @param  $2    integer (optional) Number of results (default: 15)
# @return       void
function procs() {
  local sort_by="${1:-cpu}"
  local count="${2:-15}"

  case "$sort_by" in
    cpu)
      printf "\n  🔥 Top %d Processes by CPU\n\n" "$count"
      ps aux --sort=-%cpu 2>/dev/null | head -$(( count + 1 )) || \
        ps aux -r 2>/dev/null | head -$(( count + 1 ))
      ;;
    mem)
      printf "\n  💾 Top %d Processes by Memory\n\n" "$count"
      ps aux --sort=-%mem 2>/dev/null | head -$(( count + 1 )) || \
        ps aux -m 2>/dev/null | head -$(( count + 1 ))
      ;;
    *)
      log_error "Sort by 'cpu' or 'mem'"
      return 1
      ;;
  esac
  printf "\n"
}

# ============================================================================
# System Information
# ============================================================================

# @description  Show a comprehensive system overview
# @return       void
function overview() {
  printf "\n  🖥  System Overview\n"
  printf "  ═══════════════════════════════════\n\n"

  # -- OS Info
  printf "  ── OS & Kernel ──\n"
  if has "fastfetch"; then
    fastfetch --structure OS:Kernel:Uptime --logo none 2>/dev/null
  else
    printf "  OS:      %s\n" "$(uname -srm)"
    printf "  Uptime:  %s\n" "$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1,$2}')"
  fi

  # -- Shell & Terminal
  printf "\n  ── Shell & Terminal ──\n"
  printf "  Shell:     %s (%s)\n" "$(basename "$SHELL")" "$ZSH_VERSION"
  printf "  Terminal:  %s\n" "$ZSH_TERMINAL"
  printf "  Platform:  %s (%s)\n" "$ZSH_PLATFORM" "$ZSH_DISTRO"

  # -- Resource usage
  if has "btop" || has "top"; then
    printf "\n  ── Resources ──\n"
    if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
      printf "  CPU:     %s cores\n" "$(sysctl -n hw.ncpu)"
      printf "  Memory:  %s GB\n" "$(( $(sysctl -n hw.memsize) / 1073741824 ))"
    else
      printf "  CPU:     %s cores\n" "$(nproc 2>/dev/null || echo 'N/A')"
      printf "  Memory:  %s\n" "$(free -h 2>/dev/null | awk '/^Mem:/{print $3 "/" $2}')"
    fi
  fi

  printf "\n  ═══════════════════════════════════\n\n"
}

# ============================================================================
# PATH Management
# ============================================================================

# @description  Show PATH entries, one per line, with existence check
# @return       void
function path_audit() {
  printf "\n  📁 PATH Audit\n\n"
  local entry
  local i=0
  while IFS=: read -rd: entry || [[ -n "$entry" ]]; do
    (( i++ ))
    if [[ -d "$entry" ]]; then
      printf "  %2d ✅ %s\n" "$i" "$entry"
    else
      printf "  %2d ❌ %s (missing)\n" "$i" "$entry"
    fi
  done <<< "$PATH:"
  printf "\n"
}

# @description  Show duplicate entries in PATH
# @return       void
function path_dupes() {
  printf "\n  🔄 PATH Duplicates\n\n"
  echo "$PATH" | tr ':' '\n' | sort | uniq -d | while read -r d; do
    printf "  ⚠️  %s\n" "$d"
  done || printf "  ✅ No duplicates found\n"
  printf "\n"
}

# ============================================================================
# Cleanup & Maintenance
# ============================================================================

# @description  Clean common cache directories to free disk space
# @return       void
function cache_clean() {
  printf "\n  🧹 Cache Cleanup\n\n"

  local -A caches=()
  caches[ZSH]="${ZSH_CACHE_DIR}"
  caches[pip]="${XDG_CACHE_HOME}/pip"
  caches[npm]="${XDG_CACHE_HOME}/npm"
  caches[cargo]="${CARGO_HOME:-${XDG_DATA_HOME}/cargo}/registry"
  caches[go]="${GOMODCACHE:-${XDG_CACHE_HOME}/go/mod}"
  caches[mise]="${MISE_CACHE_DIR:-${XDG_CACHE_HOME}/mise}"

  local name path size
  for name in "${(@k)caches}"; do
    path="${caches[$name]}"
    if [[ -d "$path" ]]; then
      if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
        size=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
      else
        size=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
      fi
      printf "  %-12s %8s  %s\n" "$name" "$size" "$path"
    fi
  done

  if confirm "\nClean these caches?"; then
    for name in "${(@k)caches}"; do
      path="${caches[$name]}"
      if [[ -d "$path" ]]; then
        rm -rf "${path:?}"/* 2>/dev/null
        printf "  ✅ Cleaned: %s\n" "$name"
      fi
    done
  fi
  printf "\n"
}

# @description  Show shell startup environment summary (for debugging)
# @return       void
function env_summary() {
  printf "\n  🔧 Environment Summary\n"
  printf "  ─────────────────────────────────\n"
  printf "  ZDOTDIR:   %s\n" "$ZDOTDIR"
  printf "  EDITOR:    %s\n" "$EDITOR"
  printf "  PAGER:     %s\n" "$PAGER"
  printf "  SHELL:     %s\n" "$SHELL"
  printf "  TERM:      %s\n" "$TERM"
  printf "  LANG:      %s\n" "$LANG"
  printf "  HOME:      %s\n" "$HOME"
  printf "  USER:      %s\n" "$USER"
  printf "  PKG_MGR:   %s\n" "$ZSH_PKG_MANAGER"
  printf "  ─────────────────────────────────\n\n"
}

log_debug "System functions loaded"
