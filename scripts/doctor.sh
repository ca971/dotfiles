#!/usr/bin/env bash
# ============================================================================
# @file        scripts/doctor.sh
# @description Diagnostic and health check script for the dotfiles system.
#              Validates installation integrity, checks tool availability,
#              verifies file permissions, and reports potential issues.
#              Supports the new cross-shell dotfiles/ architecture.
#
# @usage       bash ~/dotfiles/scripts/doctor.sh
#              just doctor
#
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     2.0.0
#
# @changelog   2.0.0 — Updated for dotfiles/ architecture with shells/ subdir.
#              CONFIG_DIR now resolves to DOTFILES_DIR.
#              ZSH-specific files checked in shells/zsh/.
#              Shared files checked at dotfiles root.
#              Fixed stat permissions for macOS.
# ============================================================================

set -uo pipefail

# ============================================================================
# Configuration — Resolve dotfiles root
# ============================================================================

# @description  Find the dotfiles root directory.
#               Priority: DOTFILES_DIR env → script location → fallback
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"

readonly DOTFILES_DIR
readonly ZSH_DIR="${DOTFILES_DIR}/shells/zsh"

readonly GREEN="\033[0;32m"
readonly YELLOW="\033[0;33m"
readonly RED="\033[0;31m"
readonly BLUE="\033[0;34m"
readonly DIM="\033[2m"
readonly BOLD="\033[1m"
readonly RESET="\033[0m"

PASS=0
WARN=0
FAIL=0

_pass() {
    printf "  ${GREEN}✓${RESET} %s\n" "$1"
    PASS=$((PASS + 1))
}
_warn() {
    printf "  ${YELLOW}⚠${RESET} %s\n" "$1"
    WARN=$((WARN + 1))
}
_fail() {
    printf "  ${RED}✗${RESET} %s\n" "$1"
    FAIL=$((FAIL + 1))
}
_info() { printf "  ${DIM}ℹ${RESET} %s\n" "$1"; }
_section() { printf "\n${BOLD}  ── %s ──${RESET}\n\n" "$1"; }
_has() { command -v "$1" > /dev/null 2>&1; }

# @description  Get file permissions (cross-platform, handles GNU vs BSD stat)
# @param  $1    string  File path
# @return       Permission string (e.g., "700")
_get_perms() {
    local file="$1"

    # -- Try BSD stat first (macOS native)
    if /usr/bin/stat -f '%Lp' "$file" 2> /dev/null; then
        return
    fi

    # -- Try GNU stat
    if stat -c '%a' "$file" 2> /dev/null; then
        return
    fi

    # -- Fallback: parse ls -ld output
    local ls_perms
    ls_perms=$(ls -ld "$file" 2> /dev/null | awk '{print $1}')
    if [ -n "$ls_perms" ]; then
        # Convert rwxrwxrwx to octal
        local octal=0
        local i char val
        for i in 1 2 3 4 5 6 7 8 9; do
            char=$(echo "$ls_perms" | cut -c$((i + 1)))
            case $char in
                r) val=4 ;; w) val=2 ;; x | s | t) val=1 ;; *) val=0 ;;
            esac
            octal=$((octal + val))
            if [ $((i % 3)) -eq 0 ] && [ "$i" -lt 9 ]; then
                printf "%d" "$octal"
                octal=0
            fi
        done
        printf "%d" "$octal"
        return
    fi

    echo "unknown"
}

# ============================================================================
# Check: Directory Structure
# ============================================================================

check_structure() {
    _section "Directory Structure"

    # -- Dotfiles root
    if [ -d "$DOTFILES_DIR" ]; then
        _pass "Dotfiles root: ${DOTFILES_DIR}"
    else
        _fail "Dotfiles root not found: ${DOTFILES_DIR}"
        return
    fi

    # -- Shared directories (at dotfiles root)
    local dir
    for dir in \
        ssot ssot/generators generated \
        tools functions platform \
        lib themes local cache scripts tests; do
        if [ -d "${DOTFILES_DIR}/${dir}" ]; then
            _pass "${dir}/"
        else
            _fail "${dir}/ — MISSING"
        fi
    done

    # -- Shell directories
    for dir in shells shells/zsh shells/fish shells/bash shells/nushell; do
        if [ -d "${DOTFILES_DIR}/${dir}" ]; then
            _pass "${dir}/"
        else
            _warn "${dir}/ — MISSING (create with: mkdir -p ~/dotfiles/${dir})"
        fi
    done
}

# ============================================================================
# Check: ZSH-Specific Files (shells/zsh/)
# ============================================================================

