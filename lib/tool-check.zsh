#!/usr/bin/env zsh
# ============================================================================
# @file        lib/tool-check.zsh
# @description Tool availability and version checking library. Provides
#              functions to verify whether CLI tools are installed, meet
#              minimum version requirements, and conditionally load
#              configurations based on tool presence.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @usage       source "${ZDOTDIR}/lib/tool-check.zsh"
#              has "eza" && source "${ZDOTDIR}/tools/eza.zsh"
#              need "git" "2.30"
#              load_tool_config "fzf"
#
# @changelog   1.2.0 — Fixed negative cache bug. Negative lookups are NO
#              LONGER cached, so tools that become available after PATH
#              changes (e.g., Homebrew) are correctly detected.

# @depends     lib/logging.zsh
# ============================================================================


# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_LIB_TOOL_CHECK_LOADED:-}" ]] && return 0
readonly _ZSH_LIB_TOOL_CHECK_LOADED=1

# ── Tool cache (avoids repeated lookups) ─────────────────────────────────────
# @type associative array
# @description Cache of tool name → path. Only POSITIVE results are cached.
typeset -gA _TOOL_CACHE=()

# ============================================================================
# @description  Check if a command/tool is available in PATH
# @param  $1    string  Command name to check
# @return       0 if found, 1 if not found
# ============================================================================
function has() {
  local tool="$1"

  # -- Return from cache if positive
  if [[ -n "${_TOOL_CACHE[$tool]:-}" ]]; then
    return 0
  fi

  # -- Use $+commands (instant hash lookup, no fork)
  if (( $+commands[$tool] )); then
    _TOOL_CACHE[$tool]="${commands[$tool]}"
    return 0
  fi

  # -- Fallback: command -v (handles builtins, functions)
  local path_result
  path_result="$(command -v "$tool" 2>/dev/null)"
  if [[ -n "$path_result" ]]; then
    _TOOL_CACHE[$tool]="$path_result"
    return 0
  fi

  return 1
}

# ============================================================================
# @description  Check if multiple tools are all available
# @param  $@    string  List of command names
# @return       0 if all found, 1 if any missing
# ============================================================================
function has_all() {
  local tool
  for tool in "$@"; do
    has "$tool" || return 1
  done
  return 0
}

# ============================================================================
# @description  Check if at least one of the listed tools is available
# @param  $@    string  List of command names
# @return       0 if any found, 1 if none found
# ============================================================================
function has_any() {
  local tool
  for tool in "$@"; do
    has "$tool" && return 0
  done
  return 1
}

# ============================================================================
# @description  Get the resolved path of a tool (cached)
# @param  $1    string  Command name
# @return       Prints path to stdout; returns 1 if not found
# ============================================================================
function tool_path() {
  has "$1" && printf "%s\n" "${_TOOL_CACHE[$1]}" && return 0
  return 1
}

# ============================================================================
# @description  Compare two version strings (semver-like)
# @param  $1    string  Version A
# @param  $2    string  Operator: "ge" "gt" "le" "lt" "eq"
# @param  $3    string  Version B
# @return       0 if comparison is true, 1 otherwise
# ============================================================================
function version_compare() {
  local ver_a="$1" op="$2" ver_b="$3"

  ver_a="${ver_a#v}"
  ver_b="${ver_b#v}"

  local sorted
  sorted=$(printf '%s\n%s\n' "$ver_a" "$ver_b" | sort -V)
  local first
  first=$(echo "$sorted" | head -1)

  case "$op" in
    ge) [[ "$first" == "$ver_b" ]] ;;
    gt) [[ "$first" == "$ver_b" ]] && [[ "$ver_a" != "$ver_b" ]] ;;
    le) [[ "$first" == "$ver_a" ]] ;;
    lt) [[ "$first" == "$ver_a" ]] && [[ "$ver_a" != "$ver_b" ]] ;;
    eq) [[ "$ver_a" == "$ver_b" ]] ;;
    *)
      log_error "version_compare: invalid operator '%s'" "$op"
      return 1
      ;;
  esac
}

