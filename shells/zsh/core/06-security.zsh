#!/usr/bin/env zsh
# ============================================================================
# @file        core/06-security.zsh
# @description Security hardening for the ZSH shell environment. Implements
#              protections against common attack vectors: path injection,
#              credential leaks, unsafe permissions, and command injection.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_CORE_SECURITY_LOADED:-}" ]] && return 0
readonly _ZSH_CORE_SECURITY_LOADED=1

log_debug "Applying security hardening"

# ============================================================================
# PATH Security
# ============================================================================

# @description Remove current directory (.) from PATH to prevent command
#              hijacking via trojan executables in the current directory
path=("${(@)path:#.}")

# @description Remove empty entries from PATH (which act as "." references)
path=("${(@)path:#}")

# @description Remove world-writable directories from PATH (if root)
if (( ZSH_IS_ROOT )); then
  local _safe_path=()
  local _dir
  for _dir in "${path[@]}"; do
    if [[ -d "$_dir" ]] && [[ ! -w "$_dir" || "$_dir" == "/usr/"* || "$_dir" == "/bin"* || "$_dir" == "/sbin"* ]]; then
      _safe_path+=("$_dir")
    elif [[ -d "$_dir" ]] && ! stat -c '%a' "$_dir" 2>/dev/null | grep -q '^..7'; then
      _safe_path+=("$_dir")
    else
      log_warn "PATH security: Skipping potentially unsafe directory: %s" "$_dir"
    fi
  done
  path=("${_safe_path[@]}")
  unset _safe_path _dir
fi

# ============================================================================
# File Permission Defaults
# ============================================================================

# @description Set umask to prevent group/other write access on new files
#   022 → owner: rwx, group: r-x, others: r-x
#   077 → owner: rwx, group: ---, others: --- (more restrictive)
if (( ZSH_IS_ROOT )); then
  umask 077  # Restrictive for root
else
  umask 022  # Standard for regular users
fi

# ============================================================================
# SSH Directory Permissions — Optimized (run in background)
# ============================================================================

function _secure_ssh_permissions() {
  local ssh_dir="${HOME}/.ssh"
  [[ -d "$ssh_dir" ]] || return 0

  chmod 700 "$ssh_dir" 2>/dev/null

  # -- Batch chmod instead of per-file loop
  find "$ssh_dir" -maxdepth 1 -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} + 2>/dev/null
  find "$ssh_dir" -maxdepth 1 -type f -name "*.pub" -exec chmod 644 {} + 2>/dev/null
  [[ -f "${ssh_dir}/config" ]] && chmod 600 "${ssh_dir}/config" 2>/dev/null
  [[ -f "${ssh_dir}/authorized_keys" ]] && chmod 600 "${ssh_dir}/authorized_keys" 2>/dev/null
  [[ -f "${ssh_dir}/known_hosts" ]] && chmod 644 "${ssh_dir}/known_hosts" 2>/dev/null
}

# -- Run in background to not block startup
_secure_ssh_permissions &!

# ============================================================================
# GnuPG Directory Permissions
# ============================================================================

# @description Ensure GnuPG directory has correct restrictive permissions
if [[ -d "${GNUPGHOME:-${HOME}/.gnupg}" ]]; then
  local _gpg_dir="${GNUPGHOME:-${HOME}/.gnupg}"
  chmod 700 "$_gpg_dir" 2>/dev/null
  # -- Secure all files within
  find "$_gpg_dir" -type f -exec chmod 600 {} \; 2>/dev/null
  find "$_gpg_dir" -type d -exec chmod 700 {} \; 2>/dev/null
  unset _gpg_dir
fi

# ============================================================================
# History File Permissions
# ============================================================================

# @description Ensure history file is not readable by others
if [[ -f "${HISTFILE:-}" ]]; then
  chmod 600 "$HISTFILE" 2>/dev/null
fi

# ============================================================================
# Credential Leak Prevention
# ============================================================================

# @description Override sensitive commands to prevent accidental credential
#              display in terminal scrollback
function _mask_env_secrets() {
  env | grep -v -iE '(secret|token|password|key|credential|auth)' | sort
}

# @description Safe 'env' command that masks sensitive values
function senv() {
  env | sed -E \
    's/(.*[Tt]oken.*=|.*[Ss]ecret.*=|.*[Pp]assword.*=|.*[Kk]ey.*=|.*[Aa]uth.*=)(.*)/\1*****/g' | \
    sort
}

