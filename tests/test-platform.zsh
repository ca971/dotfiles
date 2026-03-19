#!/usr/bin/env zsh
# ============================================================================
# @file        tests/test-platform.zsh
# @description Test suite for platform-specific configurations and generated
#              SSOT files. Validates that the correct platform modules load,
#              generated files have correct structure, and core components
#              integrate properly.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @usage       zsh tests/test-platform.zsh
#              just test
# ============================================================================

# ============================================================================
# Test Framework
# ============================================================================

typeset -gi _TEST_PASS=0
typeset -gi _TEST_FAIL=0
typeset -gi _TEST_SKIP=0
typeset -g  _TEST_SUITE="Platform & Integration"

_test_header() {
  printf "\n  🧪 Test Suite: %s\n" "$_TEST_SUITE"
  printf "  ═══════════════════════════════════\n\n"
}

_assert() {
  local description="$1"
  local condition="$2"
  if eval "$condition" 2>/dev/null; then
    printf "  ✅ %s\n" "$description"
    (( _TEST_PASS++ ))
  else
    printf "  ❌ %s\n" "$description"
    (( _TEST_FAIL++ ))
  fi
}

_assert_file_exists() { _assert "File exists: $1" "[[ -f '$1' ]]"; }
_assert_file_not_empty() { _assert "File not empty: $1" "[[ -s '$1' ]]"; }
_assert_file_contains() { _assert "${3:-Contains: $2}" "grep -q '$2' '$1'"; }

_skip() {
  printf "  ⏭️  %s (%s)\n" "$1" "${2:-skipped}"
  (( _TEST_SKIP++ ))
}

_test_summary() {
  printf "\n  ─────────────────────────────────\n"
  printf "  Pass: %d | Fail: %d | Skip: %d\n" "$_TEST_PASS" "$_TEST_FAIL" "$_TEST_SKIP"
  printf "  ─────────────────────────────────\n\n"
  (( _TEST_FAIL > 0 )) && return 1 || return 0
}

# ============================================================================
# Setup
# ============================================================================

readonly ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}"
export ZSH_LOG_LEVEL=5

source "${ZDOTDIR}/lib/logging.zsh" 2>/dev/null
source "${ZDOTDIR}/lib/platform-detect.zsh" 2>/dev/null
source "${ZDOTDIR}/lib/tool-check.zsh" 2>/dev/null

# ============================================================================
# Tests Begin
# ============================================================================

_test_header

# ============================================================================
# Tests: Platform Module Existence
# ============================================================================

printf "  ── Platform Modules ──\n\n"

_assert_file_exists "${ZDOTDIR}/platform/darwin.zsh"
_assert_file_exists "${ZDOTDIR}/platform/linux.zsh"
_assert_file_exists "${ZDOTDIR}/platform/wsl.zsh"
_assert_file_exists "${ZDOTDIR}/platform/arch.zsh"
_assert_file_exists "${ZDOTDIR}/platform/debian.zsh"
_assert_file_exists "${ZDOTDIR}/platform/fedora.zsh"

# -- Current platform module should be loadable
local current_platform_file="${ZDOTDIR}/platform/${ZSH_PLATFORM}.zsh"
if [[ -f "$current_platform_file" ]]; then
  _assert "Current platform module sources without error (${ZSH_PLATFORM})" \
    "zsh -c 'export ZSH_LOG_LEVEL=5; source \"${ZDOTDIR}/lib/logging.zsh\"; source \"${ZDOTDIR}/lib/platform-detect.zsh\"; source \"${current_platform_file}\"' 2>/dev/null"
else
  _skip "Current platform module load test" "File not found: ${current_platform_file}"
fi

# ============================================================================
# Tests: Terminal Modules
# ============================================================================

printf "\n  ── Terminal Modules ──\n\n"

_assert_file_exists "${ZDOTDIR}/terminal/ghostty.zsh"
_assert_file_exists "${ZDOTDIR}/terminal/wezterm.zsh"
_assert_file_exists "${ZDOTDIR}/terminal/kitty.zsh"
_assert_file_exists "${ZDOTDIR}/terminal/alacritty.zsh"
_assert_file_exists "${ZDOTDIR}/terminal/iterm.zsh"

# ============================================================================
# Tests: Core Configuration Files
# ============================================================================

printf "\n  ── Core Configuration ──\n\n"

local -a core_files=(
  "core/00-xdg.zsh"
  "core/01-platform.zsh"
  "core/02-options.zsh"
  "core/03-history.zsh"
  "core/04-completion.zsh"
  "core/05-keybindings.zsh"
  "core/06-security.zsh"
  "core/07-performance.zsh"
)

local f
for f in "${core_files[@]}"; do
  _assert_file_exists "${ZDOTDIR}/${f}"
done

# ============================================================================
# Tests: Generated SSOT Files Structure
# ============================================================================

printf "\n  ── Generated Files Structure ──\n\n"

local gen_dir="${ZDOTDIR}/generated"

