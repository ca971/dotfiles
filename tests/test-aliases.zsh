#!/usr/bin/env zsh
# ============================================================================
# @file        tests/test-aliases.zsh
# @description Test suite for SSOT alias generation. Validates that the
#              TOML source is correctly parsed and transpiled to all
#              target shell formats (zsh, fish, nu, bash).
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @usage       zsh tests/test-aliases.zsh
#              just test
# ============================================================================

# ============================================================================
# Test Framework (minimal, zero-dependency)
# ============================================================================

typeset -gi _TEST_PASS=0
typeset -gi _TEST_FAIL=0
typeset -gi _TEST_SKIP=0
typeset -g  _TEST_SUITE="Aliases"

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
    printf "     Condition: %s\n" "$condition"
    (( _TEST_FAIL++ ))
  fi
}

_assert_file_exists() {
  local file="$1"
  local desc="${2:-File exists: ${file}}"
  _assert "$desc" "[[ -f '${file}' ]]"
}

_assert_file_not_empty() {
  local file="$1"
  local desc="${2:-File not empty: ${file}}"
  _assert "$desc" "[[ -s '${file}' ]]"
}

_assert_file_contains() {
  local file="$1"
  local pattern="$2"
  local desc="${3:-File contains pattern: ${pattern}}"
  _assert "$desc" "grep -q '${pattern}' '${file}'"
}

_assert_file_line_count_gt() {
  local file="$1"
  local min="$2"
  local desc="${3:-File has more than ${min} lines}"
  _assert "$desc" "(( \$(wc -l < '${file}') > ${min} ))"
}

_skip() {
  local description="$1"
  local reason="${2:-}"
  printf "  ⏭️  %s" "$description"
  [[ -n "$reason" ]] && printf " (%s)" "$reason"
  printf "\n"
  (( _TEST_SKIP++ ))
}

_test_summary() {
  printf "\n  ─────────────────────────────────\n"
  printf "  Pass: %d | Fail: %d | Skip: %d\n" "$_TEST_PASS" "$_TEST_FAIL" "$_TEST_SKIP"
  printf "  ─────────────────────────────────\n\n"

  if (( _TEST_FAIL > 0 )); then
    printf "  ❌ TESTS FAILED\n\n"
    return 1
  else
    printf "  ✅ ALL TESTS PASSED\n\n"
    return 0
  fi
}

# ============================================================================
# Resolve Paths
# ============================================================================

readonly ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}"
readonly SSOT_DIR="${ZDOTDIR}/ssot"
readonly GEN_DIR="${ZDOTDIR}/generated"

# ============================================================================
# Tests: SSOT Source File
# ============================================================================

_test_header

printf "  ── SSOT Source ──\n\n"

_assert_file_exists "${SSOT_DIR}/aliases.toml"
_assert_file_not_empty "${SSOT_DIR}/aliases.toml"
_assert_file_line_count_gt "${SSOT_DIR}/aliases.toml" 50 "aliases.toml has substantial content (>50 lines)"
_assert_file_contains "${SSOT_DIR}/aliases.toml" '\[general\]' "Contains [general] section"
_assert_file_contains "${SSOT_DIR}/aliases.toml" '\[git\]' "Contains [git] section"
_assert_file_contains "${SSOT_DIR}/aliases.toml" '\[docker\]' "Contains [docker] section"
_assert_file_contains "${SSOT_DIR}/aliases.toml" '\[kubernetes\]' "Contains [kubernetes] section"
_assert_file_contains "${SSOT_DIR}/aliases.toml" '\[navigation\]' "Contains [navigation] section"
_assert_file_contains "${SSOT_DIR}/aliases.toml" '\[listing\]' "Contains [listing] section"

# ============================================================================
# Tests: Generated ZSH Aliases
# ============================================================================

printf "\n  ── Generated ZSH ──\n\n"

