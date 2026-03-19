#!/usr/bin/env bash
# ============================================================================
# @file        scripts/update.sh
# @description Self-update mechanism for the ZSH configuration framework.
#              Pulls latest changes from Git, regenerates SSOT files,
#              recompiles ZSH files, and updates plugins.
#
# @usage       bash ~/.config/zsh/scripts/update.sh
#              just update
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

readonly CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/zsh"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[0;33m"
readonly RED="\033[0;31m"
readonly BLUE="\033[0;34m"
readonly BOLD="\033[1m"
readonly RESET="\033[0m"

_info() { printf "${BLUE}ℹ${RESET} %s\n" "$1"; }
_success() { printf "${GREEN}✓${RESET} %s\n" "$1"; }
_warn() { printf "${YELLOW}⚠${RESET} %s\n" "$1"; }
_error() { printf "${RED}✗${RESET} %s\n" "$1"; }
_step() { printf "\n${BOLD}━━━ %s ━━━${RESET}\n\n" "$1"; }

# ============================================================================
# Update Steps
# ============================================================================

update_repo() {
    _step "Updating Configuration Repository"

    if [[ ! -d "${CONFIG_DIR}/.git" ]]; then
        _error "Not a git repository: ${CONFIG_DIR}"
        return 1
    fi

    cd "$CONFIG_DIR"

    # -- Check for local changes
    if ! git diff --quiet 2> /dev/null || ! git diff --cached --quiet 2> /dev/null; then
        _warn "Local changes detected — using autostash"
    fi

    # -- Pull with rebase and autostash
    if git pull --rebase --autostash 2> /dev/null; then
        local commits
        commits=$(git log --oneline HEAD@{1}..HEAD 2> /dev/null | wc -l | tr -d ' ')
        if ((commits > 0)); then
            _success "Updated: ${commits} new commit(s)"
            git log --oneline HEAD@{1}..HEAD 2> /dev/null | head -10 | while read -r line; do
                printf "  ${BLUE}•${RESET} %s\n" "$line"
            done
        else
            _success "Already up to date"
        fi
    else
        _error "Git pull failed — resolve conflicts manually"
        return 1
    fi
}

regenerate_ssot() {
    _step "Regenerating SSOT Files"

    local gen_script="${CONFIG_DIR}/ssot/generators/generate-all.sh"
    if [[ -f "$gen_script" ]]; then
        bash "$gen_script" && _success "SSOT files regenerated" \
            || _warn "SSOT generation had issues"
    else
        _warn "Generator script not found"
    fi
}

recompile_zsh() {
    _step "Recompiling ZSH Files"

    local count=0
    while IFS= read -r -d '' file; do
        zsh -c "zcompile '$file'" 2> /dev/null && ((count++)) || true
    done < <(find "$CONFIG_DIR" -name "*.zsh" -not -path "*/cache/*" -print0 2> /dev/null)

    _success "Compiled ${count} ZSH files"
}

clean_stale() {
    _step "Cleaning Stale Files"

    # -- Remove orphaned .zwc files (compiled files without source)
    local cleaned=0
    while IFS= read -r -d '' zwc; do
        local src="${zwc%.zwc}"
        if [[ ! -f "$src" ]]; then
            rm -f "$zwc"
            ((cleaned++))
        fi
    done < <(find "$CONFIG_DIR" -name "*.zwc" -print0 2> /dev/null)

    if ((cleaned > 0)); then
        _success "Removed ${cleaned} orphaned .zwc files"
    else
        _success "No stale files found"
    fi
}

# ============================================================================
# Version Check
# ============================================================================

show_version() {
    _step "Version Info"

    local current_version
    current_version=$(grep 'ZSH_CONFIG_VERSION' "${CONFIG_DIR}/.zshenv" 2> /dev/null \
        | grep -oP '"[^"]*"' | tr -d '"' || echo "unknown")

    local git_hash
    git_hash=$(git -C "$CONFIG_DIR" rev-parse --short HEAD 2> /dev/null || echo "unknown")

    local git_date
    git_date=$(git -C "$CONFIG_DIR" log -1 --format='%ci' 2> /dev/null | cut -d' ' -f1 || echo "unknown")

    printf "  Version: %s\n" "$current_version"
    printf "  Commit:  %s (%s)\n" "$git_hash" "$git_date"
    printf "  Path:    %s\n" "$CONFIG_DIR"
}

# ============================================================================
# Main
# ============================================================================

main() {
    printf "\n${BOLD}  🔄 ZSH Configuration Update${RESET}\n\n"

    local start_time
    start_time=$(date +%s)

    update_repo
    regenerate_ssot
    recompile_zsh
    clean_stale
    show_version

    local end_time elapsed
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))

    printf "\n${BOLD}  ✅ Update complete in %ds${RESET}\n" "$elapsed"
    printf "  ${DIM}Restart your shell to apply changes: exec zsh${RESET}\n\n"
}

main "$@"
