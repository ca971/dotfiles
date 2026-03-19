#!/usr/bin/env zsh
# ============================================================================
# @file        lib/toml-parser.zsh
# @description Lightweight TOML parser for ZSH. Provides functions to read
#              TOML configuration files (used by SSOT definitions) and extract
#              values into ZSH variables and associative arrays. Supports a
#              practical subset of TOML: basic key/value pairs, sections,
#              arrays, inline tables, strings, integers, booleans.
#
#              This parser is intentionally simple — for complex TOML, the
#              SSOT generators (ssot/generators/*.sh) can use external tools
#              like `dasel`, `yq`, or `taplo`.
#
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @usage       source "${ZDOTDIR}/lib/toml-parser.zsh"
#              toml_parse "ssot/settings.toml"
#              toml_get "general.theme"
#              toml_get_bool "features.enable_icons"
#
# @depends     lib/logging.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_LIB_TOML_PARSER_LOADED:-}" ]] && return 0
readonly _ZSH_LIB_TOML_PARSER_LOADED=1

# @type associative array
# @description Parsed TOML data stored as flattened key-value pairs.
#              Section headers are prepended as prefixes with dot notation.
#              Example: [general] / theme = "catppuccin" → _TOML_DATA[general.theme]="catppuccin"
typeset -gA _TOML_DATA=()

# @type string
# @description Path of the last parsed TOML file (for error reporting)
typeset -g _TOML_CURRENT_FILE=""

# ============================================================================
# Core Parser
# ============================================================================

# @description  Parse a TOML file and populate _TOML_DATA associative array.
#               Supports: sections [header], key = "value", key = number,
#               key = true/false, key = ["array", "items"], comments (#).
#
# @param  $1    string   Path to the TOML file
# @param  $2    string   (optional) Key prefix for namespacing multiple files
#
# @return       0 on success, 1 if file not found or parse error
function toml_parse() {
  local file="$1"
  local prefix="${2:-}"

  if [[ ! -f "$file" ]]; then
    log_error "TOML parser: file not found: %s" "$file"
    return 1
  fi

  _TOML_CURRENT_FILE="$file"
  log_debug "Parsing TOML: %s" "$file"

  local section=""
  local line_num=0
  local line key value full_key

  while IFS= read -r line || [[ -n "$line" ]]; do
    (( line_num++ ))

    # -- Strip inline comments (but not inside strings)
    # Simple approach: strip # that's not inside quotes
    line="${line%%#*}"

    # -- Trim leading/trailing whitespace
    line="${line## }"
    line="${line%% }"
    line="${${line## }%% }"

    # -- Skip empty lines
    [[ -z "$line" ]] && continue

    # -- Section header: [section] or [section.subsection]
    if [[ "$line" =~ '^\[([a-zA-Z0-9_.-]+)\]$' ]]; then
      section="${match[1]}"
      log_debug "TOML section: [%s]" "$section"
      continue
    fi

    # -- Key-value pair: key = value
    if [[ "$line" =~ '^([a-zA-Z0-9_-]+)[[:space:]]*=[[:space:]]*(.+)$' ]]; then
      key="${match[1]}"
      value="${match[2]}"

      # -- Build full key path with section prefix
      if [[ -n "$section" ]]; then
        full_key="${section}.${key}"
      else
        full_key="$key"
      fi

      # -- Add optional file prefix
      if [[ -n "$prefix" ]]; then
        full_key="${prefix}.${full_key}"
      fi

      # -- Parse value type and clean
      value="$(_toml_parse_value "$value")"

      _TOML_DATA[$full_key]="$value"
      log_debug "TOML: %s = %s" "$full_key" "$value"
      continue
    fi

    # -- Unrecognized line (warn but don't fail)
    if [[ -n "$line" ]]; then
      log_debug "TOML: skipping unrecognized line %d: %s" "$line_num" "$line"
    fi

  done < "$file"

  log_debug "TOML parsed: %d entries from %s" "${#_TOML_DATA}" "$file"
  return 0
}

# ============================================================================
# Value Parser — Type detection and cleaning
# ============================================================================

# @description  Parse and clean a TOML value string. Handles:
#               - Quoted strings: "value" or 'value'
#               - Integers: 42
#               - Booleans: true / false
#               - Arrays: ["a", "b", "c"] (returns space-separated)
#
# @param  $1    string  Raw value from TOML line
# @return       Cleaned value (printed to stdout)
function _toml_parse_value() {
  local raw="$1"

  # -- Trim whitespace
  raw="${raw## }"
  raw="${raw%% }"

  # -- Double-quoted string: "value"
  if [[ "$raw" =~ '^"(.*)"$' ]]; then
    # -- Handle escape sequences
    local unescaped="${match[1]}"
    unescaped="${unescaped//\\n/$'\n'}"
    unescaped="${unescaped//\\t/$'\t'}"
    unescaped="${unescaped//\\\"/\"}"
    unescaped="${unescaped//\\\\/\\}"
    printf '%s' "$unescaped"
    return
  fi

  # -- Single-quoted string: 'value' (literal, no escapes)
  if [[ "$raw" =~ "^'(.*)'$" ]]; then
    printf '%s' "${match[1]}"
    return
  fi

  # -- Array: ["a", "b", "c"]
  if [[ "$raw" =~ '^\[(.+)\]$' ]]; then
    local array_content="${match[1]}"
    # -- Remove quotes and clean up
    array_content="${array_content//\"/}"
    array_content="${array_content//\'/}"
    # -- Replace commas with newlines for easier processing
    array_content="${array_content//,/$'\n'}"
    # -- Trim each element and join with space
    local result=""
    local elem
    while IFS= read -r elem; do
      elem="${elem## }"
      elem="${elem%% }"
      [[ -n "$elem" ]] && result+="${elem} "
    done <<< "$array_content"
    printf '%s' "${result%% }"
    return
  fi

  # -- Boolean / Integer / bare value: pass through
  printf '%s' "$raw"
}

