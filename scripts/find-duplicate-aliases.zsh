#!/usr/bin/env zsh
# ============================================================================
# @file        scripts/find-duplicate-aliases.zsh
# @description Detect duplicate alias definitions between SSOT generated
#              aliases and tool-specific files. Reports conflicts and
#              generates a cleanup plan.
#
# @usage       zsh scripts/find-duplicate-aliases.zsh
#              zsh scripts/find-duplicate-aliases.zsh --fix
#
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-15
# @version     1.0.0
# ============================================================================

readonly ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}"
readonly FIX_MODE="${1:-}"

# ── Colors ───────────────────────────────────────────────────────────────────
readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly YELLOW=$'\033[0;33m'
readonly BLUE=$'\033[0;34m'
readonly CYAN=$'\033[0;36m'
readonly DIM=$'\033[2m'
readonly BOLD=$'\033[1m'
readonly RESET=$'\033[0m'

# ── Temp files ───────────────────────────────────────────────────────────────
readonly SSOT_ALIASES="$(mktemp /tmp/zsh-ssot-aliases.XXXXXX)"
readonly TOOL_ALIASES="$(mktemp /tmp/zsh-tool-aliases.XXXXXX)"
readonly ALL_ALIASES="$(mktemp /tmp/zsh-all-aliases.XXXXXX)"
readonly DUPLICATES="$(mktemp /tmp/zsh-duplicates.XXXXXX)"
readonly FIX_PLAN="$(mktemp /tmp/zsh-fix-plan.XXXXXX)"
trap "rm -f '$SSOT_ALIASES' '$TOOL_ALIASES' '$ALL_ALIASES' '$DUPLICATES' '$FIX_PLAN'" EXIT

# ============================================================================
# Phase 1: Extract aliases from SSOT generated file
# ============================================================================

extract_ssot_aliases() {
  local file="${ZDOTDIR}/generated/aliases.zsh"
  [[ -f "$file" ]] || { echo "  ${RED}✗${RESET} generated/aliases.zsh not found"; return 1; }

  grep -nE "^alias " "$file" | while IFS= read -r line; do
    local lineno name
    lineno=$(echo "$line" | cut -d: -f1)
    # Extract alias name: alias 'name'='...' or alias name='...'
    name=$(echo "$line" | sed "s/^[0-9]*:alias //" | sed "s/['\"]//g" | sed "s/=.*//")
    printf "ssot|%s|%s|generated/aliases.zsh:%s\n" "$name" "$file" "$lineno"
  done >> "$SSOT_ALIASES"

  local count
  count=$(wc -l < "$SSOT_ALIASES" | tr -d ' ')
  printf "  ${GREEN}✓${RESET} SSOT aliases: %s\n" "$count"
}

# ============================================================================
# Phase 2: Extract aliases from tools/*.zsh files
# ============================================================================

extract_tool_aliases() {
  local total=0

  for file in "${ZDOTDIR}"/tools/*.zsh(N); do
    local tool_name
    tool_name=$(basename "$file" .zsh)

    grep -nE "^[[:space:]]*(alias|function) " "$file" | while IFS= read -r line; do
      local lineno name type
      lineno=$(echo "$line" | cut -d: -f1)
      local content
      content=$(echo "$line" | cut -d: -f2-)
      content=$(echo "$content" | sed 's/^[[:space:]]*//')

      if echo "$content" | grep -q "^alias "; then
        type="alias"
        name=$(echo "$content" | sed "s/^alias //" | sed "s/['\"]//g" | sed "s/=.*//" | tr -d ' ')
      elif echo "$content" | grep -q "^function "; then
        type="function"
        name=$(echo "$content" | sed "s/^function //" | sed "s/()[[:space:]]*{.*//" | sed "s/[[:space:]].*//" | tr -d ' ')
      else
        continue
      fi

      [[ -z "$name" ]] && continue
      printf "tool:%s|%s|%s|tools/%s.zsh:%s|%s\n" "$tool_name" "$name" "$file" "$tool_name" "$lineno" "$type"
    done

  done >> "$TOOL_ALIASES"

  total=$(wc -l < "$TOOL_ALIASES" | tr -d ' ')
  printf "  ${GREEN}✓${RESET} Tool aliases/functions: %s\n" "$total"
}

# ============================================================================
# Phase 3: Extract aliases from platform/*.zsh files
# ============================================================================

