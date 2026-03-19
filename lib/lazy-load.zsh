#!/usr/bin/env zsh
# ============================================================================
# @file        lib/lazy-load.zsh
# @description Lazy loading framework for ZSH. Provides mechanisms to defer
#              the initialization of tools, completions, and plugins until
#              they are first invoked. This dramatically reduces shell startup
#              time by avoiding eager evaluation of rarely-used commands.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @usage       # Lazy-load nvm when "node", "npm", or "nvm" is first called:
#              lazy_load "nvm" "node npm nvm" '_nvm_init'
#
#              # Lazy-load a tool config on first use:
#              lazy_load_tool "kubectl" "tools/kubernetes.zsh"
#
# @depends     lib/logging.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_LIB_LAZY_LOAD_LOADED:-}" ]] && return 0
readonly _ZSH_LIB_LAZY_LOAD_LOADED=1

# @type associative array
# @description Registry of lazy-loaded tools and their initialization state
typeset -gA _LAZY_LOAD_REGISTRY=()

# ============================================================================
# Core Lazy Loading — Command-based triggers
# ============================================================================

# @description  Create lazy-loading shims for a set of trigger commands.
#               When any trigger command is first invoked, the init function
#               is called, the shims are removed, and the original command
#               is re-executed with the original arguments.
#
# @param  $1    string   Identifier name (for logging/tracking)
# @param  $2    string   Space-separated list of trigger command names
# @param  $3    string   Initialization code (function name or inline code)
#
# @example      lazy_load "nvm" "node npm npx nvm" \
#                 'export NVM_DIR="$HOME/.nvm"; source "$NVM_DIR/nvm.sh"'
#
# @return       void
function lazy_load() {
  local name="$1"
  local triggers="$2"
  local init_code="$3"

  # -- Guard: don't re-register if already loaded
  if [[ "${_LAZY_LOAD_REGISTRY[$name]:-}" == "loaded" ]]; then
    return 0
  fi

  _LAZY_LOAD_REGISTRY[$name]="pending"

  local trigger
  for trigger in ${(z)triggers}; do
    # -- Create a shim function that replaces itself on first call
    eval "
      function ${trigger}() {
        # -- Remove all shims for this lazy group
        local _t
        for _t in ${(z)triggers}; do
          unfunction \"\${_t}\" 2>/dev/null
        done

        # -- Execute initialization
        log_debug \"Lazy loading: ${name} (triggered by ${trigger})\"
        ${init_code}

        # -- Mark as loaded
        _LAZY_LOAD_REGISTRY[${name}]=\"loaded\"

        # -- Re-execute the original command with original arguments
        if command -v \"${trigger}\" &>/dev/null; then
          ${trigger} \"\$@\"
        fi
      }
    "
  done

  log_debug "Registered lazy loader: %s (triggers: %s)" "$name" "$triggers"
}

# ============================================================================
# Lazy Tool Config Loading — File-based triggers
# ============================================================================

# @description  Lazy-load a tool configuration file when the tool command
#               is first invoked. Wraps the tool with a shim that sources
#               the config file, then re-executes the command.
#
# @param  $1    string  Tool command name (e.g., "kubectl")
# @param  $2    string  Path to config file relative to ZDOTDIR
#                        (e.g., "tools/kubernetes.zsh")
#
# @return       void
function lazy_load_tool() {
  local cmd="$1"
  local config_path="$2"
  local full_path="${ZDOTDIR}/${config_path}"

  # -- Skip if config file doesn't exist
  if [[ ! -f "$full_path" ]]; then
    log_debug "Lazy load skipped: %s (file not found: %s)" "$cmd" "$config_path"
    return 1
  fi

  eval "
    function ${cmd}() {
      unfunction \"${cmd}\" 2>/dev/null
      log_debug \"Lazy sourcing: ${config_path}\"
      source \"${full_path}\"
      ${cmd} \"\$@\"
    }
  "

  log_debug "Registered lazy tool loader: %s → %s" "$cmd" "$config_path"
}

# ============================================================================
# Lazy Completion Loading
# ============================================================================

# @description  Lazy-load completion definitions for a command. The completion
#               is only loaded and compiled when the user first attempts to
#               tab-complete the command.
#
# @param  $1    string  Command name
# @param  $2    string  Completion initialization code
#
# @return       void
function lazy_load_completion() {
  local cmd="$1"
  local init_code="$2"

  eval "
    function _lazy_comp_${cmd}() {
      compdef -d ${cmd}    # Remove this lazy compdef
      ${init_code}          # Initialize real completion
    }
    compdef _lazy_comp_${cmd} ${cmd}
  "

  log_debug "Registered lazy completion: %s" "$cmd"
}

# ============================================================================
# Lazy Environment Loading — Triggered by directory entry
# ============================================================================

# @description  Lazy-load environment setup when entering a specific directory
#               pattern. Useful for project-specific SDK/tool initialization.
#
# @param  $1    string  Directory glob pattern (e.g., "*/node_modules/..")
# @param  $2    string  Initialization code to execute
#
# @return       void
function lazy_load_on_cd() {
  local pattern="$1"
  local init_code="$2"
  local marker="_lazy_cd_$(echo "$pattern" | tr '/' '_' | tr '*' 'x')"

  eval "
    function _chpwd_lazy_${marker}() {
      if [[ \"\$PWD\" == ${pattern} ]] && [[ -z \"\${${marker}:-}\" ]]; then
        ${marker}=1
        log_debug \"Lazy CD load: ${pattern}\"
        ${init_code}
      fi
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd _chpwd_lazy_${marker}
  "

  log_debug "Registered lazy CD loader: %s" "$pattern"
}

# ============================================================================
# Lazy Load Status
# ============================================================================

# @description  Display the status of all registered lazy loaders
# @return       void (prints to stdout)
function lazy_load_status() {
  printf "\n  🦥 Lazy Load Registry\n"
  printf "  %-25s %s\n" "NAME" "STATUS"
  printf "  %-25s %s\n" "─────────────────────────" "──────────"

  local name status
  for name in "${(@k)_LAZY_LOAD_REGISTRY}"; do
    status="${_LAZY_LOAD_REGISTRY[$name]}"
    local icon
    case "$status" in
      loaded)  icon="✅" ;;
      pending) icon="💤" ;;
      *)       icon="❓" ;;
    esac
    printf "  %-25s %s %s\n" "$name" "$icon" "$status"
  done
  printf "\n"
}

# @description  Check if a lazy loader has been triggered and loaded
# @param  $1    string  Lazy loader name
# @return       0 if loaded, 1 if still pending or not registered
function is_lazy_loaded() {
  [[ "${_LAZY_LOAD_REGISTRY[$1]:-}" == "loaded" ]]
}
