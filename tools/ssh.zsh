#!/usr/bin/env zsh
# ============================================================================
# @file        tools/ssh.zsh
# @description SSH integration — fully auto-configured, cross-platform.
#              Dynamic key management: discovers all id_* keys automatically.
#              Modular config via ~/.ssh/config.d/ with auto-generated files.
#              No hardcoded key paths — adapts to whatever keys exist.
#
#              Auto-creates on first run:
#              - ~/.ssh/                      (700)
#              - ~/.ssh/config                (includes config.d/*.conf)
#              - ~/.ssh/config.d/             (modular configs)
#              - ~/.ssh/config.d/00-defaults  (global SSH options)
#              - ~/.ssh/config.d/10-github    (symlink from dotfiles)
#              - ~/.ssh/config.d/20-work      (private template)
#              - ~/.ssh/config.d/30-personal  (private template)
#              - ~/.ssh/config.d/90-fallback  (GitLab, Bitbucket, etc.)
#              - ~/.ssh/sockets/              (for ControlPath multiplexing)
#
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-16
# @version     2.0.0
#
# @depends     lib/logging.zsh, lib/tool-check.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_TOOLS_SSH_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_SSH_LOADED=1

log_debug "Configuring ssh"

# ============================================================================
# Constants (directories only — NO hardcoded key paths)
# ============================================================================

readonly SSH_DIR="${HOME}/.ssh"
readonly SSH_CONF_DIR="${SSH_DIR}/config.d"
readonly SSH_SOCKETS_DIR="${SSH_DIR}/sockets"
readonly SSH_CONFIG="${SSH_DIR}/config"

# ============================================================================
# Dynamic Key Discovery
# ============================================================================

# @description  Discover all SSH private keys in ~/.ssh/ dynamically.
#               Matches all id_* files that are not .pub extensions.
# @return       Key paths, one per line
function _ssh_discover_keys() {
  local key
  for key in "${SSH_DIR}"/id_*(N); do
    [[ -f "$key" ]]      || continue
    [[ "$key" == *.pub ]] && continue
    echo "$key"
  done
}

# @description  Get the count of discovered SSH keys
# @return       Integer count
function _ssh_key_count() {
  _ssh_discover_keys | wc -l | tr -d ' '
}

# ============================================================================
# Auto-Setup — Runs on every shell startup (idempotent)
# ============================================================================

