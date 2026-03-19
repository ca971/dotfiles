#!/usr/bin/env bash
# ============================================================================
# @file        bin/dot.d/_core.sh
# @description Shared core: SSOT colors, icons, helper functions.
#              Sourced by all dot.d/ modules.
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @version     1.0.0
#
# shellcheck disable=SC2034
# ============================================================================

# ── Globals ──────────────────────────────────────────────────────────────────
export DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"
export THEMES_DIR="${DOTFILES_DIR}/themes"
export VERSION="3.0.0"

# ── SSOT Colors — Catppuccin Mocha ───────────────────────────────────────────
if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ] && [ "${TERM:-dumb}" != "dumb" ]; then
    export C_RED=$'\033[38;2;243;139;168m'
    export C_GREEN=$'\033[38;2;166;227;161m'
    export C_YELLOW=$'\033[38;2;249;226;175m'
    export C_BLUE=$'\033[38;2;137;180;250m'
    export C_MAUVE=$'\033[38;2;203;166;247m'
    export C_TEAL=$'\033[38;2;148;226;213m'
    export C_SKY=$'\033[38;2;137;220;254m'
    export C_PEACH=$'\033[38;2;250;179;135m'
    export C_LAVENDER=$'\033[38;2;180;190;254m'
    export C_TEXT=$'\033[38;2;205;214;244m'
    export C_SUBTEXT=$'\033[38;2;166;173;200m'
    export C_OVERLAY=$'\033[38;2;108;112;134m'
    export C_SURFACE=$'\033[38;2;69;71;90m'
    export C_SUCCESS="$C_GREEN"
    export C_ERROR="$C_RED"
    export C_WARNING="$C_YELLOW"
    export C_INFO="$C_BLUE"
    export C_ACCENT="$C_MAUVE"
    export C_MUTED="$C_OVERLAY"
    export S_BOLD=$'\033[1m'
    export S_DIM=$'\033[2m'
    export S_RESET=$'\033[0m'
else
    export C_RED="" C_GREEN="" C_YELLOW="" C_BLUE="" C_MAUVE="" C_TEAL=""
    export C_SKY="" C_PEACH="" C_LAVENDER="" C_TEXT="" C_SUBTEXT="" C_OVERLAY=""
    export C_SURFACE="" C_SUCCESS="" C_ERROR="" C_WARNING="" C_INFO="" C_ACCENT=""
    export C_MUTED="" S_BOLD="" S_DIM="" S_RESET=""
fi

# ── SSOT Icons — Nerd Font v3 ────────────────────────────────────────────────
export I_SUCCESS="✓" I_ERROR="✗" I_WARNING="" I_INFO=""
export I_ROCKET="" I_LIGHTNING="" I_LOADING="" I_SHIELD="󰒃"
export I_SEARCH="" I_SETTINGS="" I_CLOCK="" I_FOLDER=""
export I_FILE="" I_CODE="" I_TERMINAL="" I_GIT=""
export I_DOCKER="" I_PACKAGE="" I_K8S="☸" I_LINUX=""
export I_MACOS="" I_WINDOWS="" I_ARROW="" I_CHEVRON=""
export I_BRANCH="" I_STAR="" I_PALETTE="🎨"

# ── Helpers ──────────────────────────────────────────────────────────────────
_ok() { printf '  %b %s\n' "${C_SUCCESS}${I_SUCCESS}${S_RESET}" "$1"; }
_err() { printf '  %b %s\n' "${C_ERROR}${I_ERROR}${S_RESET}" "$1"; }
_warn() { printf '  %b %s\n' "${C_WARNING}${I_WARNING}${S_RESET}" "$1"; }
_info() { printf '  %b %s\n' "${C_INFO}${I_INFO}${S_RESET}" "$1"; }
_section() { printf '\n  %b━━━ %s ━━━%b\n\n' "${S_BOLD}${C_LAVENDER}" "$1" "$S_RESET"; }
_separator() { printf '  %b─────────────────────────────────────────────────%b\n' "$C_SURFACE" "$S_RESET"; }
_kv() { printf '  %b%-14s%b %b\n' "$C_SUBTEXT" "$1" "$S_RESET" "$2"; }
_has() { command -v "$1" > /dev/null 2>&1; }

_banner() {
    printf '\n  %b%b%b  dot%b %b— Dotfiles CLI%b %bv%s%b\n' \
        "$C_MAUVE" "$S_BOLD" "$I_TERMINAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET" "$C_OVERLAY" "$VERSION" "$S_RESET"
    printf '  %b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n' "$C_SURFACE" "$S_RESET"
}

_detect_shell() {
    if [ -n "${ZSH_VERSION:-}" ]; then
        echo "zsh ${ZSH_VERSION}"
    elif [ -n "${BASH_VERSION:-}" ]; then
        echo "bash ${BASH_VERSION}"
    elif [ -n "${FISH_VERSION:-}" ]; then
        echo "fish ${FISH_VERSION}"
    else basename "${SHELL:-sh}"; fi
}

_os_icon() {
    case "$(uname -s)" in
        Darwin) echo "$I_MACOS" ;; Linux) echo "$I_LINUX" ;; *) echo "$I_TERMINAL" ;;
    esac
}

_stat_mtime() {
    if [ "$(uname -s)" = "Darwin" ]; then
        /usr/bin/stat -f%m "$1" 2> /dev/null
    else stat -c%Y "$1" 2> /dev/null; fi
}
