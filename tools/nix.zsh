#!/usr/bin/env zsh
# ============================================================================
# @file        tools/nix.zsh
# @description Nix package manager — auto-setup, shell integration,
#              daemon sourcing, and management functions.
#              Handles both single-user and multi-user Nix installations.
# @version     4.0.0
#
# @depends     lib/logging.zsh, lib/tool-check.zsh, lib/platform-detect.zsh
# ============================================================================

[[ -n "${_ZSH_TOOLS_NIX_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_NIX_LOADED=1

# ── Detect and source Nix environment ────────────────────────────────────────
# Nix must be sourced BEFORE we check `has "nix"` because Nix
# adds itself to PATH via these profile scripts.
function _nix_auto_setup() {

  # ── 1. Multi-user Nix daemon (macOS + Linux) ───────────────────────
  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" 2>/dev/null
    log_debug "Nix daemon sourced (multi-user)"

  # ── 2. Single-user Nix ─────────────────────────────────────────────
  elif [[ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
    source "${HOME}/.nix-profile/etc/profile.d/nix.sh" 2>/dev/null
    log_debug "Nix sourced (single-user)"

  # ── 3. Nix-darwin (macOS with nix-darwin) ──────────────────────────
  elif [[ -f "/run/current-system/sw/etc/profile.d/nix.sh" ]]; then
    source "/run/current-system/sw/etc/profile.d/nix.sh" 2>/dev/null
    log_debug "Nix sourced (nix-darwin)"

  # ── 4. Determinate Nix installer ───────────────────────────────────
  elif [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish" ]]; then
    # Fish variant exists but we need the sh one — try alternative path
    [[ -f "/etc/profile.d/nix.sh" ]] && source "/etc/profile.d/nix.sh" 2>/dev/null

  # ── Not installed ──────────────────────────────────────────────────
  elif [[ ! -d "/nix" ]]; then
    return 0
  fi

  # ── Ensure Nix paths are in PATH ───────────────────────────────────
  local nix_profile="${HOME}/.nix-profile/bin"
  local nix_default="/nix/var/nix/profiles/default/bin"

  [[ -d "$nix_profile" ]] && {
    case ":${PATH}:" in
      *":${nix_profile}:"*) ;;
      *) export PATH="${nix_profile}:${PATH}" ;;
    esac
  }

  [[ -d "$nix_default" ]] && {
    case ":${PATH}:" in
      *":${nix_default}:"*) ;;
      *) export PATH="${nix_default}:${PATH}" ;;
    esac
  }

  # ── XDG for Nix ────────────────────────────────────────────────────
  export NIX_CONF_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/nix"
  [[ -d "$NIX_CONF_DIR" ]] || mkdir -p "$NIX_CONF_DIR" 2>/dev/null

  # ── Generate nix.conf if missing ───────────────────────────────────
  local nix_conf="${NIX_CONF_DIR}/nix.conf"
  if [[ ! -s "$nix_conf" ]]; then
cat > "$nix_conf" << 'EOF'
# Nix configuration — managed by dotfiles
experimental-features = nix-command flakes
warn-dirty = false
max-jobs = auto
EOF
    log_debug "Generated nix.conf"
  fi

  # ── Symlink flake to easy access ───────────────────────────────────
  local nix_flake_dir="${DOTFILES_DIR}/config/nix"
  if [[ -f "${nix_flake_dir}/flake.nix" ]] && [[ ! -L "${HOME}/.config/nix/flake.nix" ]]; then
    ln -sf "${nix_flake_dir}/flake.nix" "${NIX_CONF_DIR}/flake.nix" >/dev/null 2>&1
  fi
}

_nix_auto_setup

# ── Check if Nix is now available ────────────────────────────────────────────
has "nix" || has "nix-env" || return 0
log_debug "Configuring nix"

# ── Source config ────────────────────────────────────────────────────────────
[[ -f "${DOTFILES_DIR}/config/tools.d/nix.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/nix.zsh"

# ── Functions ────────────────────────────────────────────────────────────────

# @description  Show Nix installation info
function nix-info() {
  printf "\n  ❄️  Nix\n"
  printf "  ═══════════════════════════════════\n\n"

  # Version
  printf "  Version:    %s\n" "$(nix --version 2>/dev/null || nix-env --version 2>/dev/null || echo 'N/A')"

  # Installation type
  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    printf "  Type:       multi-user (daemon)\n"
  elif [[ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
    printf "  Type:       single-user\n"
  elif [[ -f "/run/current-system/sw/etc/profile.d/nix.sh" ]]; then
    printf "  Type:       nix-darwin\n"
  fi

  # Store
  printf "  Store:      /nix/store\n"
  if [[ -d "/nix/store" ]]; then
    local store_size
    store_size=$(du -sh /nix/store 2>/dev/null | awk '{print $1}')
    printf "  Store size: %s\n" "${store_size:-N/A}"
  fi

  # Channels / Registries
  printf "  Config:     %s\n" "${NIX_CONF_DIR:-~/.config/nix}"

  # Installed packages
  local pkg_count
  pkg_count=$(nix profile list 2>/dev/null | wc -l | tr -d ' ' || nix-env -q 2>/dev/null | wc -l | tr -d ' ')
  printf "  Packages:   %s\n" "${pkg_count:-0}"

  # Flakes enabled?
  if nix --version 2>/dev/null | grep -q "nix"; then
    if nix flake --help >/dev/null 2>&1; then
      printf "  Flakes:     ✅ enabled\n"
    else
      printf "  Flakes:     ❌ disabled\n"
    fi
  fi

  # Channels
  local channels
  channels=$(nix-channel --list 2>/dev/null)
  if [[ -n "$channels" ]]; then
    printf "  Channels:\n"
    echo "$channels" | while read -r line; do
      printf "    • %s\n" "$line"
    done
  fi

  printf "\n  ═══════════════════════════════════\n\n"
}

# @description  Search Nix packages interactively
function nix-search() {
  local query="${1:-}"

  if [[ -z "$query" ]]; then
    printf "Search: "
    read -r query
    [[ -z "$query" ]] && return 0
  fi

  if has "fzf"; then
    nix search nixpkgs "$query" 2>/dev/null | \
      grep -E '^\*|^  ' | \
      fzf --header="Nix: ${query}" --preview-window='right:50%:wrap'
  else
    nix search nixpkgs "$query" 2>/dev/null
  fi
}

# @description  Install a Nix package interactively
function nix-install() {
  local pkg="${1:-}"

  if [[ -z "$pkg" ]] && has "fzf"; then
    printf "Search package: "
    read -r query
    [[ -z "$query" ]] && return 0
    pkg=$(nix search nixpkgs "$query" 2>/dev/null | \
      grep -E '^\* ' | sed 's/^\* //' | awk '{print $1}' | \
      fzf --header="Install from Nix")
  fi

  [[ -z "$pkg" ]] && return 0

  log_info "Installing: %s" "$pkg"
  nix profile install "nixpkgs#${pkg}" 2>/dev/null || \
    nix-env -iA "nixpkgs.${pkg}" 2>/dev/null
}

# @description  List installed Nix packages
function nix-list() {
  printf "\n  ❄️  Installed Nix Packages\n\n"
  nix profile list 2>/dev/null || nix-env -q 2>/dev/null
  printf "\n"
}

# @description  Update all Nix packages
function nix-update() {
  log_info "Updating Nix packages..."
  nix profile upgrade '.*' 2>/dev/null || {
    nix-channel --update 2>/dev/null
    nix-env --upgrade 2>/dev/null
  }
  log_info "Nix packages updated"
}

# @description  Garbage collect Nix store
function nix-clean() {
  printf "  Nix store before: %s\n" "$(du -sh /nix/store 2>/dev/null | awk '{print $1}')"
  nix-collect-garbage -d 2>/dev/null
  printf "  Nix store after:  %s\n" "$(du -sh /nix/store 2>/dev/null | awk '{print $1}')"
  log_info "Nix garbage collected"
}

# @description  Create a nix-shell with common dev tools
function nix-dev-shell() {
  local lang="${1:-}"

  if [[ -z "$lang" ]] && has "fzf"; then
    lang=$(printf "python\nnode\nrust\ngo\nruby\njava\nc-cpp\ngeneral" | \
      fzf --header='Dev environment' --height='40%' --border)
  fi

  case "$lang" in
    python)  nix-shell -p python3 python3Packages.pip python3Packages.virtualenv ;;
    node)    nix-shell -p nodejs npm ;;
    rust)    nix-shell -p rustc cargo rustfmt clippy ;;
    go)      nix-shell -p go gopls ;;
    ruby)    nix-shell -p ruby bundler ;;
    java)    nix-shell -p jdk maven ;;
    c-cpp)   nix-shell -p gcc gnumake cmake ;;
    general) nix-shell -p git curl wget jq yq fd ripgrep ;;
    *)       printf "  Usage: nix-dev-shell <python|node|rust|go|ruby|java|c-cpp|general>\n" ;;
  esac
}

