#!/usr/bin/env zsh
# ============================================================================
# @file        tests/test-functions.zsh
# @description Test suite for core library functions and utility helpers.
#              Validates logging, platform detection, tool checking, TOML
#              parsing, and helper functions work correctly.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @usage       zsh tests/test-functions.zsh
#              just test
# ============================================================================

# ============================================================================
# Test Framework
# ============================================================================

typeset -gi _TEST_PASS=0
typeset -gi _TEST_FAIL=0
typeset -gi _TEST_SKIP=0
typeset -g  _TEST_SUITE="Functions & Libraries"

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

_assert_eq() {
  local description="$1"
  local actual="$2"
  local expected="$3"
  if [[ "$actual" == "$expected" ]]; then
    printf "  ✅ %s\n" "$description"
    (( _TEST_PASS++ ))
  else
    printf "  ❌ %s\n" "$description"
    printf "     Expected: '%s'\n     Actual:   '%s'\n" "$expected" "$actual"
    (( _TEST_FAIL++ ))
  fi
}

_assert_match() {
  local description="$1"
  local actual="$2"
  local pattern="$3"
  if [[ "$actual" =~ $pattern ]]; then
    printf "  ✅ %s\n" "$description"
    (( _TEST_PASS++ ))
  else
    printf "  ❌ %s\n" "$description"
    printf "     Pattern:  '%s'\n     Actual:   '%s'\n" "$pattern" "$actual"
    (( _TEST_FAIL++ ))
  fi
}

_assert_return() {
  local description="$1"
  shift
  if "$@" 2>/dev/null; then
    printf "  ✅ %s\n" "$description"
    (( _TEST_PASS++ ))
  else
    printf "  ❌ %s\n" "$description"
    (( _TEST_FAIL++ ))
  fi
}

_assert_no_return() {
  local description="$1"
  shift
  if ! "$@" 2>/dev/null; then
    printf "  ✅ %s\n" "$description"
    (( _TEST_PASS++ ))
  else
    printf "  ❌ %s\n" "$description"
    (( _TEST_FAIL++ ))
  fi
}

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
# Setup — Source libraries with suppressed output
# ============================================================================

readonly ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}"

# -- Suppress log output during tests
export ZSH_LOG_LEVEL=5  # SILENT

# -- Source libraries
source "${ZDOTDIR}/lib/logging.zsh" 2>/dev/null
source "${ZDOTDIR}/lib/platform-detect.zsh" 2>/dev/null
source "${ZDOTDIR}/lib/tool-check.zsh" 2>/dev/null
source "${ZDOTDIR}/lib/toml-parser.zsh" 2>/dev/null

# ============================================================================
# Tests Begin
# ============================================================================

_test_header

# ============================================================================
# Tests: Logging Library
# ============================================================================

printf "  ── Logging Library ──\n\n"

_assert "log_debug function exists" "(( ${+functions[log_debug]} ))"
_assert "log_info function exists" "(( ${+functions[log_info]} ))"
_assert "log_warn function exists" "(( ${+functions[log_warn]} ))"
_assert "log_error function exists" "(( ${+functions[log_error]} ))"
_assert "log_fatal function exists" "(( ${+functions[log_fatal]} ))"
_assert "log_set_level function exists" "(( ${+functions[log_set_level]} ))"
_assert "log_section function exists" "(( ${+functions[log_section]} ))"

_assert "LOG_LEVEL_DEBUG is 0" "(( LOG_LEVEL_DEBUG == 0 ))"
_assert "LOG_LEVEL_INFO is 1" "(( LOG_LEVEL_INFO == 1 ))"
_assert "LOG_LEVEL_SILENT is 5" "(( LOG_LEVEL_SILENT == 5 ))"

# -- Test level setting
log_set_level "debug" 2>/dev/null
_assert_eq "log_set_level 'debug' sets level 0" "$ZSH_LOG_LEVEL" "0"
log_set_level "silent" 2>/dev/null
_assert_eq "log_set_level 'silent' sets level 5" "$ZSH_LOG_LEVEL" "5"

# ============================================================================
# Tests: Platform Detection
# ============================================================================

printf "\n  ── Platform Detection ──\n\n"

_assert "ZSH_PLATFORM is set" "[[ -n '${ZSH_PLATFORM}' ]]"
_assert "ZSH_PLATFORM is valid value" "[[ '${ZSH_PLATFORM}' =~ ^(darwin|linux|wsl|freebsd|unknown)$ ]]"

_assert "ZSH_DISTRO is set" "[[ -n '${ZSH_DISTRO}' ]]"
_assert "ZSH_ARCH is set" "[[ -n '${ZSH_ARCH}' ]]"
_assert "ZSH_ARCH is valid" "[[ '${ZSH_ARCH}' =~ ^(x86_64|arm64|aarch64|i686|armv7l|s390x|ppc64le)$ ]]"
_assert "ZSH_PKG_MANAGER is set" "[[ -n '${ZSH_PKG_MANAGER}' ]]"
_assert "ZSH_TERMINAL is set" "[[ -n '${ZSH_TERMINAL}' ]]"

_assert "ZSH_IS_SSH is integer" "(( ZSH_IS_SSH == 0 || ZSH_IS_SSH == 1 ))"
_assert "ZSH_IS_CONTAINER is integer" "(( ZSH_IS_CONTAINER == 0 || ZSH_IS_CONTAINER == 1 ))"
_assert "ZSH_IS_ROOT is integer" "(( ZSH_IS_ROOT == 0 || ZSH_IS_ROOT == 1 ))"

_assert "platform_summary function exists" "(( ${+functions[platform_summary]} ))"
_assert "detect_platform_all function exists" "(( ${+functions[detect_platform_all]} ))"