# @description  Master SSH auto-setup. Creates directories, config files,
#               symlinks, and fixes permissions. Safe to run repeatedly.
# @return       void
function _ssh_auto_setup() {

  # ── 1. Create directories (silently) ────────────────────────────────
  [[ -d "$SSH_DIR" ]]         || { mkdir -p "$SSH_DIR"         && chmod 700 "$SSH_DIR"; }
  [[ -d "$SSH_CONF_DIR" ]]   || { mkdir -p "$SSH_CONF_DIR"    && chmod 700 "$SSH_CONF_DIR"; }
  [[ -d "$SSH_SOCKETS_DIR" ]] || { mkdir -p "$SSH_SOCKETS_DIR" && chmod 700 "$SSH_SOCKETS_DIR"; }

  # ── 2. Master config (includes config.d/*.conf) ─────────────────────
  # Only create if missing OR if it doesn't have our Include directive
  if [[ ! -f "$SSH_CONFIG" ]]; then
    cat > "$SSH_CONFIG" << 'EOF'
# SSH Configuration — Auto-managed by dotfiles
Include config.d/*.conf
EOF
    chmod 600 "$SSH_CONFIG"
  elif ! grep -q "config.d/\*.conf" "$SSH_CONFIG" 2>/dev/null; then
    # Backup then prepend Include
    cp -f "$SSH_CONFIG" "${SSH_CONFIG}.bak" 2>/dev/null
    local old_content
    old_content=$(grep -v "^Include.*config\.d" "$SSH_CONFIG" 2>/dev/null | grep -v "^$" | head -100)
    cat > "$SSH_CONFIG" << 'EOF'
# SSH Configuration — Auto-managed by dotfiles
Include config.d/*.conf
EOF
    [[ -n "$old_content" ]] && printf "\n%s\n" "$old_content" >> "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
  fi

  # ── 3. Symlink PUBLIC configs ──────────────────────────────────────
  local src_conf_dir="${DOTFILES_DIR}/config/ssh/config.d"
  if [[ -d "$src_conf_dir" ]]; then
    local conf_file
    for conf_file in "${src_conf_dir}"/*.conf(N); do
      local name=$(basename "$conf_file")
      local target="${SSH_CONF_DIR}/${name}"
      if [[ ! -L "$target" ]] || [[ "$(readlink "$target" 2>/dev/null)" != "$conf_file" ]]; then
        rm -f "$target" >/dev/null 2>&1
        ln -sf "$conf_file" "$target" >/dev/null 2>&1
      fi
    done
  fi

  # ── 4. Link ALL private configs from local/ (dynamic) ──────────────
  # Any file matching local/ssh_config_*.conf is auto-linked to config.d/
  # Naming convention: local/ssh_config_NAME.conf → config.d/??-NAME.conf
  local _local_dir="${DOTFILES_DIR}/local"
  if [[ -d "$_local_dir" ]]; then
    local _lf _lname _ltarget _lpriority
    for _lf in "${_local_dir}"/ssh_config_*.conf(N); do
      [[ -f "$_lf" ]] || continue

      # Extract NAME from ssh_config_NAME.conf
      _lname=$(basename "$_lf" .conf)
      _lname="${_lname#ssh_config_}"

      # Assign priority based on name
      case "$_lname" in
        colima|orbstack|docker|podman) _lpriority="15" ;;
        work)                          _lpriority="20" ;;
        personal)                      _lpriority="30" ;;
        homelab|proxmox|vps)           _lpriority="40" ;;
        *)                             _lpriority="50" ;;
      esac

      _ltarget="${SSH_CONF_DIR}/${_lpriority}-${_lname}.conf"

      # Create symlink if not already correct
      if [[ ! -L "$_ltarget" ]] || [[ "$(readlink "$_ltarget" 2>/dev/null)" != "$_lf" ]]; then
        rm -f "$_ltarget" >/dev/null 2>&1
        ln -sf "$_lf" "$_ltarget" >/dev/null 2>&1
      fi
    done
  fi

  # ── 5. Fix permissions (background, silent) ─────────────────────────
  {
    chmod 700 "$SSH_DIR" "$SSH_CONF_DIR" "$SSH_SOCKETS_DIR" 2>/dev/null
    find "$SSH_CONF_DIR" -type f -exec chmod 600 {} + 2>/dev/null
    find "$SSH_DIR" -maxdepth 1 -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} + 2>/dev/null
    find "$SSH_DIR" -maxdepth 1 -type f -name "*.pub" -exec chmod 644 {} + 2>/dev/null
    [[ -f "${SSH_DIR}/config" ]] && chmod 600 "${SSH_DIR}/config" 2>/dev/null
    [[ -f "${SSH_DIR}/authorized_keys" ]] && chmod 600 "${SSH_DIR}/authorized_keys" 2>/dev/null
    [[ -f "${SSH_DIR}/known_hosts" ]] && chmod 644 "${SSH_DIR}/known_hosts" 2>/dev/null
  } &!

  # ── 6. Auto-load keys (background, NEVER blocks) ───────────────────
  # On macOS, ssh-add with --apple-use-keychain loads keys silently
  # from the macOS Keychain without prompting for passphrase.
  # On Linux, we skip encrypted keys entirely to avoid blocking.
  if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
    {
      local _key _fp _ssh_add_cmd="ssh-add"
      # macOS: use native ssh-add for Keychain support
      [[ "$ZSH_PLATFORM" == "darwin" ]] && _ssh_add_cmd="/usr/bin/ssh-add"

      local _loaded
      _loaded=$($_ssh_add_cmd -l 2>/dev/null || echo "")

      for _key in "${SSH_DIR}"/id_*(N); do
        [[ -f "$_key" ]]      || continue
        [[ "$_key" == *.pub ]] && continue

        _fp=$(ssh-keygen -lf "$_key" 2>/dev/null | awk '{print $2}')
        [[ -z "$_fp" ]] && continue
        echo "$_loaded" | grep -q "$_fp" 2>/dev/null && continue

        case "$ZSH_PLATFORM" in
          darwin)
            $_ssh_add_cmd --apple-use-keychain "$_key" </dev/null >/dev/null 2>&1 || true
            ;;
          *)
            if ! head -5 "$_key" 2>/dev/null | grep -qi "encrypted"; then
              $_ssh_add_cmd "$_key" </dev/null >/dev/null 2>&1 || true
            fi
            ;;
        esac
      done
    } &!
  fi

  # ── Cleanup macOS artifacts ─────────────────────────────────────────
  # rm -f "${SSH_DIR}/environment-" 2>/dev/null
}

_ssh_auto_setup

# ============================================================================
# SSH Config Management
# ============================================================================

# @description  Show all SSH config files and their status
# @return       void
function ssh-config-info() {
  printf "\n  🔐 SSH Configuration\n"
  printf "  ═══════════════════════════════════\n\n"
  printf "  Master:  %s\n" "$SSH_CONFIG"
  printf "  Configs: %s\n\n" "$SSH_CONF_DIR"

  printf "  %-25s %-10s %-8s %s\n" "FILE" "TYPE" "HOSTS" "SOURCE"
  printf "  %-25s %-10s %-8s %s\n" "─────────────────────────" "──────────" "────────" "────────────────"

  local f
  for f in "${SSH_CONF_DIR}"/*.conf(N); do
    local name=$(basename "$f")
    local type="local"
    local hosts=$(grep -c "^Host " "$f" 2>/dev/null || echo "0")
    local source=""
    [[ -L "$f" ]] && { type="symlink"; source="→ $(readlink "$f" | sed "s|${HOME}|~|" | sed "s|${DOTFILES_DIR}|dotfiles|")"; }
    printf "  %-25s %-10s %-8s %s\n" "$name" "$type" "$hosts" "$source"
  done

  printf "\n  Keys:    %s found\n" "$(_ssh_key_count)"
  printf "  Agent:   "
  if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
    printf "✅ running (%s loaded)\n" "$(ssh-add -l 2>/dev/null | wc -l | tr -d ' ')"
  else
    printf "❌ not running\n"
  fi
  printf "\n  ═══════════════════════════════════\n\n"
}

# @description  Edit a SSH config file
# @param  $1    string  (optional) Config name
# @return       void
function ssh-config-edit() {
  local name="${1:-}"
  local file

  if [[ -z "$name" ]]; then
    if has "fzf"; then
      file=$(find "$SSH_CONF_DIR" -name "*.conf" 2>/dev/null | \
        fzf --header='Select config to edit' --height='40%' --border \
            --preview='cat {} | head -30')
    else
      ssh-config-info
      printf "  Name: "; read -r name
    fi
  fi

  if [[ -z "$file" ]] && [[ -n "$name" ]]; then
    case "$name" in
      defaults|00) file="${SSH_CONF_DIR}/00-defaults.conf" ;;
      github|10)   file="${SSH_CONF_DIR}/10-github.conf" ;;
      work|20)     file="${SSH_CONF_DIR}/20-work.conf" ;;
      personal|30) file="${SSH_CONF_DIR}/30-personal.conf" ;;
      fallback|90) file="${SSH_CONF_DIR}/90-fallback.conf" ;;
      *)           file="${SSH_CONF_DIR}/${name}" ;;
    esac
  fi

  [[ -n "$file" && -e "$file" ]] || { log_error "Not found: %s" "${name:-}"; return 1; }
  [[ -L "$file" ]] && file=$(readlink -f "$file" 2>/dev/null || readlink "$file")
  "${EDITOR:-nvim}" "$file"
}

# @description  Add a host entry interactively with dynamic key selection
# @param  $1    string  (optional) Target: work | personal
# @return       void
function ssh-config-add() {
  local target="${1:-personal}"
  local file

  case "$target" in
    work)     file="${SSH_CONF_DIR}/20-work.conf" ;;
    personal) file="${SSH_CONF_DIR}/30-personal.conf" ;;
    *)        file="${SSH_CONF_DIR}/${target}" ;;
  esac

  [[ -f "$file" ]] || { log_error "Config not found: %s" "$file"; return 1; }
  [[ -L "$file" ]] && file=$(readlink -f "$file" 2>/dev/null || readlink "$file")

  local host hostname user port identity

  printf "  Host alias: "; read -r host
  [[ -z "$host" ]] && return 0

  printf "  HostName (IP/domain): "; read -r hostname
  [[ -z "$hostname" ]] && return 0

  printf "  User [%s]: " "$(whoami)"; read -r user
  user="${user:-$(whoami)}"

  printf "  Port [22]: "; read -r port
  port="${port:-22}"

  # -- Dynamic key selection
  local key_count=$(_ssh_key_count)
  if (( key_count > 0 )); then
    if has "fzf"; then
      identity=$(_ssh_discover_keys | while read -r k; do
        local name=$(basename "$k")
        local fp=$(ssh-keygen -lf "$k" 2>/dev/null | awk '{print $2}')
        printf "%s\t%s (%s)\n" "$k" "$name" "$fp"
      done | fzf --header='Select IdentityFile' --height='40%' --border \
                  --delimiter='\t' --with-nth=2 | cut -f1)
    else
      printf "  Available keys:\n"
      local i=1
      _ssh_discover_keys | while read -r k; do
        printf "    %d) %s\n" "$i" "$(basename "$k")"
        i=$((i + 1))
      done
      printf "  Key number [1]: "; local choice; read -r choice
      identity=$(_ssh_discover_keys | sed -n "${choice:-1}p")
    fi
  fi

  identity="${identity:-~/.ssh/id_ed25519}"
  identity="${identity/#${HOME}/~}"

  cat >> "$file" << EOF

Host ${host}
  HostName ${hostname}
  User ${user}
  Port ${port}
  IdentityFile ${identity}
EOF

  log_info "Added '%s' → %s" "$host" "$(basename "$file")"
}

# @description  Test SSH connectivity to all configured hosts
# @return       void
function ssh-config-test() {
  printf "\n  🔐 SSH Connection Test\n"
  printf "  ─────────────────────────────────\n\n"

  local hosts
  hosts=$(grep "^Host " "${SSH_CONF_DIR}"/*.conf 2>/dev/null | \
    awk '{print $2}' | grep -v '\*' | sort -u)

  [[ -z "$hosts" ]] && { printf "  No hosts configured\n\n"; return 0; }

  echo "$hosts" | while read -r host; do
    [[ -z "$host" ]] && continue
    ssh-test "$host"
  done
  printf "\n"
}

# @description  Rebuild SSH config from scratch
# @return       void
function ssh-config-rebuild() {
  log_info "Rebuilding SSH config..."
  [[ -f "$SSH_CONFIG" ]] && cp "$SSH_CONFIG" "${SSH_CONFIG}.bak.$(date +%s)"
  rm -f "$SSH_CONFIG"
  _ssh_auto_setup
  log_info "SSH config rebuilt"
}

# ============================================================================
# SSH Key Management — Fully Dynamic
# ============================================================================

# @description  List all SSH keys with fingerprints, types, and agent status
# @return       void
function ssh-keys() {
  printf "\n  🔑 SSH Keys\n"
  printf "  ═══════════════════════════════════\n\n"

  local loaded=""
  [[ -n "${SSH_AUTH_SOCK:-}" ]] && loaded=$(ssh-add -l 2>/dev/null || echo "")

  local count=0
  _ssh_discover_keys | while read -r key; do
    count=$((count + 1))
    local name=$(basename "$key")
    local fp=$(ssh-keygen -lf "$key" 2>/dev/null)
    local type=$(echo "$fp" | awk '{print $NF}' | tr -d '()')
    local bits=$(echo "$fp" | awk '{print $1}')
    local fingerprint=$(echo "$fp" | awk '{print $2}')

    printf "  🔑 %s\n" "$name"
    printf "     Type:        %s (%s)\n" "$type" "$bits"
    printf "     Fingerprint: %s\n" "$fingerprint"

    if [[ -n "$loaded" ]]; then
      echo "$loaded" | grep -q "$fingerprint" 2>/dev/null && \
        printf "     Agent:       ✅ loaded\n" || printf "     Agent:       ❌ not loaded\n"
    fi

    [[ -f "${key}.pub" ]] && printf "     Public:      %s.pub\n" "$name" || \
      printf "     Public:      ⚠️  missing\n"
    printf "\n"
  done

  (( count == 0 )) && { printf "  No SSH keys found\n  Generate: ssh-key-generate\n\n"; }
  printf "  ═══════════════════════════════════\n\n"
}

# @description  Generate a new SSH key pair with maximum security.
#               Uses ed25519 with high KDF rounds and mandatory passphrase.
#               Auto-adds to macOS Keychain on Darwin.
# @param  $1    string  (optional) Key name (without path)
# @return       void
function ssh-key-generate() {
  local key_name="${1:-}"
  local key_type="ed25519"
  local kdf_rounds=200

  printf "\n  🔐 SSH Key Generator (Security-Hardened)\n"
  printf "  ═══════════════════════════════════\n\n"

  # ── Key name selection ──────────────────────────────────────────────
  if [[ -z "$key_name" ]]; then
    if has "fzf"; then
      key_name=$(printf "id_personal_ed25519\nid_work_ed25519\nid_deploy_ed25519\nid_github_ed25519\nid_fallback_ed25519\nid_server_ed25519\nid_ed25519\ncustom" | \
        fzf --header='🔑 Select key name' --height='40%' --border)
    else
      printf "  Suggested names:\n"
      printf "    1) id_personal_ed25519   — Personal servers\n"
      printf "    2) id_work_ed25519       — Work/corporate\n"
      printf "    3) id_deploy_ed25519     — CI/CD deployments\n"
      printf "    4) id_github_ed25519     — GitHub\n"
      printf "    5) id_server_ed25519     — Generic server\n"
      printf "    6) id_ed25519            — Default\n"
      printf "    7) Custom name\n\n"
      printf "  Choice [1-7]: "
      read -r choice
      case "$choice" in
        1) key_name="id_personal_ed25519" ;;
        2) key_name="id_work_ed25519" ;;
        3) key_name="id_deploy_ed25519" ;;
        4) key_name="id_github_ed25519" ;;
        5) key_name="id_server_ed25519" ;;
        6) key_name="id_ed25519" ;;
        7) printf "  Key name: "; read -r key_name ;;
        *) return 0 ;;
      esac
    fi
    [[ -z "$key_name" ]] && return 0
  fi

  # ── Handle custom name ──────────────────────────────────────────────
  if [[ "$key_name" == "custom" ]]; then
    printf "  Custom name (e.g., id_myproject_ed25519): "
    read -r key_name
    [[ -z "$key_name" ]] && return 0
  fi

  # ── Ensure id_ prefix ──────────────────────────────────────────────
  [[ "$key_name" != id_* ]] && key_name="id_${key_name}"

  local key_path="${SSH_DIR}/${key_name}"

  # ── Check if key already exists ─────────────────────────────────────
  if [[ -f "$key_path" ]]; then
    printf "  ⚠️  Key already exists: %s\n" "$key_name"
    printf "  Overwrite? [y/N]: "
    read -rk1 confirm; echo
    [[ "${confirm:l}" != "y" ]] && return 0
  fi

  # ── Comment — descriptive and traceable ─────────────────────────────
  local default_comment
  local usage_label="${key_name#id_}"
  usage_label="${usage_label%_ed25519}"
  usage_label="${usage_label%_ecdsa}"
  usage_label="${usage_label%_rsa}"
  default_comment="${usage_label}@$(hostname -s)-$(date +%Y%m%d)"

  printf "  Comment [%s]: " "$default_comment"
  read -r comment
  comment="${comment:-$default_comment}"

  # ── KDF rounds ──────────────────────────────────────────────────────
  printf "  KDF rounds [%d]: " "$kdf_rounds"
  read -r custom_rounds
  [[ -n "$custom_rounds" ]] && kdf_rounds="$custom_rounds"

  # ── Summary before generation ───────────────────────────────────────
  printf "\n  ─────────────────────────────────\n"
  printf "  Name:       %s\n" "$key_name"
  printf "  Path:       %s\n" "$key_path"
  printf "  Algorithm:  %s\n" "$key_type"
  printf "  KDF rounds: %s\n" "$kdf_rounds"
  printf "  Comment:    %s\n" "$comment"
  printf "  ─────────────────────────────────\n\n"
  printf "  ⚠️  You WILL be asked for a passphrase.\n"
  printf "  Use a STRONG passphrase (20+ chars, mixed case, numbers, symbols).\n"
  printf "  The passphrase protects the key if the file is compromised.\n\n"
  printf "  Generate? [Y/n]: "
  read -rk1 go; echo
  [[ "${go:l}" == "n" ]] && return 0

  # ── Generate the key ────────────────────────────────────────────────
  printf "\n"
  ssh-keygen \
    -t "$key_type" \
    -a "$kdf_rounds" \
    -C "$comment" \
    -f "$key_path"

  local rc=$?
  if (( rc != 0 )); then
    log_error "Key generation failed"
    return 1
  fi

  # ── Set permissions ─────────────────────────────────────────────────
  chmod 600 "$key_path"
  chmod 644 "${key_path}.pub"

  # ── macOS Keychain integration ──────────────────────────────────────
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    printf "\n  Add to macOS Keychain? (stores passphrase securely) [Y/n]: "
    read -rk1 kc; echo
    if [[ "${kc:l}" != "n" ]]; then
        /usr/bin/ssh-add --apple-use-keychain "$key_path" 2>/dev/null && \
        log_info "Key added to macOS Keychain" || \
        log_warn "Failed to add to Keychain (add manually with: ssh-add --apple-use-keychain %s)" "$key_path"
    fi
  elif [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
    printf "\n  Load into SSH agent? [Y/n]: "
    read -rk1 load; echo
    [[ "${load:l}" != "n" ]] && ssh-add "$key_path" 2>/dev/null
  fi

  # ── Display public key ──────────────────────────────────────────────
  printf "\n  ✅ Key generated successfully!\n\n"
  printf "  📋 Public key:\n\n"
  cat "${key_path}.pub"
  printf "\n"

  # ── Copy to clipboard ──────────────────────────────────────────────
  case "$ZSH_PLATFORM" in
    darwin)
      cat "${key_path}.pub" | pbcopy
      log_info "Public key copied to clipboard"
      ;;
    linux)
      if has "xclip"; then
        cat "${key_path}.pub" | xclip -selection clipboard
        log_info "Public key copied to clipboard"
      elif has "wl-copy"; then
        cat "${key_path}.pub" | wl-copy
        log_info "Public key copied to clipboard"
      fi
      ;;
    wsl)
      cat "${key_path}.pub" | clip.exe
      log_info "Public key copied to clipboard"
      ;;
  esac

  # ── Fingerprint ────────────────────────────────────────────────────
  printf "\n  🔑 Fingerprint:\n"
  ssh-keygen -lf "$key_path" 2>/dev/null | sed 's/^/     /'

  # ── Security reminder ──────────────────────────────────────────────
  printf "\n  ─────────────────────────────────\n"
  printf "  📌 Next steps:\n"
  printf "     1. Add the public key to your target service\n"
  printf "     2. Backup: ssh-backup\n"
  printf "     3. Verify: ssh-audit\n"
  printf "  ─────────────────────────────────\n\n"
}

# @description  Delete an SSH key pair (interactive FZF selection)
# @param  $1    string  (optional) Key name
# @return       void
function ssh-key-delete() {
  local key_path

  if [[ -n "$1" ]]; then
    key_path="${SSH_DIR}/${1}"
  elif has "fzf"; then
    key_path=$(_ssh_discover_keys | while read -r k; do
      printf "%s\t%s (%s)\n" "$k" "$(basename "$k")" "$(ssh-keygen -lf "$k" 2>/dev/null | awk '{print $2}')"
    done | fzf --header='Select key to DELETE' --height='40%' --border \
                --delimiter='\t' --with-nth=2 | cut -f1)
  else
    ssh-keys
    printf "  Key name to delete: "; local name; read -r name
    key_path="${SSH_DIR}/${name}"
  fi

  [[ -z "$key_path" || ! -f "$key_path" ]] && { log_error "Key not found"; return 1; }

  printf "  ⚠️  Delete %s (IRREVERSIBLE)? [y/N]: " "$(basename "$key_path")"
  read -rk1 confirm; echo

  if [[ "${confirm:l}" == "y" ]]; then
    ssh-add -d "$key_path" 2>/dev/null
    rm -f "$key_path" "${key_path}.pub"
    log_info "Deleted: %s" "$(basename "$key_path")"
  fi
}

# @description  Copy a public key to clipboard (interactive FZF selection)
# @param  $1    string  (optional) Key name
# @return       void
function ssh-key-copy() {
  local pub_key

  if [[ -n "$1" ]]; then
    pub_key="${SSH_DIR}/${1}.pub"
    [[ ! -f "$pub_key" ]] && pub_key="${SSH_DIR}/${1}"
  elif has "fzf"; then
    pub_key=$(find "$SSH_DIR" -maxdepth 1 -name "id_*.pub" 2>/dev/null | \
      fzf --header='Select public key' --height='40%' --border --preview='cat {}')
  else
    pub_key=$(find "$SSH_DIR" -maxdepth 1 -name "id_*.pub" 2>/dev/null | head -1)
  fi

  [[ -z "$pub_key" || ! -f "$pub_key" ]] && { log_error "Public key not found"; return 1; }

  case "$ZSH_PLATFORM" in
    darwin)  cat "$pub_key" | pbcopy ;;
    linux)   has "xclip" && cat "$pub_key" | xclip -selection clipboard || \
             has "wl-copy" && cat "$pub_key" | wl-copy ;;
    wsl)     cat "$pub_key" | clip.exe ;;
    *)       cat "$pub_key"; printf "\n  (Copy manually)\n"; return 0 ;;
  esac

  log_info "Copied: %s" "$(basename "$pub_key")"
  cat "$pub_key"
}

# @description  Load all discovered SSH keys into the agent
# @return       void
function ssh-keys-load() {
  if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
    eval "$(ssh-agent -s)" >/dev/null
    log_info "SSH agent started"
  fi

  local loaded=0
  _ssh_discover_keys | while read -r key; do
    ssh-add "$key" 2>/dev/null && {
      log_info "Loaded: %s" "$(basename "$key")"
      loaded=$((loaded + 1))
    }
  done

  (( loaded == 0 )) && log_warn "No keys to load"
}

# @description  Unload all SSH keys from the agent
# @return       void
function ssh-keys-unload() {
  ssh-add -D 2>/dev/null
  log_info "All keys removed from agent"
}

# @description  Fix all SSH file permissions
# @return       void
function ssh-fix-perms() {
  chmod 700 "$SSH_DIR" "$SSH_CONF_DIR" "$SSH_SOCKETS_DIR" 2>/dev/null
  find "$SSH_CONF_DIR" -type f -exec chmod 600 {} + 2>/dev/null
  find "$SSH_DIR" -maxdepth 1 -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} + 2>/dev/null
  find "$SSH_DIR" -maxdepth 1 -type f -name "*.pub" -exec chmod 644 {} + 2>/dev/null
  [[ -f "${SSH_DIR}/config" ]] && chmod 600 "${SSH_DIR}/config" 2>/dev/null
  [[ -f "${SSH_DIR}/authorized_keys" ]] && chmod 600 "${SSH_DIR}/authorized_keys" 2>/dev/null
  [[ -f "${SSH_DIR}/known_hosts" ]] && chmod 644 "${SSH_DIR}/known_hosts" 2>/dev/null
  log_info "SSH permissions fixed"
}

# @description  Show SSH agent status and loaded keys
# @return       void
function ssh-agent-info() {
  printf "\n  🔐 SSH Agent\n"
  printf "  ─────────────────────────────────\n"
  if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
    printf "  Status:  ✅ running\n"
    printf "  Socket:  %s\n" "$SSH_AUTH_SOCK"
    printf "  Keys:\n"
    ssh-add -l 2>/dev/null | while read -r line; do
      printf "    • %s\n" "$line"
    done
  else
    printf "  Status:  ❌ not running\n"
    printf "  Start:   eval \"\$(ssh-agent -s)\"\n"
  fi
  printf "  ─────────────────────────────────\n\n"
}

# @description  Quick SSH connectivity test to a specific host
# @param  $1    string  (optional) Host — if empty, tests all hosts
# @return       void
function ssh-test() {
  local host="${1:-}"
  if [[ -z "$host" ]]; then
    ssh-config-test
    return
  fi

  printf "  %-25s " "$host"

  local result
  case "$host" in
    github.com|github-*|gitlab.com|bitbucket.org|codeberg.org|sr.ht)
      result=$(ssh -T -o ConnectTimeout=5 "$host" 2>&1)
      if echo "$result" | grep -qi "successfully authenticated\|welcome"; then
        local user
        user=$(echo "$result" | grep -oE 'Hi [^!]+' 2>/dev/null | sed 's/Hi //')
        [[ -n "$user" ]] && printf "✅ OK (%s)\n" "$user" || printf "✅ OK\n"
      elif echo "$result" | grep -qi "permission denied"; then
        printf "🔑 Auth failed\n"
      elif echo "$result" | grep -qi "could not resolve"; then
        printf "❌ DNS failed\n"
      elif echo "$result" | grep -qi "timed out\|connection refused"; then
        printf "⏱  Timeout\n"
      else
        printf "❌ %s\n" "$(echo "$result" | head -1 | cut -c1-60)"
      fi
      ;;
    *)
      result=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" true 2>&1)
      if [ $? -eq 0 ]; then
        printf "✅ OK\n"
      elif echo "$result" | grep -qi "permission denied"; then
        printf "🔑 Auth failed\n"
      elif echo "$result" | grep -qi "could not resolve"; then
        printf "❌ DNS\n"
      elif echo "$result" | grep -qi "timed out\|connection refused"; then
        printf "⏱  Timeout\n"
      else
        printf "❌ %s\n" "$(echo "$result" | tail -1 | cut -c1-60)"
      fi
      ;;
  esac
}

# ============================================================================
# SSH Key Backup — Encrypted backup/restore
# ============================================================================

# @description  Create an encrypted backup of all SSH keys.
#               Uses age (preferred) or GPG for encryption.
#               Backup is stored outside the dotfiles repo.
# @param  $1    string  (optional) Output directory (default: ~/.ssh/backups)
# @return       void
function ssh-backup() {
  local backup_dir="${1:-${HOME}/.ssh/backups}"
  local timestamp=$(date +%Y%m%d_%H%M%S)

  mkdir -p "$backup_dir" 2>/dev/null
  chmod 700 "$backup_dir" 2>/dev/null

  # -- Collect private keys
  local -a keys_to_backup=()
  local key
  for key in "${SSH_DIR}"/id_*(N); do
    [[ -f "$key" ]] || continue
    keys_to_backup+=("$key")
    [[ -f "${key}.pub" ]] && keys_to_backup+=("${key}.pub")
  done

  if (( ${#keys_to_backup} == 0 )); then
    log_warn "No SSH keys found to backup"
    return 0
  fi

  printf "\n  🔐 SSH Key Backup\n"
  printf "  ─────────────────────────────────\n"
  printf "  Keys:   %d files\n" "${#keys_to_backup}"
  printf "  Output: %s\n\n" "$backup_dir"

  # -- Method 1: age (preferred — modern, simple)
  if has "age"; then
    local backup_file="${backup_dir}/ssh-keys-${timestamp}.tar.age"
    printf "  Encrypting with age (you'll set a passphrase)...\n\n"
    tar cf - "${keys_to_backup[@]}" 2>/dev/null | age -p -o "$backup_file"

    if [[ -f "$backup_file" ]]; then
      chmod 600 "$backup_file"
      log_info "Backup created: %s" "$backup_file"
      printf "\n  Restore with: ssh-restore %s\n\n" "$backup_file"
    else
      log_error "Backup failed"
    fi
    return
  fi

  # -- Method 2: GPG
  if has "gpg"; then
    local backup_file="${backup_dir}/ssh-keys-${timestamp}.tar.gpg"
    printf "  Encrypting with GPG (you'll set a passphrase)...\n\n"
    tar cf - "${keys_to_backup[@]}" 2>/dev/null | gpg --symmetric --cipher-algo AES256 -o "$backup_file"

    if [[ -f "$backup_file" ]]; then
      chmod 600 "$backup_file"
      log_info "Backup created: %s" "$backup_file"
      printf "\n  Restore with: ssh-restore %s\n\n" "$backup_file"
    else
      log_error "Backup failed"
    fi
    return
  fi

  # -- Method 3: zip with password (fallback)
  local backup_file="${backup_dir}/ssh-keys-${timestamp}.zip"
  printf "  Encrypting with zip...\n\n"
  zip -ej --password "$(printf 'Passphrase: ' >&2; read -rs p; echo "$p")" \
    "$backup_file" "${keys_to_backup[@]}" >/dev/null 2>&1

  if [[ -f "$backup_file" ]]; then
    chmod 600 "$backup_file"
    log_info "Backup created: %s" "$backup_file"
  else
    log_error "Backup failed"
  fi
}

# @description  Restore SSH keys from an encrypted backup.
# @param  $1    string  Backup file path
# @return       void
function ssh-restore() {
  local backup_file="${1:-}"

  if [[ -z "$backup_file" ]]; then
    local backup_dir="${HOME}/.ssh/backups"
    if has "fzf" && [[ -d "$backup_dir" ]]; then
      backup_file=$(find "$backup_dir" -type f \( -name "*.age" -o -name "*.gpg" -o -name "*.zip" \) 2>/dev/null | \
        sort -r | fzf --header='Select backup to restore' --height='40%' --border)
    else
      log_error "Usage: ssh-restore <backup-file>"
      [[ -d "$backup_dir" ]] && { printf "  Available backups:\n"; ls -1t "$backup_dir" 2>/dev/null | head -5 | sed 's/^/    /'; printf "\n"; }
      return 1
    fi
  fi

  [[ -z "$backup_file" || ! -f "$backup_file" ]] && { log_error "Backup not found"; return 1; }

  printf "\n  🔐 SSH Key Restore\n"
  printf "  ─────────────────────────────────\n"
  printf "  From: %s\n\n" "$backup_file"
  printf "  ⚠️  This will overwrite existing keys with same names!\n"
  printf "  Continue? [y/N]: "
  read -rk1 confirm; echo
  [[ "${confirm:l}" != "y" ]] && return 0

  # -- Detect format and decrypt
  case "$backup_file" in
    *.age)
      if has "age"; then
        age -d "$backup_file" | tar xf - -C / 2>/dev/null
        log_info "Keys restored from age backup"
      else
        log_error "age not installed (brew install age)"
        return 1
      fi
      ;;
    *.gpg)
      if has "gpg"; then
        gpg -d "$backup_file" 2>/dev/null | tar xf - -C / 2>/dev/null
        log_info "Keys restored from GPG backup"
      else
        log_error "gpg not installed"
        return 1
      fi
      ;;
    *.zip)
      unzip -o "$backup_file" -d "${SSH_DIR}/" >/dev/null 2>&1
      log_info "Keys restored from zip backup"
      ;;
    *)
      log_error "Unknown backup format: %s" "${backup_file##*.}"
      return 1
      ;;
  esac

  # -- Fix permissions after restore
  ssh-fix-perms
  log_info "Permissions fixed"

  # -- Reload into agent
  printf "  Load restored keys? [Y/n]: "
  read -rk1 load; echo
  [[ "${load:l}" != "n" ]] && ssh-keys-load
}

# @description  List available SSH key backups
# @return       void
function ssh-backup-list() {
  local backup_dir="${HOME}/.ssh/backups"

  printf "\n  🔐 SSH Key Backups\n"
  printf "  ─────────────────────────────────\n"
  printf "  Location: %s\n\n" "$backup_dir"

  if [[ -d "$backup_dir" ]]; then
    local f size date_str
    find "$backup_dir" -type f \( -name "*.age" -o -name "*.gpg" -o -name "*.zip" \) 2>/dev/null | \
      sort -r | while read -r f; do
        local name=$(basename "$f")
        local ext="${name##*.}"
        if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
          size=$(/usr/bin/stat -f%z "$f" 2>/dev/null)
          date_str=$(/usr/bin/stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$f" 2>/dev/null)
        else
          size=$(stat -c%s "$f" 2>/dev/null)
          date_str=$(stat -c '%y' "$f" 2>/dev/null | cut -d. -f1)
        fi

        # Human-readable size
        if (( ${size:-0} > 1048576 )); then
          size="$((size / 1048576))MB"
        elif (( ${size:-0} > 1024 )); then
          size="$((size / 1024))KB"
        else
          size="${size}B"
        fi

        local method
        case "$ext" in
          age) method="age" ;;
          gpg) method="gpg" ;;
          zip) method="zip" ;;
        esac

        printf "    %b%b%b  %-40s %b%5s%b  %b%s%b  %b%s%b\n" \
          "$C_SUCCESS" "$I_SHIELD" "$S_RESET" "$name" \
          "$C_SUBTEXT" "$size" "$S_RESET" \
          "$C_OVERLAY" "${date_str:-?}" "$S_RESET" \
          "$C_MUTED" "$method" "$S_RESET"
      done

    local count
    count=$(find "$backup_dir" -type f \( -name "*.age" -o -name "*.gpg" -o -name "*.zip" \) 2>/dev/null | wc -l | tr -d ' ')
    printf "\n  Total: %s backups\n" "$count"
  else
    printf "  No backups found\n"
    printf "  Create with: ssh-backup\n"
  fi
  printf "  ─────────────────────────────────\n\n"
}

# @description  Verify SSH key health: permissions, passphrases, expiry
# @return       void
function ssh-audit() {
  printf "\n  🔐 SSH Security Audit\n"
  printf "  ═══════════════════════════════════\n\n"

  local issues=0

  # -- 1. Check directory permissions
  printf "  %b%b Permissions%b\n" "${S_BOLD}${C_TEXT}" "$I_SHIELD" "$S_RESET"

  local dir_perms
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    dir_perms=$(/usr/bin/stat -f '%Lp' "$SSH_DIR" 2>/dev/null)
  else
    dir_perms=$(stat -c '%a' "$SSH_DIR" 2>/dev/null)
  fi

  if [[ "$dir_perms" == "700" ]]; then
    printf '    ✅ ~/.ssh/ permissions: %s\n' "$dir_perms"
  else
    printf '    ❌ ~/.ssh/ permissions: %s (should be 700)\n' "$dir_perms"
    issues=$((issues + 1))
  fi

  # -- 2. Check each key
  printf "\n  %b%b Keys%b\n" "${S_BOLD}${C_TEXT}" "$I_SHIELD" "$S_RESET"

  local _audit_keys
  _audit_keys=$(_ssh_discover_keys)

  local _akey _aname _aperms _afp _abits _atype _ahas_pass
  while IFS= read -r _akey; do
    [[ -z "$_akey" ]] && continue
    _aname=$(basename "$_akey")

    if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
      _aperms=$(/usr/bin/stat -f '%Lp' "$_akey" 2>/dev/null)
    else
      _aperms=$(stat -c '%a' "$_akey" 2>/dev/null)
    fi

    printf '    🔑 %s\n' "$_aname"

    # Permissions
    if [[ "$_aperms" == "600" ]]; then
      printf '       Permissions: ✅ %s\n' "$_aperms"
    else
      printf '       Permissions: ❌ %s (should be 600)\n' "$_aperms"
      issues=$((issues + 1))
    fi

    # Key type and strength
    _afp=$(ssh-keygen -lf "$_akey" 2>/dev/null)
    _abits=$(echo "$_afp" | awk '{print $1}')
    _atype=$(echo "$_afp" | awk '{print $NF}' | tr -d '()')

    case "$_atype" in
      ED25519)
        printf '       Algorithm:   ✅ %s (recommended)\n' "$_atype" ;;
      RSA)
        if (( _abits >= 4096 )); then
          printf '       Algorithm:   ✅ %s (%s bits)\n' "$_atype" "$_abits"
        elif (( _abits >= 2048 )); then
          printf '       Algorithm:   ⚠️  %s (%s bits — consider 4096+)\n' "$_atype" "$_abits"
          issues=$((issues + 1))
        else
          printf '       Algorithm:   ❌ %s (%s bits — TOO WEAK)\n' "$_atype" "$_abits"
          issues=$((issues + 1))
        fi ;;
      ECDSA)
        printf '       Algorithm:   ⚠️  %s (ED25519 preferred)\n' "$_atype" ;;
      DSA)
        printf '       Algorithm:   ❌ %s (DEPRECATED)\n' "$_atype"
        issues=$((issues + 1)) ;;
    esac

    # Passphrase check
    SSH_ASKPASS="" SSH_ASKPASS_REQUIRE="" ssh-keygen -y -P "" -f "$_akey" >/dev/null 2>&1 && _ahas_pass=0 || _ahas_pass=1

    if [[ "$_ahas_pass" -eq 1 ]]; then
      printf '       Passphrase:  ✅ protected\n'
    else
      printf '       Passphrase:  ❌ NO PASSPHRASE\n'
      issues=$((issues + 1))
    fi

    # Public key
    [[ -f "${_akey}.pub" ]] && printf '       Public key:  ✅ %s.pub\n' "$_aname" || printf '       Public key:  ⚠️  missing\n'

    printf '\n'
  done <<< "$_audit_keys"

  # -- 3. Config security
  printf "  %b%b Config%b\n" "${S_BOLD}${C_TEXT}" "$I_SHIELD" "$S_RESET"

  if [[ -f "${SSH_CONF_DIR}/00-defaults.conf" ]]; then
    if grep -q "ForwardAgent no" "${SSH_CONF_DIR}/00-defaults.conf" 2>/dev/null; then
      printf '    ✅ Agent forwarding: disabled (safe)\n'
    else
      printf '    ⚠️  Agent forwarding: not explicitly disabled\n'
      issues=$((issues + 1))
    fi

    if grep -q "StrictHostKeyChecking" "${SSH_CONF_DIR}/00-defaults.conf" 2>/dev/null; then
      printf '    ✅ Host key checking: enabled\n'
    else
      printf '    ⚠️  Host key checking: not configured\n'
      issues=$((issues + 1))
    fi

    if grep -q "HashKnownHosts" "${SSH_CONF_DIR}/00-defaults.conf" 2>/dev/null; then
      printf '    ✅ Known hosts hashing: enabled\n'
    else
      printf '    ⚠️  Known hosts not hashed\n'
    fi
  fi

  # -- 4. Backup check
  printf "\n  %b%b Backups%b\n" "${S_BOLD}${C_TEXT}" "$I_SHIELD" "$S_RESET"

  local backup_dir="${HOME}/.ssh/backups"
  if [[ -d "$backup_dir" ]]; then
    local backup_count
    backup_count=$(find "$backup_dir" -type f \( -name "*.age" -o -name "*.gpg" -o -name "*.zip" \) 2>/dev/null | wc -l | tr -d ' ')
    if (( backup_count > 0 )); then
      printf '    ✅ %s encrypted backups found\n' "$backup_count"
    else
      printf '    ⚠️  No encrypted backups (run: ssh-backup)\n'
      issues=$((issues + 1))
    fi
  else
    printf '    ⚠️  No backup directory (run: ssh-backup)\n'
    issues=$((issues + 1))
  fi

  # -- Summary
  printf "\n  ═══════════════════════════════════\n"
  if (( issues == 0 )); then
    printf "  ✅ No security issues found\n"
  else
    printf "  ⚠️  %d issue(s) found — review above\n" "$issues"
  fi
  printf "  ═══════════════════════════════════\n\n"


  # -- 5. Key age check
  printf "\n  %b%b Key Age%b\n" "${S_BOLD}${C_TEXT}" "$I_SHIELD" "$S_RESET"

  local _age_key _age_epoch _age_days _now_epoch
  _now_epoch=$(date +%s)

  while IFS= read -r _age_key; do
    [[ -z "$_age_key" ]] && continue
    local _age_name=$(basename "$_age_key")

    if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
      _age_epoch=$(/usr/bin/stat -f%m "$_age_key" 2>/dev/null)
    else
      _age_epoch=$(stat -c%Y "$_age_key" 2>/dev/null)
    fi

    [[ -z "$_age_epoch" ]] && continue
    _age_days=$(( (_now_epoch - _age_epoch) / 86400 ))

    if (( _age_days > 365 )); then
      printf '    ❌ %-25s %sd old (ROTATE NOW)\n' "$_age_name" "$_age_days"
      issues=$((issues + 1))
    elif (( _age_days > 270 )); then
      printf '    ⚠️  %-25s %sd old (rotate soon)\n' "$_age_name" "$_age_days"
    else
      printf '    ✅ %-25s %sd old\n' "$_age_name" "$_age_days"
    fi
  done <<< "$_audit_keys"
}

# ============================================================================
# SSH Security — Advanced features
# ============================================================================

# @description  Check SSH key age and warn about keys older than max_age_days.
#               Keys should be rotated regularly (recommended: every 365 days).
# @param  $1    integer  (optional) Max age in days (default: 365)
# @return       void
function ssh-key-age() {
  local max_days="${1:-365}"
  local now=$(date +%s)
  local warnings=0

  printf "\n  🔑 SSH Key Age Report (max: %s days)\n" "$max_days"
  printf "  ═══════════════════════════════════\n\n"

  _ssh_discover_keys | while read -r key; do
    local name=$(basename "$key")
    local key_epoch

    if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
      key_epoch=$(/usr/bin/stat -f%m "$key" 2>/dev/null)
    else
      key_epoch=$(stat -c%Y "$key" 2>/dev/null)
    fi

    [[ -z "$key_epoch" ]] && continue

    local age_days=$(( (now - key_epoch) / 86400 ))
    local age_str

    if (( age_days > 365 )); then
      age_str="$(( age_days / 365 ))y $(( age_days % 365 ))d"
    elif (( age_days > 30 )); then
      age_str="$(( age_days / 30 ))m $(( age_days % 30 ))d"
    else
      age_str="${age_days}d"
    fi

    if (( age_days > max_days )); then
      printf "  ❌ %-30s %s %b(ROTATE NOW)%b\n" "$name" "$age_str" "$C_RED" "$S_RESET"
      warnings=$((warnings + 1))
    elif (( age_days > max_days * 3 / 4 )); then
      printf "  ⚠️  %-30s %s %b(rotate soon)%b\n" "$name" "$age_str" "$C_YELLOW" "$S_RESET"
    else
      printf "  ✅ %-30s %s\n" "$name" "$age_str"
    fi
  done

  printf "\n  ═══════════════════════════════════\n\n"
}

# @description  Rotate an SSH key — generate new, backup old, update services.
# @param  $1    string  Key name to rotate
# @return       void
function ssh-key-rotate() {
  local key_name="${1:-}"

  if [[ -z "$key_name" ]] && has "fzf"; then
    key_name=$(_ssh_discover_keys | while read -r k; do
      local name=$(basename "$k")
      local age_days
      if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
        age_days=$(( ($(date +%s) - $(/usr/bin/stat -f%m "$k" 2>/dev/null || echo 0)) / 86400 ))
      else
        age_days=$(( ($(date +%s) - $(stat -c%Y "$k" 2>/dev/null || echo 0)) / 86400 ))
      fi
      printf "%s\t%s (%sd old)\n" "$k" "$name" "$age_days"
    done | fzf --header='Select key to rotate' --height='40%' --border \
                --delimiter='\t' --with-nth=2 | cut -f1)
  fi

  [[ -z "$key_name" ]] && return 0

  local key_path
  if [[ -f "$key_name" ]]; then
    key_path="$key_name"
  else
    key_path="${SSH_DIR}/${key_name}"
  fi

  [[ -f "$key_path" ]] || { log_error "Key not found: %s" "$key_name"; return 1; }

  local name=$(basename "$key_path")
  printf "\n  🔄 Rotating key: %s\n" "$name"
  printf "  ─────────────────────────────────\n\n"

  # -- Step 1: Backup old key
  printf "  Step 1: Backing up old key...\n"
  ssh-backup
  local old_backup="${key_path}.old.$(date +%Y%m%d)"
  cp "$key_path" "$old_backup" 2>/dev/null
  [[ -f "${key_path}.pub" ]] && cp "${key_path}.pub" "${old_backup}.pub" 2>/dev/null

  # -- Step 2: Generate new key
  printf "\n  Step 2: Generating new key...\n\n"
  ssh-key-generate "$name"

  # -- Step 3: Reminder
  printf "\n  ─────────────────────────────────\n"
  printf "  📌 Don't forget to:\n"
  printf "     1. Update the public key on remote services\n"
  printf "     2. Test: ssh-test <host>\n"
  printf "     3. Remove old backup when confirmed: rm %s\n" "$old_backup"
  printf "  ─────────────────────────────────\n\n"
}

# ============================================================================
# SSH Security — Advanced features
# ============================================================================

# @description  Check SSH key age and warn about keys older than max_age_days.
#               Keys should be rotated regularly (recommended: every 365 days).
# @param  $1    integer  (optional) Max age in days (default: 365)
# @return       void
function ssh-key-age() {
  local max_days="${1:-365}"
  local now=$(date +%s)
  local warnings=0

  printf "\n  🔑 SSH Key Age Report (max: %s days)\n" "$max_days"
  printf "  ═══════════════════════════════════\n\n"

  _ssh_discover_keys | while read -r key; do
    local name=$(basename "$key")
    local key_epoch

    if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
      key_epoch=$(/usr/bin/stat -f%m "$key" 2>/dev/null)
    else
      key_epoch=$(stat -c%Y "$key" 2>/dev/null)
    fi

    [[ -z "$key_epoch" ]] && continue

    local age_days=$(( (now - key_epoch) / 86400 ))
    local age_str

    if (( age_days > 365 )); then
      age_str="$(( age_days / 365 ))y $(( age_days % 365 ))d"
    elif (( age_days > 30 )); then
      age_str="$(( age_days / 30 ))m $(( age_days % 30 ))d"
    else
      age_str="${age_days}d"
    fi

    if (( age_days > max_days )); then
      printf "  ❌ %-30s %s %b(ROTATE NOW)%b\n" "$name" "$age_str" "$C_RED" "$S_RESET"
      warnings=$((warnings + 1))
    elif (( age_days > max_days * 3 / 4 )); then
      printf "  ⚠️  %-30s %s %b(rotate soon)%b\n" "$name" "$age_str" "$C_YELLOW" "$S_RESET"
    else
      printf "  ✅ %-30s %s\n" "$name" "$age_str"
    fi
  done

  printf "\n  ═══════════════════════════════════\n\n"
}

# @description  Rotate an SSH key — generate new, backup old, update services.
# @param  $1    string  Key name to rotate
# @return       void
function ssh-key-rotate() {
  local key_name="${1:-}"

  if [[ -z "$key_name" ]] && has "fzf"; then
    key_name=$(_ssh_discover_keys | while read -r k; do
      local name=$(basename "$k")
      local age_days
      if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
        age_days=$(( ($(date +%s) - $(/usr/bin/stat -f%m "$k" 2>/dev/null || echo 0)) / 86400 ))
      else
        age_days=$(( ($(date +%s) - $(stat -c%Y "$k" 2>/dev/null || echo 0)) / 86400 ))
      fi
      printf "%s\t%s (%sd old)\n" "$k" "$name" "$age_days"
    done | fzf --header='Select key to rotate' --height='40%' --border \
                --delimiter='\t' --with-nth=2 | cut -f1)
  fi

  [[ -z "$key_name" ]] && return 0

  local key_path
  if [[ -f "$key_name" ]]; then
    key_path="$key_name"
  else
    key_path="${SSH_DIR}/${key_name}"
  fi

  [[ -f "$key_path" ]] || { log_error "Key not found: %s" "$key_name"; return 1; }

  local name=$(basename "$key_path")
  printf "\n  🔄 Rotating key: %s\n" "$name"
  printf "  ─────────────────────────────────\n\n"

  # -- Step 1: Backup old key
  printf "  Step 1: Backing up old key...\n"
  ssh-backup
  local old_backup="${key_path}.old.$(date +%Y%m%d)"
  cp "$key_path" "$old_backup" 2>/dev/null
  [[ -f "${key_path}.pub" ]] && cp "${key_path}.pub" "${old_backup}.pub" 2>/dev/null

  # -- Step 2: Generate new key
  printf "\n  Step 2: Generating new key...\n\n"
  ssh-key-generate "$name"

  # -- Step 3: Reminder
  printf "\n  ─────────────────────────────────\n"
  printf "  📌 Don't forget to:\n"
  printf "     1. Update the public key on remote services\n"
  printf "     2. Test: ssh-test <host>\n"
  printf "     3. Remove old backup when confirmed: rm %s\n" "$old_backup"
  printf "  ─────────────────────────────────\n\n"
}

log_debug "ssh configured"