check_zsh_files() {
    _section "ZSH Configuration (shells/zsh/)"

    local file
    for file in .zshenv .zshrc .zprofile .zlogin .zlogout; do
        if [ -f "${ZSH_DIR}/${file}" ]; then
            _pass "shells/zsh/${file}"
        else
            _fail "shells/zsh/${file} — MISSING"
        fi
    done

    # -- ZSH subdirectories
    for dir in core plugins terminal; do
        if [ -d "${ZSH_DIR}/${dir}" ]; then
            _pass "shells/zsh/${dir}/"
        else
            _fail "shells/zsh/${dir}/ — MISSING"
        fi
    done

    # -- Core files
    for file in \
        core/00-xdg.zsh core/01-platform.zsh core/02-options.zsh \
        core/03-history.zsh core/04-completion.zsh core/05-keybindings.zsh \
        core/06-security.zsh core/07-performance.zsh; do
        if [ -f "${ZSH_DIR}/${file}" ]; then
            _pass "shells/zsh/${file}"
        else
            _warn "shells/zsh/${file} — MISSING"
        fi
    done
}

# ============================================================================
# Check: Shared Files (dotfiles root)
# ============================================================================

check_shared_files() {
    _section "Shared Configuration"

    # -- Libraries
    local file
    for file in \
        lib/logging.zsh lib/platform-detect.zsh lib/tool-check.zsh \
        lib/lazy-load.zsh lib/toml-parser.zsh; do
        if [ -f "${DOTFILES_DIR}/${file}" ]; then
            _pass "${file}"
        else
            _fail "${file} — MISSING"
        fi
    done

    # -- SSOT source files
    for file in \
        ssot/aliases.toml ssot/colors.toml ssot/icons.toml \
        ssot/settings.toml ssot/highlights.toml ssot/tools.toml; do
        if [ -f "${DOTFILES_DIR}/${file}" ]; then
            _pass "${file}"
        else
            _fail "${file} — MISSING"
        fi
    done

    # -- Meta files
    for file in Justfile README.md LICENSE .gitignore .editorconfig; do
        if [ -f "${DOTFILES_DIR}/${file}" ]; then
            _pass "${file}"
        else
            _warn "${file} — MISSING"
        fi
    done
}

# ============================================================================
# Check: Symlinks
# ============================================================================

check_symlinks() {
    _section "Symlinks"

    # -- ~/.zshenv
    if [ -L "${HOME}/.zshenv" ]; then
        local target
        target=$(readlink "${HOME}/.zshenv" 2> /dev/null || echo "unknown")
        if echo "$target" | grep -q "dotfiles/shells/zsh/.zshenv"; then
            _pass "~/.zshenv → ${target}"
        elif echo "$target" | grep -q ".zshenv"; then
            _warn "~/.zshenv → ${target} (expected: dotfiles/shells/zsh/.zshenv)"
        else
            _warn "~/.zshenv → ${target} (unexpected target)"
        fi
    elif [ -f "${HOME}/.zshenv" ]; then
        _warn "~/.zshenv exists but is not a symlink"
    else
        _fail "~/.zshenv — MISSING (run: just link)"
    fi

    # -- ~/.bashrc
    if [ -L "${HOME}/.bashrc" ]; then
        _pass "~/.bashrc → $(readlink "${HOME}/.bashrc" 2> /dev/null)"
    elif [ -f "${DOTFILES_DIR}/shells/bash/.bashrc" ]; then
        _warn "~/.bashrc not linked (run: just link)"
    else
        _info "Bash config not yet created"
    fi

    # -- fish
    local fish_config="${XDG_CONFIG_HOME:-${HOME}/.config}/fish/config.fish"
    if [ -L "$fish_config" ]; then
        _pass "fish/config.fish → $(readlink "$fish_config" 2> /dev/null)"
    elif [ -f "${DOTFILES_DIR}/shells/fish/config.fish" ]; then
        _warn "fish config not linked (run: just link)"
    else
        _info "Fish config not yet created"
    fi

    # -- nushell
    local nu_config="${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/config.nu"
    if [ -L "$nu_config" ]; then
        _pass "nushell/config.nu → $(readlink "$nu_config" 2> /dev/null)"
    elif [ -f "${DOTFILES_DIR}/shells/nushell/config.nu" ]; then
        _warn "nushell config not linked (run: just link)"
    else
        _info "Nushell config not yet created"
    fi

    # -- starship.toml
    local starship_config="${XDG_CONFIG_HOME:-${HOME}/.config}/starship.toml"
    if [ -f "$starship_config" ] || [ -L "$starship_config" ]; then
        _pass "starship.toml"
    else
        _warn "starship.toml not found (run: just link)"
    fi
}

# ============================================================================
# Check: SSOT Generated Files
# ============================================================================