# ============================================================================
# @description  Get the version string of an installed tool
# @param  $1    string  Command name
# @return       Prints version to stdout; returns 1 if unable to determine
# ============================================================================
function tool_version() {
  local tool="$1"
  has "$tool" || return 1

  local version_output version

  for flag in "--version" "-V" "version" "-v"; do
    version_output=$("$tool" "$flag" 2>&1 | head -1)
    if [[ $? -eq 0 ]] && [[ -n "$version_output" ]]; then
      version=$(echo "$version_output" | grep -oE '[v]?[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
      if [[ -n "$version" ]]; then
        printf "%s\n" "${version#v}"
        return 0
      fi
    fi
  done

  return 1
}

# ============================================================================
# @description  Assert that a tool is installed and optionally meets minimum version
# @param  $1    string  Command name
# @param  $2    string  (optional) Minimum version required
# @return       0 if requirements met, 1 otherwise
# ============================================================================
function need() {
  local tool="$1"
  local min_version="${2:-}"

  if ! has "$tool"; then
    log_warn "Required tool not found: %s" "$tool"
    return 1
  fi

  if [[ -n "$min_version" ]]; then
    local current_version
    current_version=$(tool_version "$tool")
    if [[ -n "$current_version" ]]; then
      if ! version_compare "$current_version" "ge" "$min_version"; then
        log_warn "Tool '%s' version %s < required %s" "$tool" "$current_version" "$min_version"
        return 1
      fi
    fi
  fi

  return 0
}

# ============================================================================
# @description  Conditionally source a tool configuration file
# @param  $1    string  Tool name (e.g., "eza" → tools/eza.zsh)
# @return       0 if sourced, 1 if tool not found or file missing
# ============================================================================
function load_tool_config() {
  local tool="$1"
  local config_file="${DOTFILES_DIR}/tools/${tool}.zsh"

  if ! has "$tool"; then
    log_debug "Skipping tool config: %s (not installed)" "$tool"
    return 1
  fi

  if [[ -f "$config_file" ]]; then
    log_debug "Loading tool config: %s" "$tool"
    source "$config_file"
    return 0
  else
    log_debug "No config file for tool: %s (expected: %s)" "$tool" "$config_file"
    return 1
  fi
}

# ============================================================================
# @description  Load multiple tool configs at once
# @param  $@    string  List of tool names
# @return       void
# ============================================================================
function load_tool_configs() {
  local tool
  for tool in "$@"; do
    load_tool_config "$tool"
  done
}

# ============================================================================
# @description  Clear the tool lookup cache (useful after PATH changes)
# @return       void
# ============================================================================
function tool_cache_clear() {
  _TOOL_CACHE=()
  log_debug "Tool cache cleared"
}

# ============================================================================
# @description  Print a diagnostic report of tools
# @param  $@    string  (optional) List of tools to check
# @return       void
# ============================================================================
function tool_doctor() {
  local -a tools=("$@")

  if (( ${#tools} == 0 )); then
    tools=(
      eza fzf mise neovim zoxide bat fd ripgrep atuin direnv delta yazi
      carapace btop navi fastfetch just gpg gh pipx dust topgrade dfc duf
      thefuck lazydocker lazygit tldr docker podman kubectl chezmoi
      starship git most
    )
  fi

  printf "\n  🔍 Tool Availability Report\n"
  printf "  %-20s %-10s %-15s %s\n" "TOOL" "STATUS" "VERSION" "PATH"
  printf "  %-20s %-10s %-15s %s\n" "────────────────────" "──────────" "───────────────" "────────────────────"

  local tool status version tpath
  for tool in "${tools[@]}"; do
    if has "$tool"; then
      status="✓"
      version=$(tool_version "$tool" 2>/dev/null) || version="n/a"
      tpath="${_TOOL_CACHE[$tool]}"
    else
      status="✗"
      version="-"
      tpath="-"
    fi
    printf "  %-20s %-10s %-15s %s\n" "$tool" "$status" "$version" "$tpath"
  done
  printf "\n"
}
