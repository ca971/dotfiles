#!/usr/bin/env zsh
# ============================================================================
# @file        core/03-history.zsh
# @description ZSH history engine configuration. Manages history file
#              location, size, search behavior, and filtering rules.
#              Integrates with Atuin when available (see tools/atuin.zsh),
#              but provides a robust native history setup as fallback.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, core/00-xdg.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_CORE_HISTORY_LOADED:-}" ]] && return 0
readonly _ZSH_CORE_HISTORY_LOADED=1

log_debug "Configuring history engine"

# ============================================================================
# History File & Size
# ============================================================================

# @description Path to the history file (XDG-compliant)
export HISTFILE="${ZSH_DATA_DIR}/history"

# @description Maximum number of history entries kept in memory
export HISTSIZE=100000

# @description Maximum number of history entries saved to file
export SAVEHIST=100000

# @description Ensure the history directory exists
[[ -d "$(dirname "$HISTFILE")" ]] || mkdir -p "$(dirname "$HISTFILE")" 2>/dev/null

# @description Ensure the history file exists with correct permissions
if [[ ! -f "$HISTFILE" ]]; then
  touch "$HISTFILE"
  chmod 600 "$HISTFILE"
fi

# ============================================================================
# History Pattern Filtering
# ============================================================================

# @type        array
# @description Patterns of commands to exclude from history recording.
#              Commands matching these patterns will not be saved.
#              Format: <pattern> (glob-style matching)
export HISTORY_IGNORE="(ls|ll|la|cd|cd ..|pwd|exit|clear|cls|c|q|history|h)"

# @description Additional patterns using zshaddhistory hook
# @return      1 to reject the command from history, 0 to accept
function zshaddhistory() {
  local line="${1%%$'\n'}"
  local cmd="${line%% *}"

  # -- Skip very short commands (likely typos)
  [[ ${#line} -lt 3 ]] && return 1

  # -- Skip commands that start with a space (HIST_IGNORE_SPACE backup)
  [[ "$line" == " "* ]] && return 1

  # -- Skip sensitive patterns
  case "$line" in
    *password*|*secret*|*token*|*apikey*|*api_key*)
      return 1
      ;;
    *AWS_SECRET*|*GITHUB_TOKEN*|*SSH_KEY*|*PRIVATE_KEY*)
      return 1
      ;;
    export\ *=*password*|export\ *=*secret*|export\ *=*token*)
      return 1
      ;;
  esac

  # -- Skip ephemeral commands
  case "$cmd" in
    fg|bg|jobs|disown|exit|logout|clear|reset|cls|c|q)
      return 1
      ;;
  esac

  return 0
}

# ============================================================================
# History Search Functions
# ============================================================================

# @description  Search history with a grep pattern
# @param  $1    string  Search pattern (grep-compatible)
# @return       Prints matching history entries to stdout
function hsearch() {
  if [[ -z "$1" ]]; then
    log_error "Usage: hsearch <pattern>"
    return 1
  fi
  fc -ln 0 | grep --color=auto -i "$1"
}

# @description  Show the most frequently used commands
# @param  $1    integer  (optional) Number of commands to show (default: 20)
# @return       Prints command frequency report to stdout
function htop() {
  local count="${1:-20}"
  fc -ln 0 | \
    awk '{ print $1 }' | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -"${count}" | \
    awk '{printf "  %5d  %s\n", $1, $2}'
}

# @description  Show history statistics (total entries, file size, etc.)
# @return       void (prints to stdout)
function hstats() {
  local total_file total_mem filesize

  total_file=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
  total_mem=$( (( ${#history} )) 2>/dev/null || echo "N/A" )

  if command -v stat &>/dev/null; then
    if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
      filesize=$(stat -f%z "$HISTFILE" 2>/dev/null)
    else
      filesize=$(stat --printf="%s" "$HISTFILE" 2>/dev/null)
    fi
    # -- Human-readable size
    if (( filesize > 1048576 )); then
      filesize="$(( filesize / 1048576 ))MB"
    elif (( filesize > 1024 )); then
      filesize="$(( filesize / 1024 ))KB"
    else
      filesize="${filesize}B"
    fi
  else
    filesize="N/A"
  fi

  printf "\n  📊 History Statistics\n"
  printf "  ─────────────────────────\n"
  printf "  File:        %s\n" "$HISTFILE"
  printf "  Size:        %s\n" "$filesize"
  printf "  Lines:       %s\n" "$total_file"
  printf "  In memory:   %s\n" "${#history}"
  printf "  HISTSIZE:    %s\n" "$HISTSIZE"
  printf "  SAVEHIST:    %s\n" "$SAVEHIST"
  printf "\n"
}

# @description  Safely clean duplicate entries from the history file
# @return       void
function hclean() {
  local tmpfile="${HISTFILE}.tmp.$$"
  if [[ -f "$HISTFILE" ]]; then
    # -- Preserve extended history format while removing duplicates
    awk '!seen[$0]++' "$HISTFILE" > "$tmpfile" && \
      mv "$tmpfile" "$HISTFILE"
    log_info "History cleaned: duplicates removed"
    fc -R  # Reload history
  fi
}

# @description  Backup the history file
# @return       void
function hbackup() {
  local backup="${HISTFILE}.backup.$(date +%Y%m%d_%H%M%S)"
  if [[ -f "$HISTFILE" ]]; then
    cp "$HISTFILE" "$backup"
    log_info "History backed up to: %s" "$backup"
  fi
}

log_debug "History engine configured (file=%s, size=%d)" "$HISTFILE" "$HISTSIZE"