check_generated() {
    _section "SSOT Generated Files"

    local file
    for file in \
        generated/aliases.zsh \
        generated/aliases.fish \
        generated/aliases.nu \
        generated/aliases.bash \
        generated/colors.zsh \
        generated/icons.zsh \
        generated/highlights.zsh; do
        if [ -f "${DOTFILES_DIR}/${file}" ]; then
            local lines
            lines=$(wc -l < "${DOTFILES_DIR}/${file}" 2> /dev/null | tr -d ' ')
            if [ "${lines:-0}" -gt 5 ]; then
                _pass "${file} (${lines} lines)"
            else
                _warn "${file} — seems empty (${lines} lines)"
            fi
        else
            _warn "${file} — not generated (run: just generate-all)"
        fi
    done
}

# ============================================================================
# Check: Essential Tools
# ============================================================================

check_tools() {
    _section "Essential Tools"

    local entry tool desc required
    for entry in \
        "zsh:Shell:yes" \
        "git:Version control:yes" \
        "nvim:Editor:no" \
        "starship:Prompt:no" \
        "fzf:Fuzzy finder:no" \
        "eza:Modern ls:no" \
        "bat:Modern cat:no" \
        "fd:Modern find:no" \
        "rg:Ripgrep:no" \
        "zoxide:Smart cd:no" \
        "delta:Git diff pager:no" \
        "atuin:Shell history:no" \
        "mise:Runtime manager:no" \
        "direnv:Dir environments:no"; do

        tool="${entry%%:*}"
        local rest="${entry#*:}"
        desc="${rest%%:*}"
        required="${rest##*:}"

        if _has "$tool"; then
            local ver=""
            ver=$("$tool" --version 2> /dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1) || true
            _pass "${tool} ${ver:+(${ver})} — ${desc}"
        else
            if [ "$required" = "yes" ]; then
                _fail "${tool} — ${desc} (REQUIRED)"
            else
                _warn "${tool} — ${desc} (recommended)"
            fi
        fi
    done

    _section "Optional Tools"

    local opt_tool
    for opt_tool in \
        carapace yazi lazygit lazydocker btop navi fastfetch \
        just gh dust duf topgrade thefuck tldr most chezmoi \
        docker podman kubectl; do
        if _has "$opt_tool"; then
            _pass "$opt_tool"
        else
            printf "  ${DIM}○${RESET} %s ${DIM}(not installed)${RESET}\n" "$opt_tool"
        fi
    done
}

# ============================================================================
# Check: Permissions
# ============================================================================

check_permissions() {
    _section "File Permissions"

    # -- History file
    local histfile="${HOME}/.local/share/zsh/history"
    if [ -f "$histfile" ]; then
        local perms
        perms=$(_get_perms "$histfile")
        if [ "$perms" = "600" ]; then
            _pass "History file: 600"
        else
            _warn "History file: ${perms} (should be 600)"
        fi
    else
        _info "History file not yet created"
    fi

    # -- SSH directory
    if [ -d "${HOME}/.ssh" ]; then
        local ssh_perms
        ssh_perms=$(_get_perms "${HOME}/.ssh")
        if [ "$ssh_perms" = "700" ]; then
            _pass "SSH directory: 700"
        else
            _warn "SSH directory: ${ssh_perms} (should be 700)"
        fi
    fi

    # -- GnuPG directory
    local gnupg_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/gnupg"
    if [ -d "$gnupg_dir" ]; then
        local gpg_perms
        gpg_perms=$(_get_perms "$gnupg_dir")
        if [ "$gpg_perms" = "700" ]; then
            _pass "GnuPG directory: 700"
        else
            _warn "GnuPG directory: ${gpg_perms} (should be 700)"
        fi
    fi

    # -- Local secrets file
    local secrets_file="${DOTFILES_DIR}/local/secrets.zsh"
    if [ -f "$secrets_file" ]; then
        local sec_perms
        sec_perms=$(_get_perms "$secrets_file")
        if [ "$sec_perms" = "600" ]; then
            _pass "Secrets file: 600"
        else
            _warn "Secrets file: ${sec_perms} (should be 600 — chmod 600 ${secrets_file})"
        fi
    fi
}

# ============================================================================
# Check: Environment
# ============================================================================