# @description  Initialize a flake in the current directory
function nix-flake-init() {
  local template="${1:-}"

  if [[ -z "$template" ]] && has "fzf"; then
    template=$(nix flake show templates 2>/dev/null | grep -E '^\s' | awk '{print $1}' | \
      fzf --header='Flake template' --height='40%' --border)
  fi

  if [[ -n "$template" ]]; then
    nix flake init -t "$template"
  else
    nix flake init
  fi
  log_info "Flake initialized"
}

# @description  Edit nix.conf
function nix-edit() {
  "${EDITOR:-nvim}" "${NIX_CONF_DIR}/nix.conf"
}

# @description  Nix security audit — check store permissions and config
function nix-audit() {
  printf "\n  ❄️  Nix Audit\n"
  printf "  ─────────────────────────────────\n"

  # Store permissions
  if [[ -d "/nix/store" ]]; then
    local store_owner
    store_owner=$(ls -ld /nix/store 2>/dev/null | awk '{print $3}')
    if [[ "$store_owner" == "root" ]]; then
      printf "  ✅ Store owner: root\n"
    else
      printf "  ⚠️  Store owner: %s (should be root)\n" "$store_owner"
    fi
  fi

  # Daemon running
  if pgrep -x nix-daemon >/dev/null 2>&1; then
    printf "  ✅ Daemon: running\n"
  else
    printf "  ⚠️  Daemon: not running\n"
  fi

  # Config
  if [[ -f "${NIX_CONF_DIR}/nix.conf" ]]; then
    printf "  ✅ Config: %s\n" "${NIX_CONF_DIR}/nix.conf"
    if grep -q "experimental-features.*flakes" "${NIX_CONF_DIR}/nix.conf" 2>/dev/null; then
      printf "  ✅ Flakes: enabled in config\n"
    else
      printf "  ⚠️  Flakes: not enabled\n"
    fi
  else
    printf "  ⚠️  No nix.conf\n"
  fi

  printf "  ─────────────────────────────────\n\n"
}