# @description Redact a specific environment variable value in display
# @param  $1  string  Variable name to display (redacted)
# @return void (prints to stdout)
function redact() {
  local var_name="$1"
  local var_value="${(P)var_name}"
  if [[ -n "$var_value" ]]; then
    local shown="${var_value:0:4}"
    printf "%s=%s...[REDACTED]\n" "$var_name" "$shown"
  else
    printf "%s=(not set)\n" "$var_name"
  fi
}

# ============================================================================
# Command Injection Protection
# ============================================================================

# @description Disable hash command to prevent hash table poisoning
#              (attacker could redirect a command name to a malicious binary)
disable -r hash 2>/dev/null || true

# @description Warn when about to execute commands from untrusted locations
# (This is a monitoring hook, not a blocker)
function _check_command_source() {
  local cmd="$1"
  local cmd_path
  cmd_path="$(command -v "$cmd" 2>/dev/null)" || return 0

  # -- Warn if command resolves to a temp directory
  case "$cmd_path" in
    /tmp/*|/var/tmp/*|${TMPDIR:-/tmp}/*)
      log_warn "⚠️  Command '%s' resolves to temporary directory: %s" "$cmd" "$cmd_path"
      ;;
  esac
}

# ============================================================================
# Secure Temporary Files
# ============================================================================

# @description Create a secure temporary directory for the session
export ZSH_SECURE_TMPDIR="${TMPDIR:-/tmp}/zsh-secure-${USER}-$$"
mkdir -p "$ZSH_SECURE_TMPDIR" 2>/dev/null && chmod 700 "$ZSH_SECURE_TMPDIR"

# @description Create a secure temporary file
# @param  $1    string  (optional) Prefix for the temporary file
# @return       Prints the path to the created temporary file
function secure_tmpfile() {
  local prefix="${1:-zsh}"
  local tmpfile
  tmpfile=$(mktemp "${ZSH_SECURE_TMPDIR}/${prefix}.XXXXXXXX") || return 1
  chmod 600 "$tmpfile"
  printf '%s\n' "$tmpfile"
}

# @description Cleanup secure tmpdir on shell exit
function _cleanup_secure_tmpdir() {
  [[ -d "${ZSH_SECURE_TMPDIR:-}" ]] && rm -rf "$ZSH_SECURE_TMPDIR" >/dev/null 2>&1
}
# -- Register cleanup trap (only for interactive shells)
if [[ -o interactive ]]; then
  trap '_cleanup_secure_tmpdir' EXIT
fi

# ============================================================================
# Paste Protection — Bracketed paste mode
# ============================================================================

# @description Enable bracketed paste mode to prevent automatic execution
#              of pasted text containing newlines (paste bomb protection)
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# @description Enable URL quoting for safe pasting of URLs
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# ============================================================================
# Restricted Shell Detection
# ============================================================================

# @description Warn if running in a restricted shell mode
if [[ -o restricted ]]; then
  log_warn "Running in RESTRICTED shell mode — some features may be limited"
fi

# ============================================================================
# History Security — Prevent secrets in shell history
# ============================================================================

# @description  Enhanced zshaddhistory hook that filters sensitive commands.
#               Prevents passwords, tokens, and secrets from being recorded.
# @param  $1    string  Command line
# @return       1 to reject, 0 to accept
function zshaddhistory() {
  local line="${1%%$'\n'}"

  # -- Skip commands with sensitive patterns
  case "$line" in
    *password*=*|*PASSWORD*=*)         return 1 ;;
    *secret*=*|*SECRET*=*)             return 1 ;;
    *token*=*|*TOKEN*=*)               return 1 ;;
    *api_key*=*|*API_KEY*=*)           return 1 ;;
    *apikey*=*|*APIKEY*=*)             return 1 ;;
    *auth*=*|*AUTH*=*)                 return 1 ;;
    *credential*=*|*CREDENTIAL*=*)     return 1 ;;
    export\ *PASSWORD*|export\ *TOKEN*|export\ *SECRET*|export\ *KEY*) return 1 ;;
    *AWS_SECRET*|*GITHUB_TOKEN*|*GH_TOKEN*) return 1 ;;
    *BEGIN\ *PRIVATE\ KEY*)            return 1 ;;
    curl\ *-H*[Aa]uth*|curl\ *-u\ *)  return 1 ;;
    *mysql\ *-p*)                      return 1 ;;
    *pgpassword*|*PGPASSWORD*)         return 1 ;;
  esac

  # -- Skip very short commands (likely typos)
  [[ ${#line} -lt 3 ]] && return 1

  # -- Skip commands starting with space (HIST_IGNORE_SPACE)
  [[ "$line" == " "* ]] && return 1

  return 0
}

log_debug "Security hardening applied"
