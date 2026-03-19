#!/usr/bin/env zsh
# ============================================================================
# @file        functions/_helpers.zsh
# @description Core utility helper functions used throughout the ZSH
#              configuration. Provides common patterns for confirmation
#              prompts, string manipulation, path operations, clipboard
#              access, and other foundational utilities.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_HELPERS_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_HELPERS_LOADED=1

# ============================================================================
# Confirmation Prompts
# ============================================================================

# @description  Ask the user for a yes/no confirmation
# @param  $1    string  Prompt message
# @param  $2    string  (optional) Default: "y" or "n" (default: "n")
# @return       0 if confirmed (yes), 1 if declined (no)
function confirm() {
  local message="${1:-Are you sure?}"
  local default="${2:-n}"

  local prompt
  if [[ "${default:l}" == "y" ]]; then
    prompt="${message} [Y/n] "
  else
    prompt="${message} [y/N] "
  fi

  printf "%s" "$prompt"
  read -rk1 answer
  echo

  case "${answer:l}" in
    y) return 0 ;;
    n) return 1 ;;
    "")
      [[ "${default:l}" == "y" ]] && return 0 || return 1
      ;;
    *) return 1 ;;
  esac
}

# @description  Ask the user to select from a list of options
# @param  $1    string   Prompt message
# @param  $@    string   Options list
# @return       Selected option (printed to stdout), index as return code
function choose() {
  local prompt="$1"
  shift
  local -a options=("$@")

  printf "\n  %s\n\n" "$prompt"

  local i
  for (( i=1; i <= ${#options[@]}; i++ )); do
    printf "  %d) %s\n" "$i" "${options[$i]}"
  done

  printf "\n  Choice [1-%d]: " "${#options[@]}"
  local choice
  read -r choice

  if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
    printf "%s" "${options[$choice]}"
    return $(( choice - 1 ))
  else
    return 255
  fi
}

# ============================================================================
# String Utilities
# ============================================================================

# @description  Convert a string to lowercase
# @param  $1    string  Input string
# @return       Lowercase string (printed to stdout)
function lowercase() { printf "%s" "${1:l}"; }

# @description  Convert a string to uppercase
# @param  $1    string  Input string
# @return       Uppercase string (printed to stdout)
function uppercase() { printf "%s" "${1:u}"; }

# @description  Trim leading and trailing whitespace from a string
# @param  $1    string  Input string
# @return       Trimmed string (printed to stdout)
function trim() {
  local str="$1"
  str="${str#"${str%%[![:space:]]*}"}"
  str="${str%"${str##*[![:space:]]}"}"
  printf "%s" "$str"
}

# @description  Repeat a string N times
# @param  $1    string   String to repeat
# @param  $2    integer  Number of repetitions
# @return       Repeated string (printed to stdout)
function repeat_str() {
  local str="$1"
  local count="${2:-1}"
  printf "%0.s${str}" {1..$count}
}

# @description  Generate a separator line of a given character and width
# @param  $1    string   (optional) Character (default: "─")
# @param  $2    integer  (optional) Width (default: terminal width)
# @return       Separator line (printed to stdout)
function separator() {
  local char="${1:-─}"
  local width="${2:-${COLUMNS:-80}}"
  repeat_str "$char" "$width"
  echo
}

# @description  Count the number of characters in a string (UTF-8 aware)
# @param  $1    string  Input string
# @return       Character count (printed to stdout)
function strlen() {
  printf "%d" "${#1}"
}

# ============================================================================
# Clipboard Operations (cross-platform)
# ============================================================================

# @description  Copy text to the system clipboard
# @param  $1    string  (optional) Text to copy. If empty, reads from stdin.
# @return       void
function clip() {
  local text="${1:-$(cat)}"

  case "$ZSH_PLATFORM" in
    darwin)
      printf "%s" "$text" | pbcopy
      ;;
    wsl)
      printf "%s" "$text" | clip.exe
      ;;
    linux)
      if has "wl-copy"; then
        printf "%s" "$text" | wl-copy
      elif has "xclip"; then
        printf "%s" "$text" | xclip -selection clipboard
      elif has "xsel"; then
        printf "%s" "$text" | xsel --clipboard --input
      else
        log_warn "No clipboard tool found (install xclip, xsel, or wl-copy)"
        return 1
      fi
      ;;
  esac

  log_debug "Copied %d bytes to clipboard" "${#text}"
}

# @description  Paste text from the system clipboard
# @return       Clipboard content (printed to stdout)
function paste_clip() {
  case "$ZSH_PLATFORM" in
    darwin)
      pbpaste
      ;;
    wsl)
      powershell.exe -NoProfile -Command Get-Clipboard 2>/dev/null | tr -d '\r'
      ;;
    linux)
      if has "wl-paste"; then
        wl-paste
      elif has "xclip"; then
        xclip -selection clipboard -o
      elif has "xsel"; then
        xsel --clipboard --output
      else
        log_warn "No clipboard tool found"
        return 1
      fi
      ;;
  esac
}