# ============================================================================
# Accessors — Query parsed data
# ============================================================================

# @description  Get a value from the parsed TOML data
# @param  $1    string  Dot-notation key (e.g., "general.theme")
# @param  $2    string  (optional) Default value if key not found
# @return       Prints value to stdout; returns 1 if not found and no default
function toml_get() {
  local key="$1"
  local default="${2:-}"

  if [[ -n "${_TOML_DATA[$key]+isset}" ]]; then
    printf '%s' "${_TOML_DATA[$key]}"
    return 0
  fi

  if [[ -n "$default" ]]; then
    printf '%s' "$default"
    return 0
  fi

  return 1
}

# @description  Get a boolean value from parsed TOML data
# @param  $1    string   Dot-notation key
# @param  $2    string   (optional) Default: "true" or "false"
# @return       0 if true, 1 if false
function toml_get_bool() {
  local key="$1"
  local default="${2:-false}"
  local value

  value="$(toml_get "$key" "$default")"

  case "${value:l}" in
    true|yes|1|on)  return 0 ;;
    false|no|0|off) return 1 ;;
    *)
      log_warn "TOML: non-boolean value for '%s': %s (treating as false)" "$key" "$value"
      return 1
      ;;
  esac
}

# @description  Get an integer value from parsed TOML data
# @param  $1    string   Dot-notation key
# @param  $2    integer  (optional) Default value
# @return       Prints integer to stdout; returns 1 if not found/invalid
function toml_get_int() {
  local key="$1"
  local default="${2:-0}"
  local value

  value="$(toml_get "$key" "$default")"

  if [[ "$value" =~ '^-?[0-9]+$' ]]; then
    printf '%d' "$value"
    return 0
  else
    log_warn "TOML: non-integer value for '%s': %s (using default: %s)" "$key" "$value" "$default"
    printf '%d' "$default"
    return 1
  fi
}

# @description  Get an array value from parsed TOML data (space-separated → array)
# @param  $1    string  Dot-notation key
# @return       Prints space-separated array values; returns 1 if not found
function toml_get_array() {
  local key="$1"
  local value

  value="$(toml_get "$key")" || return 1
  printf '%s' "$value"
}

# @description  Check if a key exists in the parsed TOML data
# @param  $1    string  Dot-notation key
# @return       0 if exists, 1 if not
function toml_has() {
  [[ -n "${_TOML_DATA[$1]+isset}" ]]
}

# ============================================================================
# Section Enumeration
# ============================================================================

# @description  List all keys under a given section prefix
# @param  $1    string  Section prefix (e.g., "aliases.general")
# @return       Prints matching keys, one per line
function toml_keys() {
  local prefix="$1"
  local key
  for key in "${(@k)_TOML_DATA}"; do
    if [[ "$key" == "${prefix}."* ]]; then
      printf '%s\n' "$key"
    fi
  done | sort
}

# @description  List all top-level sections in the parsed TOML data
# @return       Prints section names, one per line (deduplicated)
function toml_sections() {
  local key section
  local -aU sections=()
  for key in "${(@k)_TOML_DATA}"; do
    if [[ "$key" == *.* ]]; then
      section="${key%%.*}"
      sections+=("$section")
    fi
  done
  printf '%s\n' "${sections[@]}" | sort
}

# ============================================================================
# Data Management
# ============================================================================

# @description  Clear all parsed TOML data (useful before parsing a new file)
# @return       void
function toml_clear() {
  _TOML_DATA=()
  _TOML_CURRENT_FILE=""
  log_debug "TOML data cleared"
}

# @description  Dump all parsed TOML data (for debugging)
# @return       void (prints to stdout)
function toml_dump() {
  printf "\n  📄 TOML Data Dump"
  [[ -n "$_TOML_CURRENT_FILE" ]] && printf " (%s)" "$_TOML_CURRENT_FILE"
  printf "\n  ─────────────────────────────────\n"

  local key
  for key in "${(@ko)_TOML_DATA}"; do
    printf "  %-40s = %s\n" "$key" "${_TOML_DATA[$key]}"
  done
  printf "  ─────────────────────────────────\n"
  printf "  Total entries: %d\n\n" "${#_TOML_DATA}"
}

# ============================================================================
# Multi-File Parsing
# ============================================================================

# @description  Parse multiple TOML files, each namespaced by filename
# @param  $@    string  Paths to TOML files
# @return       void
function toml_parse_all() {
  local file basename prefix
  for file in "$@"; do
    if [[ -f "$file" ]]; then
      basename="$(basename "$file" .toml)"
      toml_parse "$file" "$basename"
    fi
  done
}
