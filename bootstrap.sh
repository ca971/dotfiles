#!/bin/sh
# ============================================================================
# @file        bootstrap.sh
# @description Universal dotfiles bootstrap script. Works with ANY shell
#              (sh, bash, zsh, fish, nushell). Detects the current shell,
#              creates appropriate symlinks, and sets up the environment.
#
#              This is the TRUE entry point of the dotfiles system.
#              Written in POSIX sh for maximum portability.
#
# @usage       # First install:
#              git clone https://github.com/ca971/dotfiles.git ~/dotfiles
#              sh ~/dotfiles/bootstrap.sh
#
#              # Or one-liner:
#              curl -fsSL https://raw.githubusercontent.com/ca971/dotfiles/main/bootstrap.sh | sh
#
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-15
# @version     1.0.0
# ============================================================================

set -eu

# ============================================================================
# Configuration
# ============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"
REPO_URL="https://github.com/ca971/dotfiles.git"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

# ── Colors (POSIX-safe) ─────────────────────────────────────────────────────
if [ -t 1 ]; then
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[0;33m"
    BLUE="\033[0;34m"
    BOLD="\033[1m"
    DIM="\033[2m"
    RESET="\033[0m"
else
    RED="" GREEN="" YELLOW="" BLUE="" BOLD="" DIM="" RESET=""
fi

_info() { printf "${BLUE}ℹ${RESET} %s\n" "$1"; }
_success() { printf "${GREEN}✓${RESET} %s\n" "$1"; }
_warn() { printf "${YELLOW}⚠${RESET} %s\n" "$1"; }
_error() { printf "${RED}✗${RESET} %s\n" "$1"; }
_step() { printf "\n${BOLD}━━━ %s ━━━${RESET}\n\n" "$1"; }

_has() { command -v "$1" > /dev/null 2>&1; }

# ============================================================================
# Detect Current Shell
# ============================================================================

detect_shell() {
    # -- $SHELL is the LOGIN shell, not necessarily the current one
    CURRENT_SHELL="$(basename "${SHELL:-sh}")"

    # -- Try to detect more precisely
    if [ -n "${ZSH_VERSION:-}" ]; then
        CURRENT_SHELL="zsh"
    elif [ -n "${BASH_VERSION:-}" ]; then
        CURRENT_SHELL="bash"
    elif [ -n "${FISH_VERSION:-}" ]; then
        CURRENT_SHELL="fish"
    elif [ -n "${NU_VERSION:-}" ]; then
        CURRENT_SHELL="nu"
    fi

    _info "Detected shell: ${CURRENT_SHELL}"
}

# ============================================================================
# Detect Platform
# ============================================================================

detect_platform() {
    PLATFORM="unknown"
    DISTRO="unknown"

    case "$(uname -s)" in
        Darwin) PLATFORM="darwin" ;;
        Linux)
            if grep -qi 'microsoft\|wsl' /proc/version 2> /dev/null; then
                PLATFORM="wsl"
            else
                PLATFORM="linux"
            fi
            if [ -f /etc/os-release ]; then
                DISTRO=$(. /etc/os-release && echo "${ID:-unknown}")
            fi
            ;;
    esac

    _info "Platform: ${PLATFORM} (${DISTRO})"
}

# ============================================================================
# Clone or Update Repository
# ============================================================================

setup_repo() {
    _step "Repository"

    if [ -d "${DOTFILES_DIR}/.git" ]; then
        _info "Existing dotfiles found — updating..."
        cd "$DOTFILES_DIR" && git pull --rebase --autostash 2> /dev/null
        _success "Repository updated"
    elif [ -d "$DOTFILES_DIR" ] && [ ! -d "${DOTFILES_DIR}/.git" ]; then
        _warn "${DOTFILES_DIR} exists but is not a git repo"
        _info "Skipping clone — using existing directory"
    else
        _info "Cloning dotfiles..."
        if _has git; then
            git clone --depth=1 "$REPO_URL" "$DOTFILES_DIR"
            _success "Repository cloned"
        else
            _error "Git is required. Install git first."
            exit 1
        fi
    fi
}

# ============================================================================
# Create Directory Structure
# ============================================================================

