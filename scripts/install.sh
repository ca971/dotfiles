#!/usr/bin/env bash
# ============================================================================
# @file        scripts/install.sh
# @description One-line installer for the ZSH configuration framework.
#              Clones the repository, creates symlinks, installs dependencies,
#              generates SSOT files, and configures the shell environment.
#
# @usage       curl -fsSL https://raw.githubusercontent.com/ca971/zsh-config/main/scripts/install.sh | bash
#              # or:
#              git clone https://github.com/ca971/zsh-config.git ~/.config/zsh && bash ~/.config/zsh/scripts/install.sh
#
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
# ============================================================================

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

readonly REPO_URL="https://github.com/ca971/zsh-config.git"
readonly XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly INSTALL_DIR="${XDG_CONFIG_HOME}/zsh"
readonly BACKUP_DIR="${HOME}/.zsh-backup-$(date +%Y%m%d_%H%M%S)"

# ── Colors ───────────────────────────────────────────────────────────────────
readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[0;33m"
readonly BLUE="\033[0;34m"
readonly BOLD="\033[1m"
readonly DIM="\033[2m"
readonly RESET="\033[0m"

# ============================================================================
# Helper Functions
# ============================================================================

_info() { printf "${BLUE}ℹ${RESET} %s\n" "$1"; }
_success() { printf "${GREEN}✓${RESET} %s\n" "$1"; }
_warn() { printf "${YELLOW}⚠${RESET} %s\n" "$1"; }
_error() { printf "${RED}✗${RESET} %s\n" "$1"; }
_step() { printf "\n${BOLD}━━━ %s ━━━${RESET}\n\n" "$1"; }

_has() { command -v "$1" &> /dev/null; }

_backup_file() {
    local file="$1"
    if [[ -e "$file" ]] || [[ -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$file" "${BACKUP_DIR}/$(basename "$file")"
        _warn "Backed up: $(basename "$file") → ${BACKUP_DIR}/"
    fi
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

preflight() {
    _step "Pre-flight Checks"

    # -- Check for Git
    if ! _has "git"; then
        _error "Git is required but not installed"
        exit 1
    fi
    _success "Git found: $(git --version | head -1)"

    # -- Check for ZSH
    if ! _has "zsh"; then
        _warn "ZSH not found — you'll need to install it"
        case "$(uname -s)" in
            Darwin) _info "Install: brew install zsh" ;;
            Linux)
                if _has "apt"; then
                    _info "Install: sudo apt install zsh"
                elif _has "dnf"; then
                    _info "Install: sudo dnf install zsh"
                elif _has "pacman"; then
                    _info "Install: sudo pacman -S zsh"
                fi
                ;;
        esac
    else
        _success "ZSH found: $(zsh --version | head -1)"
    fi

    # -- Check for curl/wget (for downloading tools)
    if _has "curl"; then
        _success "curl found"
    elif _has "wget"; then
        _success "wget found"
    else
        _warn "Neither curl nor wget found — some installations may fail"
    fi
}

# ============================================================================
# Clone/Update Repository
# ============================================================================

install_repo() {
    _step "Installing ZSH Configuration"

    if [[ -d "${INSTALL_DIR}/.git" ]]; then
        _info "Existing installation found — updating..."
        git -C "$INSTALL_DIR" pull --rebase --autostash
        _success "Configuration updated"
    else
        # -- Backup existing config
        _backup_file "$INSTALL_DIR"
        _backup_file "${HOME}/.zshrc"
        _backup_file "${HOME}/.zshenv"
        _backup_file "${HOME}/.zprofile"

        # -- Clone repository
        _info "Cloning repository..."
        git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
        _success "Repository cloned to ${INSTALL_DIR}"
    fi
}

# ============================================================================
# Create Symlinks
# ============================================================================

create_symlinks() {
    _step "Creating Symlinks"

    # -- Main symlink: ~/.zshenv → config .zshenv
    _backup_file "${HOME}/.zshenv"
    ln -sf "${INSTALL_DIR}/.zshenv" "${HOME}/.zshenv"
    _success "~/.zshenv → ${INSTALL_DIR}/.zshenv"

    # -- Starship config symlink
    local starship_target="${XDG_CONFIG_HOME}/starship.toml"
    if [[ ! -f "$starship_target" ]] || [[ -L "$starship_target" ]]; then
        ln -sf "${INSTALL_DIR}/themes/starship.toml" "$starship_target"
        _success "starship.toml symlinked"
    else
        _warn "starship.toml exists — skipping (manual merge may be needed)"
    fi
}

# ============================================================================
# Create Required Directories
# ============================================================================

create_directories() {
    _step "Creating Directories"

    local dirs=(
        "${XDG_CONFIG_HOME}"
        "${HOME}/.local/share"
        "${HOME}/.local/state"
        "${HOME}/.cache"
        "${HOME}/.local/bin"
        "${INSTALL_DIR}/local"
        "${INSTALL_DIR}/cache"
        "${INSTALL_DIR}/generated"
        "${HOME}/.local/share/zsh"
        "${HOME}/.cache/zsh"
        "${HOME}/.local/state/zsh"
    )

    local dir
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir" 2> /dev/null
    done
    _success "XDG directories created"
}

# ============================================================================
# Generate SSOT Files
# ============================================================================

generate_ssot() {
    _step "Generating SSOT Files"

    local gen_script="${INSTALL_DIR}/ssot/generators/generate-all.sh"
    if [[ -f "$gen_script" ]]; then
        chmod +x "${INSTALL_DIR}/ssot/generators/"*.sh
        bash "$gen_script"
        _success "SSOT files generated"
    else
        _warn "Generator script not found — skipping SSOT generation"
    fi
}

# ============================================================================
# Install Essential Tools (optional)
# ============================================================================

install_tools() {
    _step "Essential Tools Check"

    local -a missing=()
    local -A tools=(
        [eza]="Modern ls"
        [fzf]="Fuzzy finder"
        [bat]="Cat with syntax highlighting"
        [fd]="Modern find"
        [rg]="Ripgrep (grep)"
        [zoxide]="Smart cd"
        [starship]="Prompt engine"
        [delta]="Git diff pager"
        [atuin]="Shell history"
    )

    local tool desc
    for tool in "${!tools[@]}"; do
        desc="${tools[$tool]}"
        if _has "$tool"; then
            _success "${tool} — ${desc}"
        else
            _warn "${tool} — ${desc} (not installed)"
            missing+=("$tool")
        fi
    done

    if ((${#missing[@]} > 0)); then
        printf "\n"
        _info "Missing tools: ${missing[*]}"
        _info "Install with your package manager or use: just install"

        if _has "brew"; then
            printf "\n  ${DIM}brew install %s${RESET}\n\n" "${missing[*]}"
        elif _has "pacman"; then
            printf "\n  ${DIM}sudo pacman -S %s${RESET}\n\n" "${missing[*]}"
        elif _has "apt"; then
            printf "\n  ${DIM}sudo apt install %s${RESET}\n\n" "${missing[*]}"
        fi
    fi
}

# ============================================================================
# Set ZSH as Default Shell
# ============================================================================

set_default_shell() {
    _step "Default Shell"

    local current_shell
    current_shell=$(basename "${SHELL:-}")

    if [[ "$current_shell" == "zsh" ]]; then
        _success "ZSH is already the default shell"
        return
    fi

    if _has "zsh"; then
        local zsh_path
        zsh_path=$(command -v zsh)

        # -- Ensure ZSH is in /etc/shells
        if ! grep -q "$zsh_path" /etc/shells 2> /dev/null; then
            _info "Adding ${zsh_path} to /etc/shells..."
            echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null 2>&1 || true
        fi

        printf "\n  Change default shell to ZSH? [y/N] "
        read -r answer
        if [[ "${answer:-}" =~ ^[Yy]$ ]]; then
            chsh -s "$zsh_path" && _success "Default shell changed to ZSH" \
                || _warn "Failed to change shell (try: chsh -s $zsh_path)"
        else
            _info "Skipped — change manually with: chsh -s ${zsh_path}"
        fi
    else
        _warn "ZSH not installed — cannot set as default shell"
    fi
}

# ============================================================================
# Summary
# ============================================================================

summary() {
    _step "Installation Complete 🎉"

    printf "  ${BOLD}Configuration:${RESET}  %s\n" "$INSTALL_DIR"
    printf "  ${BOLD}Symlink:${RESET}        %s → %s\n" "~/.zshenv" "${INSTALL_DIR}/.zshenv"
    if [[ -d "$BACKUP_DIR" ]]; then
        printf "  ${BOLD}Backups:${RESET}        %s\n" "$BACKUP_DIR"
    fi

    printf "\n  ${BOLD}Next steps:${RESET}\n"
    printf "    1. Start a new ZSH session:  ${GREEN}exec zsh${RESET}\n"
    printf "    2. Run diagnostics:          ${GREEN}just doctor${RESET}\n"
    printf "    3. Install missing tools:    ${GREEN}just tools${RESET}\n"
    printf "    4. Read the documentation:   ${GREEN}just edit${RESET}\n"
    printf "\n"
}

# ============================================================================
# Main
# ============================================================================

main() {
    printf "\n${BOLD}  🚀 ZSH Ultra-Modern Configuration Installer${RESET}\n"
    printf "  ${DIM}%s${RESET}\n\n" "$REPO_URL"

    preflight
    install_repo
    create_directories
    create_symlinks
    generate_ssot
    install_tools
    set_default_shell
    summary
}

main "$@"
