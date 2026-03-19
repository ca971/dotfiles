#!/usr/bin/env zsh
# ============================================================================
# @file        core/07-performance.zsh
# @description Performance optimizations and profiling utilities for ZSH.
#              Implements compilation caching, lazy module loading, function
#              autoloading, and startup time measurement tools.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_CORE_PERFORMANCE_LOADED:-}" ]] && return 0
readonly _ZSH_CORE_PERFORMANCE_LOADED=1

log_debug "Configuring performance optimizations"

# ============================================================================
# ZSH Module Loading — Load only essential modules
# ============================================================================

# @description Load zsh/datetime for EPOCHREALTIME (high-precision timestamps)
zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null

# @description Load zsh/stat for builtin stat command (avoids fork)
zmodload -F zsh/stat b:zstat 2>/dev/null

# @description Load zsh/system for system-level operations
zmodload -i zsh/system 2>/dev/null

# @description Load zsh/parameter for special parameter access
zmodload -i zsh/parameter 2>/dev/null

# @description Load zsh/complist for completion listing enhancements
zmodload -i zsh/complist 2>/dev/null

# ============================================================================
# Compilation — Pre-compile frequently sourced files
# ============================================================================

# @description  Compile a ZSH file if it's newer than its compiled version.
#               Compiled (.zwc) files load significantly faster.
# @param  $1    string  Path to the .zsh file
# @return       0 on success or skip, 1 on error
function zcompile_if_needed() {
  local src="$1"
  [[ -f "$src" ]] || return 1

  local compiled="${src}.zwc"
  if [[ ! -f "$compiled" ]] || [[ "$src" -nt "$compiled" ]]; then
    zcompile "$src" 2>/dev/null && \
      log_debug "Compiled: %s" "$(basename "$src")" || \
      log_debug "Failed to compile: %s" "$(basename "$src")"
  fi
}

# @description  Compile all .zsh files in a directory tree
# @param  $1    string  Root directory to scan
# @return       void
function zcompile_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  local file
  for file in "${dir}"/**/*.zsh(N); do
    zcompile_if_needed "$file"
  done
}

# ============================================================================
# Startup Timing Utilities
# ============================================================================

# @type associative array
# @description Timer storage for measuring section durations
typeset -gA _ZSH_TIMERS=()

# @description  Start a named timer for performance measurement
# @param  $1    string  Timer name (identifier)
# @return       void
function timer_start() {
  local name="$1"
  _ZSH_TIMERS[$name]="${EPOCHREALTIME:-$(date +%s.%N)}"
}

# @description  Stop a named timer and log the elapsed duration
# @param  $1    string  Timer name (must match a previous timer_start call)
# @return       Prints elapsed time in milliseconds
function timer_stop() {
  local name="$1"
  local end="${EPOCHREALTIME:-$(date +%s.%N)}"
  local start="${_ZSH_TIMERS[$name]:-$end}"

  local elapsed_ms
  elapsed_ms=$(( (end - start) * 1000 ))

  log_debug "⏱  %s: %.1fms" "$name" "$elapsed_ms"
  printf "%.1f" "$elapsed_ms"
}

# @description  Measure the execution time of a command/function
# @param  $@    Command and arguments to measure
# @return       Executes the command and prints elapsed time
function measure() {
  local start="${EPOCHREALTIME:-$(date +%s.%N)}"
  "$@"
  local ret=$?
  local end="${EPOCHREALTIME:-$(date +%s.%N)}"
  local elapsed_ms=$(( (end - start) * 1000 ))
  printf "  ⏱  %.1fms — %s\n" "$elapsed_ms" "$*" >&2
  return $ret
}

# ============================================================================
# Startup Benchmark
# ============================================================================