create_directories() {
    _step "Directories"

    for dir in \
        "${XDG_CONFIG_HOME}" \
        "${HOME}/.local/share" \
        "${HOME}/.local/state" \
        "${HOME}/.cache" \
        "${HOME}/.local/bin" \
        "${DOTFILES_DIR}/local" \
        "${DOTFILES_DIR}/cache" \
        "${DOTFILES_DIR}/generated" \
        "${DOTFILES_DIR}/shells/zsh" \
        "${DOTFILES_DIR}/shells/fish" \
        "${DOTFILES_DIR}/shells/bash" \
        "${DOTFILES_DIR}/shells/nushell"; do
        mkdir -p "$dir" 2> /dev/null
    done

    _success "Directory structure created"
}

# ============================================================================
# Create Shell-Specific Symlinks
# ============================================================================

link_shell() {
    _step "Shell Symlinks"

    local backup_suffix
    backup_suffix="bak.$(date +%Y%m%d_%H%M%S)"

    # ── ZSH ────────────────────────────────────────────────────────────────
    if _has zsh || [ "$CURRENT_SHELL" = "zsh" ]; then
        # Backup existing
        if [ -f "${HOME}/.zshenv" ] && [ ! -L "${HOME}/.zshenv" ]; then
            mv "${HOME}/.zshenv" "${HOME}/.zshenv.${backup_suffix}"
            _warn "Backed up existing ~/.zshenv"
        fi
        if [ -f "${DOTFILES_DIR}/shells/zsh/.zshenv" ]; then
            ln -sf "${DOTFILES_DIR}/shells/zsh/.zshenv" "${HOME}/.zshenv"
            _success "~/.zshenv → shells/zsh/.zshenv"
        fi
    fi

    # ── Bash ───────────────────────────────────────────────────────────────
    if _has bash || [ "$CURRENT_SHELL" = "bash" ]; then
        if [ -f "${DOTFILES_DIR}/shells/bash/.bashrc" ]; then
            if [ -f "${HOME}/.bashrc" ] && [ ! -L "${HOME}/.bashrc" ]; then
                mv "${HOME}/.bashrc" "${HOME}/.bashrc.${backup_suffix}"
                _warn "Backed up existing ~/.bashrc"
            fi
            ln -sf "${DOTFILES_DIR}/shells/bash/.bashrc" "${HOME}/.bashrc"
            _success "~/.bashrc → shells/bash/.bashrc"

            if [ -f "${DOTFILES_DIR}/shells/bash/.bash_profile" ]; then
                if [ -f "${HOME}/.bash_profile" ] && [ ! -L "${HOME}/.bash_profile" ]; then
                    mv "${HOME}/.bash_profile" "${HOME}/.bash_profile.${backup_suffix}"
                fi
                ln -sf "${DOTFILES_DIR}/shells/bash/.bash_profile" "${HOME}/.bash_profile"
                _success "~/.bash_profile → shells/bash/.bash_profile"
            fi
        else
            _info "Bash config not yet created (shells/bash/.bashrc)"
        fi
    fi

    # ── Fish ───────────────────────────────────────────────────────────────
    if _has fish || [ "$CURRENT_SHELL" = "fish" ]; then
        local fish_config_dir="${XDG_CONFIG_HOME}/fish"
        mkdir -p "$fish_config_dir"
        if [ -f "${DOTFILES_DIR}/shells/fish/config.fish" ]; then
            if [ -f "${fish_config_dir}/config.fish" ] && [ ! -L "${fish_config_dir}/config.fish" ]; then
                mv "${fish_config_dir}/config.fish" "${fish_config_dir}/config.fish.${backup_suffix}"
                _warn "Backed up existing fish config"
            fi
            ln -sf "${DOTFILES_DIR}/shells/fish/config.fish" "${fish_config_dir}/config.fish"
            _success "fish/config.fish → shells/fish/config.fish"
        else
            _info "Fish config not yet created (shells/fish/config.fish)"
        fi
    fi

    # ── Nushell ────────────────────────────────────────────────────────────
    if _has nu || [ "$CURRENT_SHELL" = "nu" ]; then
        local nu_config_dir="${XDG_CONFIG_HOME}/nushell"
        mkdir -p "$nu_config_dir"
        if [ -f "${DOTFILES_DIR}/shells/nushell/config.nu" ]; then
            ln -sf "${DOTFILES_DIR}/shells/nushell/config.nu" "${nu_config_dir}/config.nu"
            _success "nushell/config.nu → shells/nushell/config.nu"
        fi
        if [ -f "${DOTFILES_DIR}/shells/nushell/env.nu" ]; then
            ln -sf "${DOTFILES_DIR}/shells/nushell/env.nu" "${nu_config_dir}/env.nu"
            _success "nushell/env.nu → shells/nushell/env.nu"
        fi
        if [ ! -f "${DOTFILES_DIR}/shells/nushell/config.nu" ]; then
            _info "Nushell config not yet created (shells/nushell/config.nu)"
        fi
    fi

    # ── Starship (cross-shell prompt) ──────────────────────────────────────
    if [ -f "${DOTFILES_DIR}/themes/starship.toml" ]; then
        ln -sf "${DOTFILES_DIR}/themes/starship.toml" "${XDG_CONFIG_HOME}/starship.toml"
        _success "starship.toml → themes/starship.toml"
    fi
}

