#!/usr/bin/env bash
# ============================================================================
# @file        ssot/generators/generate-icons.sh
# @description SSOT Icon Transpiler. Reads icons.toml and generates ZSH icons.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
#
# @changelog   1.1.0 — Bash 3.x compat. Temp files instead of declare -A.
# ============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TOML_FILE="${CONFIG_ROOT}/ssot/icons.toml"
OUTPUT_FILE="${CONFIG_ROOT}/generated/icons.zsh"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

PARSED_FILE="$(mktemp /tmp/zsh-icons-parsed.XXXXXX)"
SECTIONS_FILE="$(mktemp /tmp/zsh-icons-sections.XXXXXX)"
trap "rm -f '$PARSED_FILE' '$SECTIONS_FILE'" EXIT

[[ -f "$TOML_FILE" ]] || {
    echo "ERROR: icons.toml not found" >&2
    exit 1
}
mkdir -p "$(dirname "$OUTPUT_FILE")"

parse_icons_toml() {
    local current_section=""
    while IFS= read -r line; do
        line="$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
        [[ -z "$line" ]] && continue
        [[ "$line" == "#"* ]] && continue

        if echo "$line" | grep -qE '^\[[a-zA-Z0-9_]+\]$'; then
            current_section="$(echo "$line" | tr -d '[]')"
            grep -qx "$current_section" "$SECTIONS_FILE" 2> /dev/null || echo "$current_section" >> "$SECTIONS_FILE"
            continue
        fi

        if echo "$line" | grep -qE '^[a-zA-Z0-9_]+[[:space:]]*='; then
            local key value
            key="$(echo "$line" | sed 's/[[:space:]]*=.*//')"
            value="$(echo "$line" | sed 's/^[^=]*=[[:space:]]*//' | sed 's/^"//' | sed 's/"$//')"
            printf '%s|%s|%s\n' "$current_section" "$key" "$value" >> "$PARSED_FILE"
        fi
    done < "$TOML_FILE"
}

generate_icons_zsh() {
    {
        cat << HEADER
#!/usr/bin/env zsh
# ============================================================================
# @file        generated/icons.zsh
# @description Auto-generated Nerd Font icon definitions from ssot/icons.toml.
#              DO NOT EDIT MANUALLY — regenerate with: just generate-icons
# @generated   ${TIMESTAMP}
# @license     MIT
# ============================================================================

[[ -n "\${_ZSH_GENERATED_ICONS_LOADED:-}" ]] && return 0
readonly _ZSH_GENERATED_ICONS_LOADED=1

typeset -gi ZSH_ICONS_ENABLED=\${ZSH_ICONS_ENABLED:-1}

HEADER

        # -- Master registry
        echo "typeset -gA ZSH_ICONS=("
        while IFS= read -r section; do
            echo "  # ── ${section} ──"
            grep "^${section}|" "$PARSED_FILE" | sort | while IFS='|' read -r _sec icon_name icon_char; do
                printf '  [%s.%s]="%s"\n' "$section" "$icon_name" "$icon_char"
            done
        done < "$SECTIONS_FILE"
        echo ")"
        echo ""

        # -- Per-section arrays
        while IFS= read -r section; do
            local section_upper
            section_upper="$(echo "$section" | tr '[:lower:]' '[:upper:]')"
            printf 'typeset -gA ZSH_ICONS_%s=(\n' "$section_upper"
            grep "^${section}|" "$PARSED_FILE" | sort | while IFS='|' read -r _sec icon_name icon_char; do
                printf '  [%s]="%s"\n' "$icon_name" "$icon_char"
            done
            echo ")"
            echo ""
        done < "$SECTIONS_FILE"

        # -- Shorthand + fallback + accessor
        cat << 'SHORTCUTS'
if (( ZSH_ICONS_ENABLED )); then
  typeset -g ICON_SUCCESS="${ZSH_ICONS[status.success]:-✓}"
  typeset -g ICON_ERROR="${ZSH_ICONS[status.error]:-✗}"
  typeset -g ICON_WARNING="${ZSH_ICONS[status.warning]:-!}"
  typeset -g ICON_INFO="${ZSH_ICONS[status.info]:-i}"
  typeset -g ICON_FOLDER="${ZSH_ICONS[files.folder]:-/}"
  typeset -g ICON_FILE="${ZSH_ICONS[files.file]:--}"
  typeset -g ICON_GIT="${ZSH_ICONS[dev.git_branch]:-Y}"
  typeset -g ICON_DOCKER="${ZSH_ICONS[dev.docker]:-D}"
else
  typeset -g ICON_SUCCESS="+"
  typeset -g ICON_ERROR="x"
  typeset -g ICON_WARNING="!"
  typeset -g ICON_INFO="i"
  typeset -g ICON_FOLDER="/"
  typeset -g ICON_FILE="-"
  typeset -g ICON_GIT="Y"
  typeset -g ICON_DOCKER="D"
fi

function icon() {
  if (( ZSH_ICONS_ENABLED )); then
    printf '%s' "${ZSH_ICONS[$1]:-${2:-?}}"
  else
    printf '%s' "${2:-}"
  fi
}

function icon_preview() {
  printf "\n  🔣 Icon Preview (%d icons)\n\n" "${#ZSH_ICONS}"
  for key in "${(@ko)ZSH_ICONS}"; do
    printf "  %s  %s\n" "${ZSH_ICONS[$key]}" "$key"
  done
  printf "\n"
}
SHORTCUTS

        echo ""
        echo "# vim: ft=zsh ts=2 sw=2 et"

    } > "$OUTPUT_FILE"

    echo "  → ${OUTPUT_FILE} ($(wc -l < "$OUTPUT_FILE" | tr -d ' ') lines)"
}

main() {
    echo "  Parsing: ${TOML_FILE}"
    parse_icons_toml
    echo "  Found: $(wc -l < "$PARSED_FILE" | tr -d ' ') icons in $(wc -l < "$SECTIONS_FILE" | tr -d ' ') sections"
    echo ""
    generate_icons_zsh
}

main "$@"
