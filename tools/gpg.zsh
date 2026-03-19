#!/usr/bin/env zsh
# ============================================================================
# @file        tools/gpg.zsh
# @description GnuPG (GPG) agent integration. Configures the GPG agent for
#              secure key management, SSH authentication via GPG keys,
#              and proper TTY handling for passphrase prompts.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @see         https://gnupg.org
# @depends     lib/logging.zsh, lib/tool-check.zsh
# ============================================================================

[[ -n "${_ZSH_TOOLS_GPG_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_GPG_LOADED=1

has "gpg" || has "gpg2" || return 0

log_debug "Configuring gpg"

# ============================================================================
# Binary Detection
# ============================================================================

if has "gpg2" && ! has "gpg"; then
  alias gpg="gpg2"
fi

# ============================================================================
# Constants
# ============================================================================

readonly GPG_SRC_DIR="${DOTFILES_DIR}/config/gpg"
export GNUPGHOME="${GNUPGHOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/gnupg}"

# ============================================================================
# Auto-Setup
# ============================================================================

function _gpg_auto_setup() {

  # ── 1. Create GNUPGHOME with correct permissions ────────────────────
  if [[ ! -d "$GNUPGHOME" ]]; then
    mkdir -p "$GNUPGHOME" 2>/dev/null
    chmod 700 "$GNUPGHOME" 2>/dev/null
  fi

  # ── 2. Symlink gpg.conf ────────────────────────────────────────────
  local src_conf="${GPG_SRC_DIR}/gpg.conf"
  local dst_conf="${GNUPGHOME}/gpg.conf"
  if [[ -f "$src_conf" ]]; then
    if [[ ! -L "$dst_conf" ]] || [[ "$(readlink "$dst_conf" 2>/dev/null)" != "$src_conf" ]]; then
      [[ -f "$dst_conf" ]] && [[ ! -L "$dst_conf" ]] && \
        mv "$dst_conf" "${dst_conf}.bak.$(date +%s)" >/dev/null 2>&1
      ln -sf "$src_conf" "$dst_conf" >/dev/null 2>&1
    fi
  fi

  # ── 3. Symlink gpg-agent.conf ──────────────────────────────────────
  local src_agent="${GPG_SRC_DIR}/gpg-agent.conf"
  local dst_agent="${GNUPGHOME}/gpg-agent.conf"
  if [[ -f "$src_agent" ]]; then
    if [[ ! -L "$dst_agent" ]] || [[ "$(readlink "$dst_agent" 2>/dev/null)" != "$src_agent" ]]; then
      [[ -f "$dst_agent" ]] && [[ ! -L "$dst_agent" ]] && \
        mv "$dst_agent" "${dst_agent}.bak.$(date +%s)" >/dev/null 2>&1
      ln -sf "$src_agent" "$dst_agent" >/dev/null 2>&1
    fi
  fi

  # ── 4. Set GPG_TTY (CRITICAL for passphrase prompts) ───────────────
  export GPG_TTY="$(tty)"

  # ── 5. Start agent and update TTY ──────────────────────────────────
  if has "gpgconf"; then
    gpgconf --launch gpg-agent >/dev/null 2>&1
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
  fi

  # ── 6. Fix permissions (background) ────────────────────────────────
  {
    chmod 700 "$GNUPGHOME" 2>/dev/null
    find "$GNUPGHOME" -type f -exec chmod 600 {} + 2>/dev/null
    find "$GNUPGHOME" -type d -exec chmod 700 {} + 2>/dev/null
  } &!

  # ── 7. Detect and configure pinentry ───────────────────────────────
  _gpg_configure_pinentry
}

# @description  Auto-detect and configure the best pinentry program
function _gpg_configure_pinentry() {
  local agent_conf="${GNUPGHOME}/gpg-agent.conf"
  [[ -f "$agent_conf" ]] || return 0

  # Skip if pinentry is already configured (uncommented)
  grep -q "^pinentry-program" "$agent_conf" 2>/dev/null && return 0

  local pinentry=""
  case "$ZSH_PLATFORM" in
    darwin)
      if [[ -x "/opt/homebrew/bin/pinentry-mac" ]]; then
        pinentry="/opt/homebrew/bin/pinentry-mac"
      elif [[ -x "/usr/local/bin/pinentry-mac" ]]; then
        pinentry="/usr/local/bin/pinentry-mac"
      fi
      ;;
    linux)
      if has "pinentry-gnome3"; then
        pinentry="$(command -v pinentry-gnome3)"
      elif has "pinentry-qt"; then
        pinentry="$(command -v pinentry-qt)"
      elif has "pinentry-tty"; then
        pinentry="$(command -v pinentry-tty)"
      elif has "pinentry-curses"; then
        pinentry="$(command -v pinentry-curses)"
      fi
      ;;
  esac

  if [[ -n "$pinentry" ]]; then
    # Append to the source file (not the symlink target, but a local override)
    local local_agent="${GNUPGHOME}/gpg-agent.local.conf"
    if [[ ! -f "$local_agent" ]] || ! grep -q "pinentry-program" "$local_agent" 2>/dev/null; then
      printf "pinentry-program %s\n" "$pinentry" >> "$local_agent" 2>/dev/null
      # Reload agent
      gpgconf --kill gpg-agent >/dev/null 2>&1
      gpgconf --launch gpg-agent >/dev/null 2>&1
    fi
  fi
}