# @description  Run a comprehensive ZSH startup benchmark
# @param  $1    integer  (optional) Number of iterations (default: 10)
# @return       void (prints statistics to stdout)
function zsh_benchmark() {
  local iterations="${1:-10}"
  local times=()
  local i total min max

  printf "  🏎  ZSH Startup Benchmark (%d iterations)\n" "$iterations"
  printf "  ─────────────────────────────────────\n"

  for (( i = 1; i <= iterations; i++ )); do
    local t
    t=$( { time zsh -ic exit; } 2>&1 | grep real | sed 's/real[[:space:]]*//' )

    # -- Convert to milliseconds (handle "0m0.123s" format)
    local ms
    if [[ "$t" =~ ([0-9]+)m([0-9.]+)s ]]; then
      local minutes="${match[1]}"
      local seconds="${match[2]}"
      ms=$(( (minutes * 60 + seconds) * 1000 ))
    else
      ms=0
    fi

    times+=("$ms")
    printf "  Run %2d: %.0fms\n" "$i" "$ms"
  done

  # -- Calculate statistics
  total=0
  min="${times[1]}"
  max="${times[1]}"
  for t in "${times[@]}"; do
    total=$(( total + t ))
    (( t < min )) && min=$t
    (( t > max )) && max=$t
  done
  local avg=$(( total / iterations ))

  printf "  ─────────────────────────────────────\n"
  printf "  Average: %.0fms\n" "$avg"
  printf "  Min:     %.0fms\n" "$min"
  printf "  Max:     %.0fms\n" "$max"
  printf "\n"

  # -- Performance rating
  if (( avg < 100 )); then
    printf "  🟢 Excellent (<100ms)\n"
  elif (( avg < 200 )); then
    printf "  🟡 Good (<200ms)\n"
  elif (( avg < 500 )); then
    printf "  🟠 Acceptable (<500ms)\n"
  else
    printf "  🔴 Slow (>500ms) — consider profiling with ZSH_PROFILE=1\n"
  fi
  printf "\n"
}

# ============================================================================
# Function Autoloading
# ============================================================================

# @description  Set up autoloading for a directory of function files.
#               Each file should contain a function with the same name as
#               the file (without extension).
# @param  $1    string  Directory containing function files
# @return       void
function setup_autoload() {
  local func_dir="$1"
  [[ -d "$func_dir" ]] || return 0

  fpath=("$func_dir" $fpath)

  local func_file
  for func_file in "${func_dir}"/*(.N:t); do
    autoload -Uz "$func_file"
  done
}

# ============================================================================
# Deferred Execution
# ============================================================================

# @type array
# @description Queue of commands to execute after first prompt (deferred load)
typeset -ga _ZSH_DEFERRED_COMMANDS=()

# @description  Schedule a command to run after the first prompt is displayed.
#               This defers non-critical initialization to improve perceived
#               startup time.
# @param  $@    string  Command to execute (evaluated with eval)
# @return       void
function defer() {
  _ZSH_DEFERRED_COMMANDS+=("$*")
}

# @description  Execute all deferred commands. Called automatically via
#               precmd hook after the first prompt.
function _execute_deferred() {
  # -- Unregister self to only run once
  add-zsh-hook -d precmd _execute_deferred

  local cmd
  for cmd in "${_ZSH_DEFERRED_COMMANDS[@]}"; do
    log_debug "Deferred exec: %s" "$cmd"
    eval "$cmd"
  done
  _ZSH_DEFERRED_COMMANDS=()
}

# -- Register deferred execution hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd _execute_deferred

# ============================================================================
# Process Substitution Optimization
# ============================================================================

# @description Increase the limit on the number of open file descriptors
#              for heavy I/O operations (compilation, multiple sources)
ulimit -n 4096 2>/dev/null || true

# ============================================================================
# Hash Table Optimization
# ============================================================================

# @description Rehash commands automatically when new executables are installed.
#              This uses TRAPUSR1 to refresh the hash table on signal.
TRAPUSR1() { rehash }

# @description Periodically check for PATH changes and rehash
#              (every 60 seconds in interactive shells)
typeset -g _ZSH_LAST_REHASH="${EPOCHREALTIME:-0}"

function _periodic_rehash() {
  local now="${EPOCHREALTIME:-$(date +%s)}"
  if (( now - _ZSH_LAST_REHASH > 60 )); then
    rehash
    _ZSH_LAST_REHASH="$now"
  fi
}
add-zsh-hook precmd _periodic_rehash

log_debug "Performance optimizations configured"