# ── Flake helpers ────────────────────────────────────────────────────────────

# @description  Enter the dotfiles dev shell
function nix-dev() {
  local flake_dir="${DOTFILES_DIR}/config/nix"
  if [[ -f "${flake_dir}/flake.nix" ]]; then
    log_info "Entering dev shell..."
    nix develop "${flake_dir}" "$@"
  else
    log_error "No flake.nix found in config/nix/"
  fi
}

# @description  Install all packages from the flake
function nix-install-env() {
  local flake_dir="${DOTFILES_DIR}/config/nix"
  if [[ -f "${flake_dir}/flake.nix" ]]; then
    log_info "Installing dotfiles environment..."
    nix profile install "${flake_dir}"
    log_info "Environment installed"
  else
    log_error "No flake.nix found"
  fi
}

# @description  Update flake inputs
function nix-flake-update() {
  local flake_dir="${DOTFILES_DIR}/config/nix"
  if [[ -f "${flake_dir}/flake.nix" ]]; then
    log_info "Updating flake inputs..."
    nix flake update "${flake_dir}"
    log_info "Flake updated"
  else
    log_error "No flake.nix found"
  fi
}

# @description  Show flake info
function nix-flake-info() {
  local flake_dir="${DOTFILES_DIR}/config/nix"
  if [[ -f "${flake_dir}/flake.nix" ]]; then
    nix flake show "${flake_dir}"
  else
    log_error "No flake.nix found"
  fi
}

# @description  Rebuild environment from flake (update + install)
function nix-rebuild() {
  nix-flake-update
  nix-install-env
}

# ── Project templates ────────────────────────────────────────────────────────
function nix-new() {
  local template="${1:-}"
  local dir="${2:-}"

  if [[ -z "$template" ]]; then
    if has "fzf"; then
      template=$(printf "rust\npython\nnode\ngo" | \
        fzf --header='Project template' --height='30%' --border)
    else
      printf "  Templates: rust, python, node, go\n  Choice: "
      read -r template
    fi
  fi
  [[ -z "$template" ]] && return 0

  if [[ -z "$dir" ]]; then
    printf "  Project directory: "
    read -r dir
  fi
  [[ -z "$dir" ]] && return 0

  mkdir -p "$dir" && cd "$dir"
  nix flake init -t "${DOTFILES_DIR}/config/nix#${template}"
  git init 2>/dev/null
  log_info "Project created: %s (%s)" "$dir" "$template"
}

# ── Named dev shells ─────────────────────────────────────────────────────────
function nix-shell-list() {
  printf "\n  ❄️  Available Dev Shells\n  ─────────────────────\n"
  printf "  default   All tools\n"
  printf "  rust      Rust + cargo + wasm\n"
  printf "  python    Python 3.13 + uv + ruff\n"
  printf "  node      Node.js 22 + corepack\n"
  printf "  go        Go 1.23 + gopls + lint\n"
  printf "  devops    K8s + Terraform + Cloud\n"
  printf "  minimal   Essential CLI only\n\n"
  printf "  Usage: nix develop ~/dotfiles/config/nix#<name>\n\n"
}

function nix-dev() {
  local shell="${1:-default}"
  local flake_dir="${DOTFILES_DIR}/config/nix"
  [[ -f "${flake_dir}/flake.nix" ]] || { log_error "No flake.nix"; return 1; }
  log_info "Entering %s shell..." "$shell"
  nix develop "path:${flake_dir}#${shell}" --command zsh -i
}

log_debug "nix configured"