extract_platform_aliases() {
  for file in "${ZDOTDIR}"/platform/*.zsh(N) "${ZDOTDIR}"/functions/*.zsh(N); do
    local module_name
    module_name=$(basename "$file" .zsh)
    local rel_path="${file#${ZDOTDIR}/}"

    grep -nE "^[[:space:]]*(alias|function) " "$file" | while IFS= read -r line; do
      local lineno name type
      lineno=$(echo "$line" | cut -d: -f1)
      local content
      content=$(echo "$line" | cut -d: -f2-)
      content=$(echo "$content" | sed 's/^[[:space:]]*//')

      if echo "$content" | grep -q "^alias "; then
        type="alias"
        name=$(echo "$content" | sed "s/^alias //" | sed "s/['\"]//g" | sed "s/=.*//" | tr -d ' ')
      elif echo "$content" | grep -q "^function "; then
        type="function"
        name=$(echo "$content" | sed "s/^function //" | sed "s/()[[:space:]]*{.*//" | sed "s/[[:space:]].*//" | tr -d ' ')
      else
        continue
      fi

      [[ -z "$name" ]] && continue
      printf "other:%s|%s|%s|%s:%s|%s\n" "$module_name" "$name" "$file" "$rel_path" "$lineno" "$type"
    done
  done >> "$TOOL_ALIASES"
}

# ============================================================================
# Phase 4: Find duplicates
# ============================================================================

find_duplicates() {
  # -- Combine all sources
  cat "$SSOT_ALIASES" "$TOOL_ALIASES" > "$ALL_ALIASES"

  # -- Extract just the alias names, find duplicates
  local all_names
  all_names=$(mktemp /tmp/zsh-names.XXXXXX)

  # From SSOT
  awk -F'|' '{print $2}' "$SSOT_ALIASES" >> "$all_names"

  # From tools (only alias names, not function names that are clearly different)
  awk -F'|' '{print $2}' "$TOOL_ALIASES" >> "$all_names"

  # -- Find duplicate names
  sort "$all_names" | uniq -d > "$DUPLICATES"
  rm -f "$all_names"

  local dup_count
  dup_count=$(wc -l < "$DUPLICATES" | tr -d ' ')

  if [[ "$dup_count" -eq 0 ]]; then
    printf "\n  ${GREEN}${BOLD}✅ No duplicates found!${RESET}\n\n"
    return 0
  fi

  printf "\n  ${RED}${BOLD}⚠ Found %d duplicate alias names${RESET}\n\n" "$dup_count"
  return 1
}

# ============================================================================
# Phase 5: Report duplicates with details
# ============================================================================

report_duplicates() {
  [[ -s "$DUPLICATES" ]] || return 0

  printf "  ${BOLD}%-20s %-12s %-40s %s${RESET}\n" "ALIAS" "SOURCE" "FILE" "LINE"
  printf "  %-20s %-12s %-40s %s\n" "────────────────────" "────────────" "────────────────────────────────────────" "────"

  while IFS= read -r dup_name; do
    [[ -z "$dup_name" ]] && continue

    local first=1

    # -- Show SSOT entries
    grep "|${dup_name}|" "$SSOT_ALIASES" | while IFS='|' read -r source name file location; do
      local display_file
      display_file=$(echo "$location" | sed "s|${ZDOTDIR}/||")
      if [[ $first -eq 1 ]]; then
        printf "  ${YELLOW}%-20s${RESET} ${CYAN}%-12s${RESET} %-40s\n" "$name" "SSOT" "$display_file"
        first=0
      else
        printf "  ${DIM}%-20s${RESET} ${CYAN}%-12s${RESET} %-40s\n" "$name" "SSOT" "$display_file"
      fi
    done

    # -- Show tool entries
    grep "|${dup_name}|" "$TOOL_ALIASES" | while IFS='|' read -r source name file location type; do
      local display_file
      display_file=$(echo "$location" | sed "s|${ZDOTDIR}/||")
      local source_label
      source_label=$(echo "$source" | cut -d: -f2)
      printf "  ${DIM}%-20s${RESET} ${BLUE}%-12s${RESET} %-40s ${DIM}(%s)${RESET}\n" "$name" "$source_label" "$display_file" "${type:-alias}"
    done

    printf "\n"

    # -- Build fix plan
    printf "%s\n" "$dup_name" >> "$FIX_PLAN"

  done < "$DUPLICATES"
}

# ============================================================================
# Phase 6: Generate fix suggestions
# ============================================================================

suggest_fixes() {
  [[ -s "$DUPLICATES" ]] || return 0

  printf "  ${BOLD}═══ Fix Suggestions ═══${RESET}\n\n"

  printf "  ${BOLD}Strategy:${RESET} Keep the alias in the ${CYAN}tool file${RESET} (more context-aware),\n"
  printf "  remove it from ${YELLOW}SSOT aliases.toml${RESET}.\n\n"

  printf "  ${BOLD}Aliases to REMOVE from ssot/aliases.toml:${RESET}\n\n"

  while IFS= read -r dup_name; do
    [[ -z "$dup_name" ]] && continue

    # -- Check if this alias exists in a tool file
    if grep -q "|${dup_name}|" "$TOOL_ALIASES"; then
      local tool_source
      tool_source=$(grep "|${dup_name}|" "$TOOL_ALIASES" | head -1 | awk -F'|' '{print $4}')
      printf "    ${RED}✗${RESET} %-20s ${DIM}(keep in %s)${RESET}\n" "$dup_name" "$tool_source"
    fi
  done < "$DUPLICATES"

  printf "\n"
}

