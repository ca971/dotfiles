#!/usr/bin/env zsh
# ============================================================================
# @file        lib/logging.zsh
# @description Structured logging library with severity levels, timestamps,
#              and optional color output. Provides consistent log formatting
#              across the entire ZSH configuration.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @usage       source "${ZDOTDIR}/lib/logging.zsh"
#              log_info "Configuration loaded"
#              log_warn "Tool not found: %s" "eza"
#              log_error "Failed to initialize plugin"
#              log_debug "Variable X=%s" "$X"
#
# @depends     None (standalone library)
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_LIB_LOGGING_LOADED:-}" ]] && return 0
readonly _ZSH_LIB_LOGGING_LOADED=1

# ── Log level constants ─────────────────────────────────────────────────────
# @type integer
# @description Numeric severity levels for filtering log output
typeset -gri LOG_LEVEL_DEBUG=0
typeset -gri LOG_LEVEL_INFO=1
typeset -gri LOG_LEVEL_WARN=2
typeset -gri LOG_LEVEL_ERROR=3
typeset -gri LOG_LEVEL_FATAL=4
typeset -gri LOG_LEVEL_SILENT=5

# ── Current log level (configurable via ZSH_LOG_LEVEL env var) ───────────────
# @type integer
# @description Active minimum log level; messages below this are suppressed
typeset -gi ZSH_LOG_LEVEL="${ZSH_LOG_LEVEL:-$LOG_LEVEL_INFO}"

# ── Log file (optional, set ZSH_LOG_FILE to enable file logging) ─────────────
# @type string
# @description Path to log file; empty string disables file logging
typeset -g ZSH_LOG_FILE="${ZSH_LOG_FILE:-}"

# ── ANSI color codes ────────────────────────────────────────────────────────
# @type associative array
# @description Color codes for each log severity level
typeset -gA _LOG_COLORS=(
  [DEBUG]="\033[0;36m"    # Cyan
  [INFO]="\033[0;32m"     # Green
  [WARN]="\033[0;33m"     # Yellow
  [ERROR]="\033[0;31m"    # Red
  [FATAL]="\033[1;31m"    # Bold Red
  [RESET]="\033[0m"       # Reset
  [DIM]="\033[2m"         # Dim
  [BOLD]="\033[1m"        # Bold
)

# ── Detect color support ────────────────────────────────────────────────────
# @return boolean (0 = color supported, 1 = no color)
function _log_supports_color() {
  [[ -t 2 ]] && [[ -z "${NO_COLOR:-}" ]] && [[ "${TERM:-dumb}" != "dumb" ]]
}