# ============================================================================
# Generate SSOT Files
# ============================================================================

generate_ssot() {
    _step "SSOT Generation"

    local gen_script="${DOTFILES_DIR}/ssot/generators/generate-all.sh"
    if [ -f "$gen_script" ]; then
        chmod +x "${DOTFILES_DIR}/ssot/generators/"*.sh 2> /dev/null
        if _has bash; then
            bash "$gen_script"
            _success "SSOT files generated for all shells"
        else
            _warn "Bash required for SSOT generation"
        fi
    else
        _warn "Generator script not found"
    fi
}

# ============================================================================
# Check Available Shells
# ============================================================================

check_shells() {
    _step "Available Shells"

    for shell_name in zsh bash fish nu; do
        if _has "$shell_name"; then
            local ver
            ver=$("$shell_name" --version 2> /dev/null | head -1 || echo "")
            _success "${shell_name} — ${ver}"
        else
            printf "  ${DIM}○ ${shell_name} (not installed)${RESET}\n"
        fi
    done

    echo ""
    _info "Default shell: ${SHELL:-unknown}"
}

# ============================================================================
# Install Missing Shell (optional)
# ============================================================================

offer_shell_install() {
    _step "Shell Setup"

    local missing_shells=""

    if ! _has zsh; then
        missing_shells="${missing_shells} zsh"
    fi

    if [ -z "$missing_shells" ]; then
        _success "ZSH is available"
        return
    fi

    _warn "Missing shells:${missing_shells}"
    _info "Install with your package manager:"

    if _has brew; then
        printf "  brew install%s\n" "$missing_shells"
    elif _has apt; then
        printf "  sudo apt install -y%s\n" "$missing_shells"
    elif _has dnf; then
        printf "  sudo dnf install -y%s\n" "$missing_shells"
    elif _has pacman; then
        printf "  sudo pacman -S%s\n" "$missing_shells"
    fi
}

# ============================================================================
# Summary
# ============================================================================

summary() {
    _step "Bootstrap Complete 🎉"

    printf "  ${BOLD}Dotfiles:${RESET}  %s\n" "$DOTFILES_DIR"
    printf "  ${BOLD}Platform:${RESET}  %s (%s)\n" "$PLATFORM" "$DISTRO"
    printf "  ${BOLD}Shell:${RESET}     %s\n" "$CURRENT_SHELL"

    printf "\n  ${BOLD}Configured shells:${RESET}\n"
    [ -L "${HOME}/.zshenv" ] && printf "    ✅ zsh\n" || printf "    ○ zsh\n"
    [ -L "${HOME}/.bashrc" ] && printf "    ✅ bash\n" || printf "    ○ bash\n"
    [ -L "${XDG_CONFIG_HOME}/fish/config.fish" ] 2> /dev/null && printf "    ✅ fish\n" || printf "    ○ fish\n"
    [ -L "${XDG_CONFIG_HOME}/nushell/config.nu" ] 2> /dev/null && printf "    ✅ nu\n" || printf "    ○ nu\n"

    printf "\n  ${BOLD}Next steps:${RESET}\n"
    printf "    1. Restart your shell:  ${GREEN}exec \$SHELL${RESET}\n"
    printf "    2. Run diagnostics:     ${GREEN}just doctor${RESET}\n"
    printf "    3. Check tools:         ${GREEN}just tools${RESET}\n"
    printf "\n"
}

# ============================================================================
# Main
# ============================================================================

main() {
    printf "\n${BOLD}  🚀 Dotfiles Bootstrap — Cross-Platform, Cross-Shell${RESET}\n"
    printf "  ${DIM}%s${RESET}\n\n" "$REPO_URL"

    detect_shell
    detect_platform
    setup_repo
    create_directories
    link_shell
    generate_ssot
    check_shells
    offer_shell_install
    summary
}

main "$@"