# ============================================================================
# Phase 7: Auto-fix mode (--fix)
# ============================================================================

auto_fix() {
  [[ "$FIX_MODE" == "--fix" ]] || return 0
  [[ -s "$DUPLICATES" ]] || return 0

  printf "  ${BOLD}═══ Auto-Fix Mode ═══${RESET}\n\n"

  local toml_file="${ZDOTDIR}/ssot/aliases.toml"
  local backup="${toml_file}.bak.$(date +%Y%m%d_%H%M%S)"

  # -- Backup
  cp "$toml_file" "$backup"
  printf "  ${GREEN}✓${RESET} Backup: %s\n" "$backup"

  local removed=0

  while IFS= read -r dup_name; do
    [[ -z "$dup_name" ]] && continue

    # -- Only remove from TOML if it exists in a tool file
    if grep -q "|${dup_name}|" "$TOOL_ALIASES"; then
      # -- Comment out the alias line in the TOML file
      # Match: name = "..." or "name" = "..."
      if grep -qE "^\"?${dup_name}\"?[[:space:]]*=" "$toml_file" 2>/dev/null; then
        # -- Use sed to comment out the line and the @description above it
        if [[ "$(uname -s)" == "Darwin" ]]; then
          # macOS sed requires '' after -i
          sed -i '' "/^#[[:space:]]*@description.*/{N;/\n\"*${dup_name}\"*[[:space:]]*=/s/^/# REMOVED: /;}" "$toml_file" 2>/dev/null
          sed -i '' "s/^\"*${dup_name}\"*[[:space:]]*=.*/# REMOVED (duplicate in tools): &/" "$toml_file" 2>/dev/null
        else
          sed -i "s/^\"*${dup_name}\"*[[:space:]]*=.*/# REMOVED (duplicate in tools): &/" "$toml_file" 2>/dev/null
        fi
        removed=$((removed + 1))
        printf "  ${YELLOW}✓${RESET} Commented out: %s\n" "$dup_name"
      fi
    fi
  done < "$DUPLICATES"

  printf "\n  ${GREEN}Removed %d duplicates from aliases.toml${RESET}\n" "$removed"
  printf "  ${DIM}Backup at: %s${RESET}\n" "$backup"
  printf "\n  Now run: ${BOLD}bash ssot/generators/generate-all.sh && exec zsh${RESET}\n\n"
}

# ============================================================================
# Main
# ============================================================================

main() {
  printf "\n  ${BOLD}🔍 ZSH Alias Duplicate Finder${RESET}\n"
  printf "  ═══════════════════════════════════\n\n"

  printf "  ${BOLD}Phase 1:${RESET} Scanning SSOT generated aliases...\n"
  extract_ssot_aliases

  printf "  ${BOLD}Phase 2:${RESET} Scanning tool files...\n"
  extract_tool_aliases

  printf "  ${BOLD}Phase 3:${RESET} Scanning platform/function files...\n"
  extract_platform_aliases

  printf "\n  ${BOLD}Phase 4:${RESET} Finding duplicates...\n"
  find_duplicates
  local has_dupes=$?

  if [[ $has_dupes -ne 0 ]]; then
    printf "  ${BOLD}Phase 5:${RESET} Duplicate report...\n\n"
    report_duplicates

    suggest_fixes
    auto_fix
  fi

  # -- Summary
  local ssot_count tool_count dup_count
  ssot_count=$(wc -l < "$SSOT_ALIASES" | tr -d ' ')
  tool_count=$(wc -l < "$TOOL_ALIASES" | tr -d ' ')
  dup_count=$(wc -l < "$DUPLICATES" | tr -d ' ')

  printf "  ${BOLD}═══ Summary ═══${RESET}\n\n"
  printf "  SSOT aliases:     %s\n" "$ssot_count"
  printf "  Tool definitions: %s\n" "$tool_count"
  printf "  Duplicates:       %s\n" "$dup_count"

  if [[ "$dup_count" -gt 0 ]] && [[ "$FIX_MODE" != "--fix" ]]; then
    printf "\n  ${YELLOW}Run with --fix to auto-remove duplicates:${RESET}\n"
    printf "    ${BOLD}zsh scripts/find-duplicate-aliases.zsh --fix${RESET}\n"
  fi

  printf "\n"
}

main "$@"