if [[ -f "${gen_dir}/colors.zsh" ]]; then
  _assert_file_not_empty "${gen_dir}/colors.zsh"
  _assert_file_contains "${gen_dir}/colors.zsh" "ZSH_COLORS_" "colors.zsh defines ZSH_COLORS_ arrays"
  _assert_file_contains "${gen_dir}/colors.zsh" "color_fg" "colors.zsh defines color_fg function"
  _assert_file_contains "${gen_dir}/colors.zsh" "LS_COLORS" "colors.zsh exports LS_COLORS"
  _assert_file_contains "${gen_dir}/colors.zsh" "_ZSH_GENERATED_COLORS_LOADED" "colors.zsh has guard"
else
  _skip "colors.zsh structure tests" "Not generated"
fi

if [[ -f "${gen_dir}/icons.zsh" ]]; then
  _assert_file_not_empty "${gen_dir}/icons.zsh"
  _assert_file_contains "${gen_dir}/icons.zsh" "ZSH_ICONS" "icons.zsh defines ZSH_ICONS"
  _assert_file_contains "${gen_dir}/icons.zsh" "ICON_SUCCESS" "icons.zsh defines ICON_SUCCESS"
  _assert_file_contains "${gen_dir}/icons.zsh" "icon()" "icons.zsh defines icon() function"
  _assert_file_contains "${gen_dir}/icons.zsh" "ZSH_ICONS_ENABLED" "icons.zsh has enable flag"
else
  _skip "icons.zsh structure tests" "Not generated"
fi

if [[ -f "${gen_dir}/highlights.zsh" ]]; then
  _assert_file_not_empty "${gen_dir}/highlights.zsh"
  _assert_file_contains "${gen_dir}/highlights.zsh" "ZSH_HIGHLIGHT_STYLES" "highlights.zsh defines styles"
  _assert_file_contains "${gen_dir}/highlights.zsh" "ZSH_HIGHLIGHT_HIGHLIGHTERS" "highlights.zsh defines highlighters"
  _assert_file_contains "${gen_dir}/highlights.zsh" "ZSH_AUTOSUGGEST_STRATEGY" "highlights.zsh configures autosuggestions"
else
  _skip "highlights.zsh structure tests" "Not generated"
fi

# ============================================================================
# Tests: Tool Modules
# ============================================================================

printf "\n  ── Tool Modules ──\n\n"

local -a tool_files=(
  eza fzf bat fd ripgrep git delta zoxide atuin
  mise neovim starship docker kubernetes chezmoi direnv carapace yazi
  btop navi fastfetch just gpg gh dust topgrade thefuck lazygit tldr
)

local t
for t in "${tool_files[@]}"; do
  _assert_file_exists "${ZDOTDIR}/tools/${t}.zsh"
done

# ============================================================================
# Tests: Function Modules
# ============================================================================

printf "\n  ── Function Modules ──\n\n"

local -a func_files=(
  _helpers archive docker-helpers file-ops git-helpers
  kubernetes-helpers navigation network system update
)

for f in "${func_files[@]}"; do
  _assert_file_exists "${ZDOTDIR}/functions/${f}.zsh"
done

# ============================================================================
# Tests: XDG Directories Exist
# ============================================================================

printf "\n  ── XDG Directories ──\n\n"

_assert "XDG_CONFIG_HOME exists" "[[ -d '${XDG_CONFIG_HOME:-${HOME}/.config}' ]]"
_assert "XDG_DATA_HOME exists" "[[ -d '${XDG_DATA_HOME:-${HOME}/.local/share}' ]]"
_assert "XDG_CACHE_HOME exists" "[[ -d '${XDG_CACHE_HOME:-${HOME}/.cache}' ]]"
_assert "XDG_STATE_HOME exists" "[[ -d '${XDG_STATE_HOME:-${HOME}/.local/state}' ]]"

# ============================================================================
# Tests: Entry Points
# ============================================================================

printf "\n  ── Entry Points ──\n\n"

_assert_file_exists "${ZDOTDIR}/.zshenv"
_assert_file_exists "${ZDOTDIR}/.zshrc"
_assert_file_exists "${ZDOTDIR}/.zprofile"
_assert_file_exists "${ZDOTDIR}/.zlogin"
_assert_file_exists "${ZDOTDIR}/.zlogout"

_assert_file_contains "${ZDOTDIR}/.zshenv" "ZDOTDIR" ".zshenv sets ZDOTDIR"
_assert_file_contains "${ZDOTDIR}/.zshenv" "ZSH_CONFIG_VERSION" ".zshenv sets version"
_assert_file_contains "${ZDOTDIR}/.zshrc" "source" ".zshrc sources modules"

# ============================================================================
# Tests: Meta Files
# ============================================================================

printf "\n  ── Meta Files ──\n\n"

_assert_file_exists "${ZDOTDIR}/Justfile"
_assert_file_exists "${ZDOTDIR}/.gitignore"
_assert_file_exists "${ZDOTDIR}/.editorconfig"
_assert_file_exists "${ZDOTDIR}/README.md"
_assert_file_exists "${ZDOTDIR}/LICENSE"

# ============================================================================
# Summary
# ============================================================================

_test_summary