_gpg_auto_setup

# ============================================================================
# Functions — Key Management
# ============================================================================

# @description  List all public GPG keys
function gpg-keys() {
  printf "\n  🔐 GPG Keys (Public)\n"
  printf "  ═══════════════════════════════════\n\n"
  gpg --list-keys --keyid-format 0xlong 2>/dev/null || printf "  No public keys found\n"
  printf "\n  ═══════════════════════════════════\n\n"
}

# @description  List all secret GPG keys
function gpg-secret-keys() {
  printf "\n  🔐 GPG Keys (Secret)\n"
  printf "  ═══════════════════════════════════\n\n"
  gpg --list-secret-keys --keyid-format 0xlong 2>/dev/null || printf "  No secret keys found\n"
  printf "\n  ═══════════════════════════════════\n\n"
}

# @description  Generate a new GPG key pair (interactive)
function gpg-generate() {
  printf "\n  🔐 GPG Key Generator\n"
  printf "  ─────────────────────────────────\n\n"
  printf "  Recommended: RSA 4096 or ed25519\n\n"
  gpg --full-generate-key
}

# @description  Export a public key (ASCII armored)
# @param  $1    string  Key ID or email
function gpg-export() {
  local keyid="${1:?Usage: gpg-export <key-id-or-email>}"
  gpg --armor --export "$keyid"
}

# @description  Export public key and copy to clipboard (for GitHub/GitLab)
# @param  $1    string  Key ID or email
function gpg-export-clipboard() {
  local keyid="${1:?Usage: gpg-export-clipboard <key-id-or-email>}"
  local key
  key=$(gpg --armor --export "$keyid" 2>/dev/null)

  if [[ -z "$key" ]]; then
    log_error "Key not found: %s" "$keyid"
    return 1
  fi

  echo "$key"

  case "$ZSH_PLATFORM" in
    darwin) echo "$key" | pbcopy && log_info "Copied to clipboard" ;;
    linux)
      has "xclip" && echo "$key" | xclip -selection clipboard && log_info "Copied to clipboard"
      has "wl-copy" && echo "$key" | wl-copy && log_info "Copied to clipboard"
      ;;
    wsl) echo "$key" | clip.exe && log_info "Copied to clipboard" ;;
  esac
}