# @description  Copy the current working directory path to clipboard
# @return       void
function cpwd() {
  printf "%s" "$PWD" | clip
  log_info "Copied to clipboard: %s" "$PWD"
}

# @description  Copy a file's content to clipboard
# @param  $1    string  File path
# @return       void
function cpfile() {
  local file="${1:?Usage: cpfile <file>}"
  if [[ -f "$file" ]]; then
    cat "$file" | clip
    log_info "File content copied: %s" "$file"
  else
    log_error "File not found: %s" "$file"
    return 1
  fi
}

# ============================================================================
# Path Utilities
# ============================================================================

# @description  Get the absolute/real path of a file or directory
# @param  $1    string  Relative or symlinked path
# @return       Absolute path (printed to stdout)
function realpath_safe() {
  if has "realpath"; then
    realpath "$1" 2>/dev/null
  elif has "grealpath"; then
    grealpath "$1" 2>/dev/null
  elif [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    python3 -c "import os; print(os.path.realpath('$1'))" 2>/dev/null
  else
    readlink -f "$1" 2>/dev/null || echo "$1"
  fi
}

# @description  Check if a path is inside a Git repository
# @param  $1    string  (optional) Path to check (default: current directory)
# @return       0 if inside a Git repo, 1 otherwise
function is_git_repo() {
  local dir="${1:-$PWD}"
  git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null
}

# @description  Get the root directory of the current Git repository
# @return       Git root path (printed to stdout), returns 1 if not in a repo
function git_root() {
  git rev-parse --show-toplevel 2>/dev/null || {
    log_error "Not inside a Git repository"
    return 1
  }
}

# ============================================================================
# Date / Time Utilities
# ============================================================================

# @description  Get the current ISO 8601 timestamp
# @return       Timestamp string (printed to stdout)
function now_iso() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

# @description  Get the current Unix timestamp (seconds)
# @return       Unix timestamp (printed to stdout)
function now_unix() {
  date '+%s'
}

# @description  Convert a Unix timestamp to human-readable date
# @param  $1    integer  Unix timestamp
# @return       Human-readable date (printed to stdout)
function from_unix() {
  local ts="${1:?Usage: from_unix <timestamp>}"
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    date -r "$ts" '+%Y-%m-%d %H:%M:%S'
  else
    date -d "@${ts}" '+%Y-%m-%d %H:%M:%S'
  fi
}

# @description  Show a human-readable time difference from now
# @param  $1    integer  Unix timestamp
# @return       Human-readable relative time (printed to stdout)
function time_ago() {
  local ts="${1:?Usage: time_ago <timestamp>}"
  local now
  now=$(date '+%s')
  local diff=$(( now - ts ))

  if (( diff < 60 )); then
    printf "%ds ago" "$diff"
  elif (( diff < 3600 )); then
    printf "%dm ago" "$(( diff / 60 ))"
  elif (( diff < 86400 )); then
    printf "%dh ago" "$(( diff / 3600 ))"
  elif (( diff < 604800 )); then
    printf "%dd ago" "$(( diff / 86400 ))"
  else
    printf "%dw ago" "$(( diff / 604800 ))"
  fi
}

# ============================================================================
# Encoding Utilities
# ============================================================================

# @description  URL-encode a string
# @param  $1    string  String to encode
# @return       URL-encoded string (printed to stdout)
function urlencode() {
  python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$1" 2>/dev/null || \
    printf "%s" "$1" | od -An -tx1 | tr ' ' '%' | tr -d '\n'
}

# @description  URL-decode a string
# @param  $1    string  URL-encoded string
# @return       Decoded string (printed to stdout)
function urldecode() {
  python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$1" 2>/dev/null || \
    printf "%b" "$(echo "$1" | sed 's/%/\\x/g')"
}

# @description  Base64 encode a string or file
# @param  $1    string  String to encode (or "-f <file>")
# @return       Base64-encoded string (printed to stdout)
function b64encode() {
  if [[ "$1" == "-f" ]]; then
    base64 < "${2:?Usage: b64encode -f <file>}"
  else
    printf "%s" "${1:-$(cat)}" | base64
  fi
}

# @description  Base64 decode a string
# @param  $1    string  Base64-encoded string
# @return       Decoded string (printed to stdout)
function b64decode() {
  printf "%s" "${1:-$(cat)}" | base64 --decode
}

# ============================================================================
# Miscellaneous
# ============================================================================

# @description  Generate a random password
# @param  $1    integer  (optional) Password length (default: 32)
# @return       Random password (printed to stdout)
function genpass() {
  local length="${1:-32}"
  if has "openssl"; then
    openssl rand -base64 "$length" | head -c "$length"
  else
    cat /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' | head -c "$length"
  fi
  echo
}

# @description  Generate a UUID v4
# @return       UUID string (printed to stdout)
function genuuid() {
  if has "uuidgen"; then
    uuidgen | tr '[:upper:]' '[:lower:]'
  else
    python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || \
      cat /proc/sys/kernel/random/uuid 2>/dev/null
  fi
}

# @description  Pretty-print JSON from stdin or argument
# @param  $1    string  (optional) JSON string or file
# @return       Formatted JSON (printed to stdout)
function jsonpp() {
  if [[ -n "$1" ]] && [[ -f "$1" ]]; then
    python3 -m json.tool < "$1"
  elif [[ -n "$1" ]]; then
    printf "%s" "$1" | python3 -m json.tool
  else
    python3 -m json.tool
  fi
}

# @description  Serve current directory over HTTP
# @param  $1    integer  (optional) Port number (default: 8000)
# @return       void (starts HTTP server)
function serve() {
  local port="${1:-8000}"
  log_info "Serving %s on http://localhost:%s" "$PWD" "$port"
  python3 -m http.server "$port"
}

# @description  Show a countdown timer
# @param  $1    integer  Seconds to count down
# @param  $2    string   (optional) Message to show when done
# @return       void
function countdown() {
  local secs="${1:?Usage: countdown <seconds> [message]}"
  local msg="${2:-Time's up!}"

  while (( secs > 0 )); do
    printf "\r  ⏱  %02d:%02d " "$(( secs / 60 ))" "$(( secs % 60 ))"
    sleep 1
    (( secs-- ))
  done
  printf "\r  🔔 %s\n" "$msg"
}

# ============================================================================
# Secure Clipboard — Auto-clear after timeout
# ============================================================================

# @description  Copy to clipboard and auto-clear after N seconds
# @param  $1    string  Text to copy (or stdin)
# @param  $2    integer (optional) Clear timeout in seconds (default: 30)
# @return       void
function clip-secure() {
  local text="${1:-$(cat)}"
  local timeout="${2:-30}"

  # Copy
  clip "$text"
  log_info "Copied to clipboard (auto-clears in %ds)" "$timeout"

  # Auto-clear in background
  {
    sleep "$timeout"
    case "$ZSH_PLATFORM" in
      darwin) echo -n "" | pbcopy ;;
      wsl)    echo -n "" | clip.exe ;;
      linux)
        has "xclip" && echo -n "" | xclip -selection clipboard
        has "wl-copy" && wl-copy --clear
        ;;
    esac
  } &!
}

log_debug "Helper functions loaded"