# ── Core log function ───────────────────────────────────────────────────────
# @description  Internal log dispatcher. Formats and outputs log messages
#               to stderr and optionally to a log file.
# @param  $1    string   Log level name (DEBUG|INFO|WARN|ERROR|FATAL)
# @param  $2    integer  Numeric log level
# @param  $3    string   Format string (printf-compatible)
# @param  $@    mixed    Additional printf arguments
# @return void
function _log_message() {
  local level_name="$1"
  local level_num="$2"

  # -- FAST early exit
  (( level_num < ZSH_LOG_LEVEL )) && return 0

  shift 2
  local format_str="$1"
  shift

  local message
  if (( $# > 0 )); then
    message=$(printf "$format_str" "$@" 2>/dev/null) || message="$format_str $*"
  else
    message="$format_str"
  fi

  # -- Timestamp (multiple fallbacks for reliability)
  local timestamp=""

  # Method 1: ZSH strftime with EPOCHSECONDS (fastest, no fork)
  if (( ${+EPOCHSECONDS} )) && (( EPOCHSECONDS > 0 )); then
    zmodload -F zsh/datetime b:strftime 2>/dev/null
    strftime -s timestamp '%Y-%m-%dT%H:%M:%S%z' "$EPOCHSECONDS" 2>/dev/null
  fi

  # Method 2: ZSH prompt expansion (no fork)
  if [[ -z "$timestamp" ]]; then
    timestamp="${(%):-%D{%Y-%m-%dT%H:%M:%S%z}}"
    # -- Strip trailing } if present (ZSH version quirk)
    timestamp="${timestamp%\}}"
  fi

  # Method 3: date command (last resort, forks)
  if [[ -z "$timestamp" ]] || [[ "$timestamp" == *"invalid"* ]]; then
    timestamp=$(date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null)
  fi

  # -- Output to stderr
  if _log_supports_color; then
    local color="${_LOG_COLORS[$level_name]}"
    printf "%b%s%b [%b%-5s%b] %s\n" \
      "${_LOG_COLORS[DIM]}" "$timestamp" "${_LOG_COLORS[RESET]}" \
      "$color" "$level_name" "${_LOG_COLORS[RESET]}" \
      "$message" >&2
  else
    printf "[%s] [%s] %s\n" "$timestamp" "$level_name" "$message" >&2
  fi

  # -- File logging
  if [[ -n "${ZSH_LOG_FILE:-}" ]]; then
    printf "[%s] [%s] %s\n" "$timestamp" "$level_name" "$message" >> "$ZSH_LOG_FILE" 2>/dev/null
  fi
}

# ── Public API ───────────────────────────────────────────────────────────────

# @description Log a debug message (lowest severity)
# @param $1  string  Format string
# @param $@  mixed   Format arguments
# @return void
function log_debug() { _log_message "DEBUG" "$LOG_LEVEL_DEBUG" "$@"; }

# @description Log an informational message
# @param $1  string  Format string
# @param $@  mixed   Format arguments
# @return void
function log_info() { _log_message "INFO" "$LOG_LEVEL_INFO" "$@"; }

# @description Log a warning message
# @param $1  string  Format string
# @param $@  mixed   Format arguments
# @return void
function log_warn() { _log_message "WARN" "$LOG_LEVEL_WARN" "$@"; }

# @description Log an error message
# @param $1  string  Format string
# @param $@  mixed   Format arguments
# @return void
function log_error() { _log_message "ERROR" "$LOG_LEVEL_ERROR" "$@"; }

# @description Log a fatal error message (highest severity)
# @param $1  string  Format string
# @param $@  mixed   Format arguments
# @return void
function log_fatal() { _log_message "FATAL" "$LOG_LEVEL_FATAL" "$@"; }

# ── Convenience: log + return/exit ───────────────────────────────────────────

# @description Log an error and return a non-zero status (for use in functions)
# @param $1  string  Format string
# @param $@  mixed   Format arguments
# @return 1
function log_error_return() {
  log_error "$@"
  return 1
}

# @description Log a fatal error and exit the shell
# @param $1  string  Format string
# @param $@  mixed   Format arguments
# @return never (exits with code 1)
function log_fatal_exit() {
  log_fatal "$@"
  exit 1
}

# ── Log level management ────────────────────────────────────────────────────

# @description Set the current log level by name
# @param $1  string  Level name (debug|info|warn|error|fatal|silent)
# @return 0 on success, 1 on invalid level
function log_set_level() {
  local level="${1:l}"  # lowercase
  case "$level" in
    debug)  ZSH_LOG_LEVEL=$LOG_LEVEL_DEBUG  ;;
    info)   ZSH_LOG_LEVEL=$LOG_LEVEL_INFO   ;;
    warn)   ZSH_LOG_LEVEL=$LOG_LEVEL_WARN   ;;
    error)  ZSH_LOG_LEVEL=$LOG_LEVEL_ERROR  ;;
    fatal)  ZSH_LOG_LEVEL=$LOG_LEVEL_FATAL  ;;
    silent) ZSH_LOG_LEVEL=$LOG_LEVEL_SILENT ;;
    *)
      log_error "Invalid log level: %s (valid: debug|info|warn|error|fatal|silent)" "$1"
      return 1
      ;;
  esac
  log_debug "Log level set to: %s (%d)" "${level:u}" "$ZSH_LOG_LEVEL"
}

# @description Display the current log level
# @return void
function log_get_level() {
  local names=("DEBUG" "INFO" "WARN" "ERROR" "FATAL" "SILENT")
  printf "Current log level: %s (%d)\n" "${names[$((ZSH_LOG_LEVEL + 1))]}" "$ZSH_LOG_LEVEL"
}

# ── Section logging (for startup profiling) ──────────────────────────────────

# @description Log the start of a configuration section with a visual marker
# @param $1  string  Section name
# @return void
function log_section() {
  log_info "━━━ %s ━━━" "$1"
}

# @description Log a sub-step within a section
# @param $1  string  Step description
# @return void
function log_step() {
  log_info "  → %s" "$1"
}

# @description Log a success marker
# @param $1  string  Success description
# @return void
function log_success() {
  if _log_supports_color; then
    printf "%b✓%b %s\n" "\033[0;32m" "\033[0m" "$1" >&2
  else
    printf "✓ %s\n" "$1" >&2
  fi
}
