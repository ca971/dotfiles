#!/usr/bin/env bash
# ============================================================================
# @file        ssot/generators/generate-all.sh
# @description Master generator that orchestrates all SSOT transpilers.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
#
# @changelog   1.1.0 — Fixed Bash 3.x compat (macOS). Removed associative
#              arrays. Replaced with simple sequential execution.
# ============================================================================

set -uo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
GENERATORS_DIR="${CONFIG_ROOT}/ssot/generators"
GENERATED_DIR="${CONFIG_ROOT}/generated"

readonly COLOR_GREEN="\033[0;32m"
readonly COLOR_YELLOW="\033[0;33m"
readonly COLOR_RED="\033[0;31m"
readonly COLOR_BLUE="\033[0;34m"
readonly COLOR_BOLD="\033[1m"
readonly COLOR_RESET="\033[0m"

_info() { printf "${COLOR_BLUE}ℹ${COLOR_RESET} %s\n" "$1"; }
_success() { printf "${COLOR_GREEN}✓${COLOR_RESET} %s\n" "$1"; }
_warn() { printf "${COLOR_YELLOW}⚠${COLOR_RESET} %s\n" "$1"; }
_error() { printf "${COLOR_RED}✗${COLOR_RESET} %s\n" "$1"; }

# ============================================================================
# Main
# ============================================================================

main() {
    local start_time
    start_time=$(date +%s)

    printf "\n${COLOR_BOLD}━━━ SSOT Generator Pipeline ━━━${COLOR_RESET}\n\n"

    mkdir -p "$GENERATED_DIR"

    local total=0
    local success=0
    local failed=0

    # -- Generate Aliases
    total=$((total + 1))
    _info "Generating Aliases (zsh/fish/nu/bash)..."
    if bash "${GENERATORS_DIR}/generate-aliases.sh"; then
        _success "Aliases generated"
        success=$((success + 1))
    else
        _error "Aliases generation failed"
        failed=$((failed + 1))
    fi

    # -- Generate Colors
    total=$((total + 1))
    _info "Generating Colors..."
    if bash "${GENERATORS_DIR}/generate-colors.sh"; then
        _success "Colors generated"
        success=$((success + 1))
    else
        _error "Colors generation failed"
        failed=$((failed + 1))
    fi

    # -- Generate Icons
    total=$((total + 1))
    _info "Generating Icons..."
    if bash "${GENERATORS_DIR}/generate-icons.sh"; then
        _success "Icons generated"
        success=$((success + 1))
    else
        _error "Icons generation failed"
        failed=$((failed + 1))
    fi

    # -- Generate Highlights
    total=$((total + 1))
    _info "Generating Highlights..."
    if bash "${GENERATORS_DIR}/generate-highlights.sh"; then
        _success "Highlights generated"
        success=$((success + 1))
    else
        _error "Highlights generation failed"
        failed=$((failed + 1))
    fi

    # -- Summary
    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - start_time))

    printf "\n${COLOR_BOLD}━━━ Generation Complete ━━━${COLOR_RESET}\n"
    printf "  Total:   %d\n" "$total"
    printf "  ${COLOR_GREEN}Success: %d${COLOR_RESET}\n" "$success"
    if [ "$failed" -gt 0 ]; then
        printf "  ${COLOR_RED}Failed:  %d${COLOR_RESET}\n" "$failed"
    fi
    printf "  Time:    %ds\n" "$elapsed"
    printf "  Output:  %s/\n\n" "$GENERATED_DIR"

    ls -lh "$GENERATED_DIR"/ 2> /dev/null
    printf "\n"

    return "$failed"
}

main "$@"