# ============================================================================
# Tests: Tool Check Library
# ============================================================================

printf "\n  ── Tool Check Library ──\n\n"

_assert "has function exists" "(( ${+functions[has]} ))"
_assert "has_all function exists" "(( ${+functions[has_all]} ))"
_assert "has_any function exists" "(( ${+functions[has_any]} ))"
_assert "tool_version function exists" "(( ${+functions[tool_version]} ))"
_assert "need function exists" "(( ${+functions[need]} ))"
_assert "tool_doctor function exists" "(( ${+functions[tool_doctor]} ))"
_assert "version_compare function exists" "(( ${+functions[version_compare]} ))"

# -- Test has() with known commands
_assert_return "has 'zsh' returns true" has "zsh"
_assert_no_return "has 'nonexistent_cmd_xyz' returns false" has "nonexistent_cmd_xyz"

# -- Test has_all()
_assert_return "has_all 'zsh' returns true" has_all "zsh"
_assert_no_return "has_all 'zsh' 'nonexistent_cmd_xyz' returns false" has_all "zsh" "nonexistent_cmd_xyz"

# -- Test has_any()
_assert_return "has_any 'zsh' 'nonexistent_cmd_xyz' returns true" has_any "zsh" "nonexistent_cmd_xyz"
_assert_no_return "has_any 'nonexistent_a' 'nonexistent_b' returns false" has_any "nonexistent_a" "nonexistent_b"

# -- Test version_compare()
_assert_return "version_compare: 2.0.0 ge 1.0.0" version_compare "2.0.0" "ge" "1.0.0"
_assert_return "version_compare: 1.0.0 eq 1.0.0" version_compare "1.0.0" "eq" "1.0.0"
_assert_return "version_compare: 1.5.0 gt 1.4.9" version_compare "1.5.0" "gt" "1.4.9"
_assert_return "version_compare: 1.0.0 le 2.0.0" version_compare "1.0.0" "le" "2.0.0"
_assert_return "version_compare: 1.0.0 lt 1.0.1" version_compare "1.0.0" "lt" "1.0.1"
_assert_no_return "version_compare: 1.0.0 gt 2.0.0 is false" version_compare "1.0.0" "gt" "2.0.0"

# -- Test tool_cache_clear()
_assert_return "tool_cache_clear runs without error" tool_cache_clear

# ============================================================================
# Tests: TOML Parser
# ============================================================================

printf "\n  ── TOML Parser ──\n\n"

_assert "toml_parse function exists" "(( ${+functions[toml_parse]} ))"
_assert "toml_get function exists" "(( ${+functions[toml_get]} ))"
_assert "toml_get_bool function exists" "(( ${+functions[toml_get_bool]} ))"
_assert "toml_get_int function exists" "(( ${+functions[toml_get_int]} ))"
_assert "toml_has function exists" "(( ${+functions[toml_has]} ))"
_assert "toml_clear function exists" "(( ${+functions[toml_clear]} ))"

# -- Test with settings.toml
local settings_file="${ZDOTDIR}/ssot/settings.toml"
if [[ -f "$settings_file" ]]; then
  toml_clear
  toml_parse "$settings_file"

  _assert "toml_parse reads settings.toml" "(( ${#_TOML_DATA} > 0 ))"

  local theme_val
  theme_val=$(toml_get "general.theme" "")
  _assert "toml_get reads general.theme" "[[ -n '${theme_val}' ]]"
  _assert_eq "general.theme is catppuccin-mocha" "$theme_val" "catppuccin-mocha"

  _assert_return "toml_get_bool features.enable_icons is true" toml_get_bool "features.enable_icons"
  _assert_return "toml_has general.version" toml_has "general.version"
  _assert_no_return "toml_has nonexistent.key is false" toml_has "nonexistent.key.xyz"

  local hist_size
  hist_size=$(toml_get_int "history.size" "0")
  _assert "toml_get_int history.size > 0" "(( hist_size > 0 ))"
else
  _skip "TOML parser integration tests" "settings.toml not found"
fi

# ============================================================================
# Tests: Helper Functions
# ============================================================================

printf "\n  ── Helper Functions ──\n\n"

if [[ -f "${ZDOTDIR}/functions/_helpers.zsh" ]]; then
  source "${ZDOTDIR}/functions/_helpers.zsh" 2>/dev/null

  # -- String functions
  _assert_eq "lowercase 'HELLO'" "$(lowercase 'HELLO')" "hello"
  _assert_eq "uppercase 'hello'" "$(uppercase 'hello')" "HELLO"
  _assert_eq "trim '  hello  '" "$(trim '  hello  ')" "hello"
  _assert_eq "strlen 'hello'" "$(strlen 'hello')" "5"

  # -- Date functions
  local iso
  iso=$(now_iso)
  _assert_match "now_iso returns ISO 8601" "$iso" '^[0-9]{4}-[0-9]{2}-[0-9]{2}T'

  local unix_ts
  unix_ts=$(now_unix)
  _assert "now_unix returns a number" "(( unix_ts > 1000000000 ))"

  # -- genpass
  local pass
  pass=$(genpass 16)
  _assert "genpass generates 16 chars" "(( ${#pass} >= 16 ))"

  # -- genuuid
  if (( ${+functions[genuuid]} )); then
    local uuid
    uuid=$(genuuid)
    _assert_match "genuuid returns UUID format" "$uuid" '^[0-9a-f-]{36}$'
  fi
else
  _skip "Helper function tests" "_helpers.zsh not found"
fi

# ============================================================================
# Summary
# ============================================================================

_test_summary