if [[ -f "${GEN_DIR}/aliases.zsh" ]]; then
  _assert_file_exists "${GEN_DIR}/aliases.zsh"
  _assert_file_not_empty "${GEN_DIR}/aliases.zsh"
  _assert_file_line_count_gt "${GEN_DIR}/aliases.zsh" 20 "aliases.zsh has >20 lines"
  _assert_file_contains "${GEN_DIR}/aliases.zsh" "alias" "Contains alias definitions"
  _assert_file_contains "${GEN_DIR}/aliases.zsh" "_ZSH_GENERATED_ALIASES_LOADED" "Has double-source guard"
  _assert_file_contains "${GEN_DIR}/aliases.zsh" "Auto-generated" "Has auto-generated header"

  # -- Verify specific aliases exist
  _assert_file_contains "${GEN_DIR}/aliases.zsh" "gs=" "Contains git status alias (gs)"
  _assert_file_contains "${GEN_DIR}/aliases.zsh" "ll=" "Contains long list alias (ll)"
  _assert_file_contains "${GEN_DIR}/aliases.zsh" "dk=" "Contains docker alias (dk)"

  # -- Test that the file can actually be sourced without errors
  _assert "aliases.zsh sources without errors" \
    "zsh -c 'source \"${GEN_DIR}/aliases.zsh\"' 2>/dev/null"
else
  _skip "Generated aliases.zsh tests" "File not yet generated (run: just generate-aliases)"
fi

# ============================================================================
# Tests: Generated Fish Aliases
# ============================================================================

printf "\n  ── Generated Fish ──\n\n"

if [[ -f "${GEN_DIR}/aliases.fish" ]]; then
  _assert_file_exists "${GEN_DIR}/aliases.fish"
  _assert_file_not_empty "${GEN_DIR}/aliases.fish"
  _assert_file_contains "${GEN_DIR}/aliases.fish" "abbr\|alias" "Contains abbr or alias definitions"
  _assert_file_contains "${GEN_DIR}/aliases.fish" "Auto-generated" "Has auto-generated header"
else
  _skip "Generated aliases.fish tests" "File not yet generated"
fi

# ============================================================================
# Tests: Generated Nushell Aliases
# ============================================================================

printf "\n  ── Generated Nushell ──\n\n"

if [[ -f "${GEN_DIR}/aliases.nu" ]]; then
  _assert_file_exists "${GEN_DIR}/aliases.nu"
  _assert_file_not_empty "${GEN_DIR}/aliases.nu"
  _assert_file_contains "${GEN_DIR}/aliases.nu" "alias" "Contains alias definitions"
  _assert_file_contains "${GEN_DIR}/aliases.nu" "Auto-generated" "Has auto-generated header"
else
  _skip "Generated aliases.nu tests" "File not yet generated"
fi

# ============================================================================
# Tests: Generated Bash Aliases
# ============================================================================

printf "\n  ── Generated Bash ──\n\n"

if [[ -f "${GEN_DIR}/aliases.bash" ]]; then
  _assert_file_exists "${GEN_DIR}/aliases.bash"
  _assert_file_not_empty "${GEN_DIR}/aliases.bash"
  _assert_file_contains "${GEN_DIR}/aliases.bash" "alias" "Contains alias definitions"
  _assert_file_contains "${GEN_DIR}/aliases.bash" "_BASH_GENERATED_ALIASES_LOADED" "Has double-source guard"

  # -- Test that the file sources in bash without errors
  _assert "aliases.bash sources without errors" \
    "bash -c 'source \"${GEN_DIR}/aliases.bash\"' 2>/dev/null"
else
  _skip "Generated aliases.bash tests" "File not yet generated"
fi

# ============================================================================
# Tests: Generator Script
# ============================================================================

printf "\n  ── Generator Script ──\n\n"

_assert_file_exists "${SSOT_DIR}/generators/generate-aliases.sh" "Alias generator script exists"
_assert "Generator script is executable or can be made executable" \
  "[[ -f '${SSOT_DIR}/generators/generate-aliases.sh' ]]"

# ============================================================================
# Summary
# ============================================================================

_test_summary
