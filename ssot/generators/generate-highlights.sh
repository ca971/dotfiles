#!/usr/bin/env bash
# ============================================================================
# @file        ssot/generators/generate-highlights.sh
# @description SSOT Highlight Transpiler. Reads highlights.toml and generates
#              ZSH syntax highlighting configuration.
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

TOML_FILE="${CONFIG_ROOT}/ssot/highlights.toml"
OUTPUT_FILE="${CONFIG_ROOT}/generated/highlights.zsh"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

PARSED_FILE="$(mktemp /tmp/zsh-highlights-parsed.XXXXXX)"
SECTIONS_FILE="$(mktemp /tmp/zsh-highlights-sections.XXXXXX)"
trap "rm -f '$PARSED_FILE' '$SECTIONS_FILE'" EXIT

[[ -f "$TOML_FILE" ]] || {
    echo "ERROR: highlights.toml not found" >&2
    exit 1
}
mkdir -p "$(dirname "$OUTPUT_FILE")"

parse_highlights_toml() {
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

        if echo "$line" | grep -qE '^[a-zA-Z0-9_-]+[[:space:]]*='; then
            local key value
            key="$(echo "$line" | sed 's/[[:space:]]*=.*//')"
            value="$(echo "$line" | sed 's/^[^=]*=[[:space:]]*//')"
            # -- Strip surrounding quotes
            value="$(echo "$value" | sed 's/^"//' | sed 's/"$//')"
            # -- Strip array brackets and quotes for arrays
            value="$(echo "$value" | sed 's/^\[//' | sed 's/\]$//' | sed 's/"//g' | sed 's/,/ /g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
            printf '%s|%s|%s\n' "$current_section" "$key" "$value" >> "$PARSED_FILE"
        fi
    done < "$TOML_FILE"
}

generate_highlights_zsh() {
    {
        cat << HEADER
#!/usr/bin/env zsh
# ============================================================================
# @file        generated/highlights.zsh
# @description Auto-generated syntax highlighting from ssot/highlights.toml.
#              DO NOT EDIT MANUALLY — regenerate with: just generate-highlights
# @generated   ${TIMESTAMP}
# @license     MIT
# ============================================================================

[[ -n "\${_ZSH_GENERATED_HIGHLIGHTS_LOADED:-}" ]] && return 0
readonly _ZSH_GENERATED_HIGHLIGHTS_LOADED=1

HEADER

        echo "typeset -gA ZSH_HIGHLIGHT_STYLES"
        echo ""

        # -- Process style sections
        local style_section
        for style_section in main arguments variables redirections patterns comments separators suffixes; do
            if grep -q "^${style_section}|" "$PARSED_FILE"; then
                local section_upper
                section_upper="$(echo "$style_section" | tr '[:lower:]' '[:upper:]')"
                printf '# ── %s ──\n\n' "$section_upper"

                grep "^${style_section}|" "$PARSED_FILE" | sort | while IFS='|' read -r _sec style_name style_value; do
                    printf "ZSH_HIGHLIGHT_STYLES[%s]='%s'\n" "$style_name" "$style_value"
                done
                echo ""
            fi
        done

        # -- Bracket highlighter
        local brackets_enabled
        brackets_enabled=$(grep '^brackets|enabled|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
        if [[ "$brackets_enabled" == "true" ]]; then
            echo "# ── BRACKET HIGHLIGHTER ──"
            echo ""
            echo "typeset -ga ZSH_HIGHLIGHT_MATCHING_BRACKETS_STYLES=("
            grep '^brackets|level' "$PARSED_FILE" | sort | while IFS='|' read -r _sec _key level_value; do
                printf "  '%s'\n" "$level_value"
            done
            echo ")"
            echo ""

            local bracket_cursor bracket_mismatch
            bracket_cursor=$(grep '^brackets|cursor|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
            bracket_mismatch=$(grep '^brackets|mismatch|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
            [[ -n "$bracket_cursor" ]] && printf "ZSH_HIGHLIGHT_STYLES[bracket-level-0]='%s'\n" "$bracket_cursor"
            [[ -n "$bracket_mismatch" ]] && printf "ZSH_HIGHLIGHT_STYLES[bracket-error]='%s'\n" "$bracket_mismatch"
            echo ""
        fi

        # -- Highlighter selection
        cat << 'HL_SELECT'
typeset -ga ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor regexp)

# ── Dangerous Command Patterns ──

typeset -gA ZSH_HIGHLIGHT_PATTERNS
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=#f38ba8,bold,standout')
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf /' 'fg=#f38ba8,bold,standout')
ZSH_HIGHLIGHT_PATTERNS+=('dd if=' 'fg=#f9e2af,bold')
ZSH_HIGHLIGHT_PATTERNS+=('mkfs.' 'fg=#f38ba8,bold')

HL_SELECT

        # -- Autosuggestions
        local suggestion_color suggestion_strategy
        suggestion_color=$(grep '^autosuggestions|suggestion_color|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
        suggestion_strategy=$(grep '^autosuggestions|strategy|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)

        echo "# ── AUTOSUGGESTIONS ──"
        echo ""
        [[ -n "$suggestion_color" ]] && printf "typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='%s'\n" "$suggestion_color"
        [[ -n "$suggestion_strategy" ]] && printf "typeset -ga ZSH_AUTOSUGGEST_STRATEGY=(%s)\n" "$suggestion_strategy"
        echo "typeset -gi ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20"
        echo "typeset -gi ZSH_AUTOSUGGEST_USE_ASYNC=1"
        echo "typeset -gi ZSH_AUTOSUGGEST_MANUAL_REBIND=1"
        echo ""

        echo "# vim: ft=zsh ts=2 sw=2 et"

    } > "$OUTPUT_FILE"

    echo "  → ${OUTPUT_FILE} ($(wc -l < "$OUTPUT_FILE" | tr -d ' ') lines)"
}

main() {
    echo "  Parsing: ${TOML_FILE}"
    parse_highlights_toml
    echo "  Found: $(wc -l < "$PARSED_FILE" | tr -d ' ') highlight rules"
    echo ""
    generate_highlights_zsh
}

main "$@"