check_environment() {
    _section "Environment"

    # -- DOTFILES_DIR
    if [ -d "${DOTFILES_DIR}" ]; then
        _pass "DOTFILES_DIR=${DOTFILES_DIR}"
    else
        _fail "DOTFILES_DIR=${DOTFILES_DIR} (directory not found)"
    fi

    # -- ZDOTDIR
    local zdotdir="${ZDOTDIR:-}"
    if echo "$zdotdir" | grep -q "shells/zsh"; then
        _pass "ZDOTDIR=${zdotdir}"
    elif echo "$zdotdir" | grep -q "zsh"; then
        _warn "ZDOTDIR=${zdotdir} (expected: dotfiles/shells/zsh)"
    elif [ -n "$zdotdir" ]; then
        _warn "ZDOTDIR=${zdotdir} (unexpected path)"
    else
        _warn "ZDOTDIR not set"
    fi

    # -- XDG variables
    local var val
    for var in XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME XDG_STATE_HOME; do
        eval "val=\${${var}:-}"
        if [ -n "$val" ]; then
            _pass "${var}=${val}"
        else
            _warn "${var} not set (will use defaults)"
        fi
    done

    # -- Shell
    local current_shell
    current_shell=$(basename "${SHELL:-unknown}")
    if [ "$current_shell" = "zsh" ]; then
        _pass "Default shell: zsh"
    else
        _warn "Default shell: ${current_shell} (ZSH recommended)"
    fi

    # -- Available shells
    printf "\n  ${BOLD}Available shells:${RESET}\n"
    local sh_name
    for sh_name in zsh bash fish nu; do
        if _has "$sh_name"; then
            local sh_ver
            sh_ver=$("$sh_name" --version 2> /dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1) || true
            printf "    ${GREEN}✓${RESET} %-8s %s\n" "$sh_name" "${sh_ver:-}"
        else
            printf "    ${DIM}○ %-8s (not installed)${RESET}\n" "$sh_name"
        fi
    done

    # -- Terminal
    local term="${TERM_PROGRAM:-${TERM:-unknown}}"
    _pass "Terminal: ${term}"

    # -- Locale
    local lang="${LANG:-}"
    if echo "$lang" | grep -qi "utf-8"; then
        _pass "Locale: ${lang} (UTF-8)"
    else
        _warn "Locale: ${lang:-not set} (UTF-8 recommended)"
    fi

    # -- Nerd Font
    printf "\n  ${DIM}ℹ${RESET} Nerd Font: "
    printf "Test glyphs:      — if broken, install a Nerd Font\n"
}

# ============================================================================
# Check: Performance
# ============================================================================

check_performance() {
    _section "Performance"

    # -- Count ZSH files and compiled versions
    local total_zsh compiled_zsh pct

    # Search in both shells/zsh/ and shared dirs
    total_zsh=$(find "$DOTFILES_DIR" -name "*.zsh" \
        -not -path "*/cache/*" \
        -not -path "*/.git/*" \
        -not -path "*/generated/*" \
        2> /dev/null | wc -l | tr -d ' ')

    compiled_zsh=$(find "$DOTFILES_DIR" -name "*.zwc" \
        -not -path "*/cache/*" \
        -not -path "*/.git/*" \
        2> /dev/null | wc -l | tr -d ' ')

    total_zsh="${total_zsh:-0}"
    compiled_zsh="${compiled_zsh:-0}"
    pct=0
    if [ "$total_zsh" -gt 0 ]; then
        pct=$((compiled_zsh * 100 / total_zsh))
    fi

    if [ "$pct" -ge 80 ]; then
        _pass "ZSH compilation: ${compiled_zsh}/${total_zsh} files (${pct}%)"
    else
        _warn "ZSH compilation: ${compiled_zsh}/${total_zsh} files (${pct}%) — run: just upgrade"
    fi

    if _has "zsh"; then
        _pass "Run 'just benchmark' for startup time measurement"
    fi
}

# ============================================================================
# Summary
# ============================================================================

summary() {
    printf "\n${BOLD}  ── Summary ──${RESET}\n\n"
    printf "  ${GREEN}✓ Pass:${RESET} %d\n" "$PASS"
    if [ "$WARN" -gt 0 ]; then
        printf "  ${YELLOW}⚠ Warn:${RESET} %d\n" "$WARN"
    fi
    if [ "$FAIL" -gt 0 ]; then
        printf "  ${RED}✗ Fail:${RESET} %d\n" "$FAIL"
    fi

    printf "\n"
    if [ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ]; then
        printf "  ${GREEN}${BOLD}🎉 Everything looks great!${RESET}\n"
    elif [ "$FAIL" -eq 0 ]; then
        printf "  ${YELLOW}${BOLD}⚠ Some warnings — review above${RESET}\n"
    else
        printf "  ${RED}${BOLD}❌ Issues found — fix failures above${RESET}\n"
    fi
    printf "\n"
}

# ============================================================================
# Main
# ============================================================================

main() {
    printf "\n${BOLD}  🩺 Dotfiles Health Check${RESET}\n"
    printf "  ${DIM}%s${RESET}\n" "$DOTFILES_DIR"

    check_structure
    check_zsh_files
    check_shared_files
    check_symlinks
    check_generated
    check_tools
    check_permissions
    check_environment
    check_performance
    summary

    if [ "$FAIL" -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"