# @description  Import a GPG key from file or URL
# @param  $1    string  Key file path or URL
function gpg-import() {
  local source="${1:?Usage: gpg-import <file-or-url>}"

  if [[ "$source" =~ ^https?:// ]]; then
    curl -sSL "$source" | gpg --import
  elif [[ -f "$source" ]]; then
    gpg --import "$source"
  else
    log_error "Not found: %s" "$source"
    return 1
  fi
}

# @description  Restart the GPG agent
function gpg-restart() {
  gpgconf --kill gpg-agent >/dev/null 2>&1
  gpgconf --launch gpg-agent >/dev/null 2>&1
  export GPG_TTY="$(tty)"
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
  log_info "GPG agent restarted"
}

# @description  Encrypt a file symmetrically (password-based)
# @param  $1    string  File to encrypt
function gpg-encrypt() {
  local file="${1:?Usage: gpg-encrypt <file>}"
  gpg --symmetric --cipher-algo AES256 "$file"
  log_info "Encrypted: %s.gpg" "$file"
}

# @description  Decrypt a GPG-encrypted file
# @param  $1    string  Encrypted file
function gpg-decrypt() {
  local file="${1:?Usage: gpg-decrypt <file.gpg>}"
  gpg --decrypt "$file"
}

# @description  Encrypt a file for a specific recipient
# @param  $1    string  Recipient key ID or email
# @param  $2    string  File to encrypt
function gpg-encrypt-for() {
  local recipient="${1:?Usage: gpg-encrypt-for <recipient> <file>}"
  local file="${2:?Usage: gpg-encrypt-for <recipient> <file>}"
  gpg --encrypt --recipient "$recipient" --armor "$file"
  log_info "Encrypted for %s: %s.asc" "$recipient" "$file"
}

# @description  Sign a file
# @param  $1    string  File to sign
function gpg-sign() {
  local file="${1:?Usage: gpg-sign <file>}"
  gpg --detach-sign --armor "$file"
  log_info "Signed: %s.asc" "$file"
}

# @description  Verify a signature
# @param  $1    string  Signature file (.asc or .sig)
# @param  $2    string  (optional) Original file
function gpg-verify-file() {
  local sig="${1:?Usage: gpg-verify-file <signature> [file]}"
  local file="${2:-}"
  if [[ -n "$file" ]]; then
    gpg --verify "$sig" "$file"
  else
    gpg --verify "$sig"
  fi
}

# @description  Show GPG configuration info
function gpg-info() {
  printf "\n  🔐 GPG Configuration\n"
  printf "  ═══════════════════════════════════\n\n"
  printf "  GNUPGHOME:  %s\n" "$GNUPGHOME"
  printf "  GPG_TTY:    %s\n" "${GPG_TTY:-not set}"
  printf "  Version:    %s\n" "$(gpg --version 2>/dev/null | head -1)"

  # Symlinks
  if [[ -L "${GNUPGHOME}/gpg.conf" ]]; then
    printf "  gpg.conf:   ✅ → %s\n" "$(readlink "${GNUPGHOME}/gpg.conf" | sed "s|${DOTFILES_DIR}|dotfiles|")"
  else
    printf "  gpg.conf:   ❌ not linked\n"
  fi

  if [[ -L "${GNUPGHOME}/gpg-agent.conf" ]]; then
    printf "  agent.conf: ✅ → %s\n" "$(readlink "${GNUPGHOME}/gpg-agent.conf" | sed "s|${DOTFILES_DIR}|dotfiles|")"
  else
    printf "  agent.conf: ❌ not linked\n"
  fi

  # Agent status
  printf "  Agent PID:  %s\n" "$(pgrep -x gpg-agent 2>/dev/null || echo 'not running')"

  # Pinentry
  local pinentry
  pinentry=$(gpgconf --list-options gpg-agent 2>/dev/null | grep "pinentry-program" | cut -d: -f10)
  printf "  Pinentry:   %s\n" "${pinentry:-default}"

  # Key count
  local secret_count public_count
  secret_count=$(gpg --list-secret-keys 2>/dev/null | grep -c "^sec" || echo "0")
  public_count=$(gpg --list-keys 2>/dev/null | grep -c "^pub" || echo "0")
  printf "  Public:     %s keys\n" "$public_count"
  printf "  Secret:     %s keys\n" "$secret_count"

  # Permissions
  local gnupg_perms
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    gnupg_perms=$(/usr/bin/stat -f '%Lp' "$GNUPGHOME" 2>/dev/null)
  else
    gnupg_perms=$(stat -c '%a' "$GNUPGHOME" 2>/dev/null)
  fi
  if [[ "$gnupg_perms" == "700" ]]; then
    printf "  Perms:      ✅ %s\n" "$gnupg_perms"
  else
    printf "  Perms:      ❌ %s (should be 700)\n" "$gnupg_perms"
  fi

  printf "\n  ═══════════════════════════════════\n\n"
}

# @description  Edit GPG config
function gpg-edit-config() {
  "${EDITOR:-nvim}" "${GPG_SRC_DIR}/gpg.conf"
}

# @description  Edit GPG agent config
function gpg-edit-agent() {
  "${EDITOR:-nvim}" "${GPG_SRC_DIR}/gpg-agent.conf"
}

# @description  Search for a key on keyserver
# @param  $1    string  Email or name to search
function gpg-search() {
  local query="${1:?Usage: gpg-search <email-or-name>}"
  gpg --search-keys "$query"
}

# @description  Refresh all keys from keyserver
function gpg-refresh() {
  log_info "Refreshing keys from keyserver..."
  gpg --refresh-keys 2>/dev/null
  log_info "Keys refreshed"
}

# @description  GPG security audit
function gpg-audit() {
  printf "\n  🔐 GPG Security Audit\n"
  printf "  ═══════════════════════════════════\n\n"

  local issues=0

  # Permissions
  local perms
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    perms=$(/usr/bin/stat -f '%Lp' "$GNUPGHOME" 2>/dev/null)
  else
    perms=$(stat -c '%a' "$GNUPGHOME" 2>/dev/null)
  fi
  if [[ "$perms" == "700" ]]; then
    printf "  ✅ GNUPGHOME permissions: %s\n" "$perms"
  else
    printf "  ❌ GNUPGHOME permissions: %s (should be 700)\n" "$perms"
    issues=$((issues + 1))
  fi

  # GPG_TTY
  if [[ -n "${GPG_TTY:-}" ]]; then
    printf "  ✅ GPG_TTY is set\n"
  else
    printf "  ❌ GPG_TTY not set\n"
    issues=$((issues + 1))
  fi

  # Agent running
  if pgrep -x gpg-agent >/dev/null 2>&1; then
    printf "  ✅ Agent running\n"
  else
    printf "  ⚠️  Agent not running\n"
  fi

  # Config symlinks
  if [[ -L "${GNUPGHOME}/gpg.conf" ]]; then
    printf "  ✅ gpg.conf symlinked\n"
  else
    printf "  ⚠️  gpg.conf not symlinked\n"
  fi

  # Key algorithms
  gpg --list-secret-keys --keyid-format 0xlong 2>/dev/null | grep "^sec" | while read -r line; do
    local algo=$(echo "$line" | awk '{print $2}' | cut -d/ -f1)
    local keyid=$(echo "$line" | awk '{print $2}' | cut -d/ -f2)
    case "$algo" in
      rsa4096|ed25519)
        printf "  ✅ Key %s: %s (strong)\n" "$keyid" "$algo" ;;
      rsa2048)
        printf "  ⚠️  Key %s: %s (consider upgrading to 4096)\n" "$keyid" "$algo"
        issues=$((issues + 1)) ;;
      rsa1024|dsa*)
        printf "  ❌ Key %s: %s (WEAK — replace immediately)\n" "$keyid" "$algo"
        issues=$((issues + 1)) ;;
      *)
        printf "  ℹ️  Key %s: %s\n" "$keyid" "$algo" ;;
    esac
  done

  printf "\n  ═══════════════════════════════════\n"
  if (( issues == 0 )); then
    printf "  ✅ No issues found\n"
  else
    printf "  ⚠️  %d issue(s)\n" "$issues"
  fi
  printf "  ═══════════════════════════════════\n\n"
}

log_debug "gpg configured"
