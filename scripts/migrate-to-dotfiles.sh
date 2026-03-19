#!/usr/bin/env bash
# ============================================================================
# @file        scripts/migrate-to-dotfiles.sh
# @description Migrate from ~/.config/zsh/ structure to ~/dotfiles/ with
#              shells/ subdirectory. Moves files, updates symlinks, and
#              preserves git history.
#
# @usage       bash scripts/migrate-to-dotfiles.sh
#
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-15
# @version     1.0.0
# ============================================================================

set -uo pipefail

readonly OLD_DIR="${HOME}/.config/zsh"
readonly NEW_DIR="${HOME}/dotfiles"

readonly GREEN="\033[0;32m"
readonly YELLOW="\033[0;33m"
readonly RED="\033[0;31m"
readonly BOLD="\033[1m"
readonly RESET="\033[0m"

_info() { printf "${GREEN}ℹ${RESET} %s\n" "$1"; }
_warn() { printf "${YELLOW}⚠${RESET} %s\n" "$1"; }
_error() { printf "${RED}✗${RESET} %s\n" "$1"; }
_step() { printf "\n${BOLD}━━━ %s ━━━${RESET}\n\n" "$1"; }

main() {
    printf "\n${BOLD}  🚀 Dotfiles Migration Tool${RESET}\n\n"

    # ── Validation ──────────────────────────────────────────────────────────
    _step "Validation"

    if [[ ! -d "$OLD_DIR" ]]; then
        _error "Source directory not found: ${OLD_DIR}"
        exit 1
    fi

    if [[ -d "$NEW_DIR" ]] && [[ ! -d "${NEW_DIR}/.git" ]]; then
        _error "Target directory exists but is not a git repo: ${NEW_DIR}"
        exit 1
    fi

    _info "Source: ${OLD_DIR}"
    _info "Target: ${NEW_DIR}"

    # ── Create new structure ────────────────────────────────────────────────
    _step "Creating new directory structure"

    mkdir -p "${NEW_DIR}/shells/zsh"
    mkdir -p "${NEW_DIR}/shells/fish"
    mkdir -p "${NEW_DIR}/shells/bash"
    mkdir -p "${NEW_DIR}/shells/nushell"
    _info "Created shells/{zsh,fish,bash,nushell}"

    # ── Move ZSH-specific files ─────────────────────────────────────────────
    _step "Moving ZSH-specific files to shells/zsh/"

    # ZSH entry points
    for f in .zshenv .zshrc .zprofile .zlogin .zlogout; do
        if [[ -f "${OLD_DIR}/${f}" ]]; then
            mv "${OLD_DIR}/${f}" "${NEW_DIR}/shells/zsh/${f}"
            _info "Moved ${f} → shells/zsh/"
        fi
    done

    # ZSH-specific directories
    for d in core plugins terminal; do
        if [[ -d "${OLD_DIR}/${d}" ]]; then
            mv "${OLD_DIR}/${d}" "${NEW_DIR}/shells/zsh/${d}"
            _info "Moved ${d}/ → shells/zsh/"
        fi
    done

    # ── Move shared files ───────────────────────────────────────────────────
    _step "Moving shared files to dotfiles root"

    for d in ssot generated tools functions platform lib themes local cache scripts tests; do
        if [[ -d "${OLD_DIR}/${d}" ]]; then
            if [[ -d "${NEW_DIR}/${d}" ]]; then
                # Merge if target exists
                cp -a "${OLD_DIR}/${d}/"* "${NEW_DIR}/${d}/" 2> /dev/null
                rm -rf "${OLD_DIR}/${d}"
            else
                mv "${OLD_DIR}/${d}" "${NEW_DIR}/${d}"
            fi
            _info "Moved ${d}/ → dotfiles/"
        fi
    done

    # Root files
    for f in Justfile README.md LICENSE .gitignore .editorconfig; do
        if [[ -f "${OLD_DIR}/${f}" ]]; then
            mv "${OLD_DIR}/${f}" "${NEW_DIR}/${f}"
            _info "Moved ${f} → dotfiles/"
        fi
    done

    # ── Move .git if present ────────────────────────────────────────────────
    if [[ -d "${OLD_DIR}/.git" ]] && [[ ! -d "${NEW_DIR}/.git" ]]; then
        mv "${OLD_DIR}/.git" "${NEW_DIR}/.git"
        _info "Moved .git → dotfiles/"
    fi

    # ── Update symlinks ─────────────────────────────────────────────────────
    _step "Updating symlinks"

    # ~/.zshenv
    rm -f "${HOME}/.zshenv"
    ln -sf "${NEW_DIR}/shells/zsh/.zshenv" "${HOME}/.zshenv"
    _info "~/.zshenv → ${NEW_DIR}/shells/zsh/.zshenv"

    # starship.toml
    local starship_config="${XDG_CONFIG_HOME:-${HOME}/.config}/starship.toml"
    rm -f "$starship_config"
    ln -sf "${NEW_DIR}/themes/starship.toml" "$starship_config"
    _info "starship.toml symlinked"

    # ── Cleanup old directory ───────────────────────────────────────────────
    _step "Cleanup"

    if [[ -d "$OLD_DIR" ]]; then
        local remaining
        remaining=$(find "$OLD_DIR" -type f 2> /dev/null | wc -l | tr -d ' ')
        if [[ "$remaining" -eq 0 ]]; then
            rmdir "$OLD_DIR" 2> /dev/null && _info "Removed empty ${OLD_DIR}"
        else
            _warn "${OLD_DIR} still has ${remaining} files — review manually"
        fi
    fi

    # ── Summary ─────────────────────────────────────────────────────────────
    _step "Migration Complete 🎉"

    printf "  Structure:\n"
    printf "    ${NEW_DIR}/\n"
    printf "    ├── shells/zsh/    (ZSH-specific)\n"
    printf "    ├── shells/fish/   (placeholder)\n"
    printf "    ├── shells/bash/   (placeholder)\n"
    printf "    ├── shells/nushell/(placeholder)\n"
    printf "    ├── ssot/          (shared SSOT)\n"
    printf "    ├── tools/         (shared tool configs)\n"
    printf "    ├── lib/           (shared libraries)\n"
    printf "    └── ...            (shared resources)\n\n"

    printf "  Next steps:\n"
    printf "    1. ${BOLD}export DOTFILES_DIR=~/dotfiles${RESET}\n"
    printf "    2. ${BOLD}exec zsh${RESET}\n"
    printf "    3. ${BOLD}just doctor${RESET}\n\n"
}

main "$@"
