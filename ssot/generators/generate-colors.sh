#!/usr/bin/env bash
# ============================================================================
# @file        ssot/generators/generate-colors.sh
# @description SSOT Color Transpiler. Reads colors.toml and generates a ZSH
#              file with color variables, ANSI escape sequences, LS_COLORS.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
#
# @changelog   1.1.0 — Bash 3.x compat. Replaced declare -A with temp files.
# ============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TOML_FILE="${CONFIG_ROOT}/ssot/colors.toml"
OUTPUT_FILE="${CONFIG_ROOT}/generated/colors.zsh"

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# -- Temp files for parsed data
PARSED_FILE="$(mktemp /tmp/zsh-colors-parsed.XXXXXX)"
SECTIONS_FILE="$(mktemp /tmp/zsh-colors-sections.XXXXXX)"
trap "rm -f '$PARSED_FILE' '$SECTIONS_FILE'" EXIT

if [[ ! -f "$TOML_FILE" ]]; then
    echo "ERROR: colors.toml not found at ${TOML_FILE}" >&2
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"

# ============================================================================
# TOML Parser
# ============================================================================

parse_colors_toml() {
    local current_section=""
    local line key value

    while IFS= read -r line; do
        line="$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
        [[ -z "$line" ]] && continue
        [[ "$line" == "#"* ]] && continue

        if echo "$line" | grep -qE '^\[[a-zA-Z0-9_]+\]$'; then
            current_section="$(echo "$line" | tr -d '[]')"
            # -- Track unique sections in order
            if ! grep -qx "$current_section" "$SECTIONS_FILE" 2> /dev/null; then
                echo "$current_section" >> "$SECTIONS_FILE"
            fi
            continue
        fi

        if echo "$line" | grep -qE '^[a-zA-Z0-9_]+[[:space:]]*='; then
            key="$(echo "$line" | sed 's/[[:space:]]*=.*//')"
            value="$(echo "$line" | sed 's/^[^=]*=[[:space:]]*//' | tr -d '"')"
            printf '%s|%s|%s\n' "$current_section" "$key" "$value" >> "$PARSED_FILE"
        fi

    done < "$TOML_FILE"
}

# ============================================================================
# Hex to RGB
# ============================================================================

hex_to_rgb() {
    local hex="${1#\#}"
    printf '%d %d %d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# ============================================================================
# ZSH Output Generator
# ============================================================================

generate_colors_zsh() {
    local total_colors=0

    {
        cat << HEADER
#!/usr/bin/env zsh
# ============================================================================
# @file        generated/colors.zsh
# @description Auto-generated color definitions from ssot/colors.toml.
#              DO NOT EDIT MANUALLY — regenerate with: just generate-colors
# @repository  https://github.com/ca971/zsh-config.git
# @generated   ${TIMESTAMP}
# @source      ssot/colors.toml
# @license     MIT
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "\${_ZSH_GENERATED_COLORS_LOADED:-}" ]] && return 0
readonly _ZSH_GENERATED_COLORS_LOADED=1

HEADER

        # -- Generate arrays per section
        while IFS= read -r section; do
            local section_upper
            section_upper="$(echo "$section" | tr '[:lower:]' '[:upper:]')"

            printf '# ── %s ──\n\n' "$section_upper"
            printf 'typeset -gA ZSH_COLORS_%s=(\n' "$section_upper"

            grep "^${section}|" "$PARSED_FILE" | while IFS='|' read -r _sec color_name hex_value; do
                printf '  [%s]="%s"\n' "$color_name" "$hex_value"
                total_colors=$((total_colors + 1))
            done | sort

            printf ')\n\n'

            # -- Individual exports for semantic/ansi
            if [[ "$section" == "semantic" ]] || [[ "$section" == "ansi" ]]; then
                grep "^${section}|" "$PARSED_FILE" | while IFS='|' read -r _sec color_name hex_value; do
                    local var_name
                    var_name="COLOR_$(echo "$color_name" | tr '[:lower:]' '[:upper:]')"
                    printf 'typeset -g %s="%s"\n' "$var_name" "$hex_value"
                done | sort
                echo ""
            fi

        done < "$SECTIONS_FILE"

        # -- ANSI helpers
        cat << 'HELPERS'
# ── ANSI Escape Code Helpers ─────────────────────────────────────────────────

typeset -g RESET=$'\033[0m'
typeset -g BOLD=$'\033[1m'
typeset -g DIM=$'\033[2m'
typeset -g ITALIC=$'\033[3m'
typeset -g UNDERLINE=$'\033[4m'

# ── Color Functions ──────────────────────────────────────────────────────────

function color_fg() {
  local hex="${1#\#}"
  local text="$2"
  local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
  printf '\033[38;2;%d;%d;%dm%s\033[0m' "$r" "$g" "$b" "$text"
}

function color_bg() {
  local hex="${1#\#}"
  local text="$2"
  local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
  printf '\033[48;2;%d;%d;%dm%s\033[0m' "$r" "$g" "$b" "$text"
}

function color_swatch() {
  printf "\n  🎨 Color Swatch\n"
  local section_var section_name
  for section_var in ${(k)parameters[(I)ZSH_COLORS_*]}; do
    section_name="${section_var#ZSH_COLORS_}"
    printf "\n  [%s]\n" "${section_name:l}"
    local -A colors=("${(@Pkv)section_var}")
    for name in "${(@ko)colors}"; do
      local hex="${colors[$name]}"
      color_fg "$hex" "  ██"
      printf " %-20s %s\n" "$name" "$hex"
    done
  done
  printf "\n"
}
HELPERS

        # -- LS_COLORS
        local ls_dir ls_sym ls_exe ls_archive ls_media ls_doc ls_broken ls_socket
        ls_dir=$(grep '^ls_colors|directory|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
        ls_sym=$(grep '^ls_colors|symlink|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
        ls_exe=$(grep '^ls_colors|executable|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
        ls_archive=$(grep '^ls_colors|archive|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
        ls_media=$(grep '^ls_colors|media|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
        ls_doc=$(grep '^ls_colors|document|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
        ls_broken=$(grep '^ls_colors|broken_symlink|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)
        ls_socket=$(grep '^ls_colors|socket|' "$PARSED_FILE" | head -1 | cut -d'|' -f3)

        if [[ -n "$ls_dir" ]]; then
            echo ""
            echo "# ── LS_COLORS ────────────────────────────────────────────────────────────────"
            echo ""

            local ls_colors_str=""
            local hex r g b color_code

            # Directory
            hex="${ls_dir#\#}"
            r=$((16#${hex:0:2}))
            g=$((16#${hex:2:2}))
            b=$((16#${hex:4:2}))
            ls_colors_str="di=38;2;${r};${g};${b}:"

            # Symlink
            if [[ -n "$ls_sym" ]]; then
                hex="${ls_sym#\#}"
                r=$((16#${hex:0:2}))
                g=$((16#${hex:2:2}))
                b=$((16#${hex:4:2}))
                ls_colors_str="${ls_colors_str}ln=38;2;${r};${g};${b}:"
            fi

            # Executable
            if [[ -n "$ls_exe" ]]; then
                hex="${ls_exe#\#}"
                r=$((16#${hex:0:2}))
                g=$((16#${hex:2:2}))
                b=$((16#${hex:4:2}))
                ls_colors_str="${ls_colors_str}ex=38;2;${r};${g};${b}:"
            fi

            # Broken symlink
            if [[ -n "$ls_broken" ]]; then
                hex="${ls_broken#\#}"
                r=$((16#${hex:0:2}))
                g=$((16#${hex:2:2}))
                b=$((16#${hex:4:2}))
                ls_colors_str="${ls_colors_str}or=38;2;${r};${g};${b};1:"
            fi

            # Socket
            if [[ -n "$ls_socket" ]]; then
                hex="${ls_socket#\#}"
                r=$((16#${hex:0:2}))
                g=$((16#${hex:2:2}))
                b=$((16#${hex:4:2}))
                ls_colors_str="${ls_colors_str}so=38;2;${r};${g};${b}:"
            fi

            # Archives
            if [[ -n "$ls_archive" ]]; then
                hex="${ls_archive#\#}"
                r=$((16#${hex:0:2}))
                g=$((16#${hex:2:2}))
                b=$((16#${hex:4:2}))
                color_code="38;2;${r};${g};${b}"
                for ext in tar gz bz2 xz zip 7z rar zst lz4 lzma tgz tbz txz; do
                    ls_colors_str="${ls_colors_str}*.${ext}=${color_code}:"
                done
            fi

            # Media
            if [[ -n "$ls_media" ]]; then
                hex="${ls_media#\#}"
                r=$((16#${hex:0:2}))
                g=$((16#${hex:2:2}))
                b=$((16#${hex:4:2}))
                color_code="38;2;${r};${g};${b}"
                for ext in jpg jpeg png gif bmp svg webp ico mp3 flac wav ogg mp4 mkv avi webm mov; do
                    ls_colors_str="${ls_colors_str}*.${ext}=${color_code}:"
                done
            fi

            # Documents
            if [[ -n "$ls_doc" ]]; then
                hex="${ls_doc#\#}"
                r=$((16#${hex:0:2}))
                g=$((16#${hex:2:2}))
                b=$((16#${hex:4:2}))
                color_code="38;2;${r};${g};${b}"
                for ext in pdf doc docx xls xlsx ppt pptx odt ods txt md rst csv; do
                    ls_colors_str="${ls_colors_str}*.${ext}=${color_code}:"
                done
            fi

            printf 'export LS_COLORS="%s"\n' "$ls_colors_str"
        fi

        echo ""
        echo "# vim: ft=zsh ts=2 sw=2 et"

    } > "$OUTPUT_FILE"

    echo "  → ${OUTPUT_FILE} ($(wc -l < "$OUTPUT_FILE" | tr -d ' ') lines)"
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo "  Parsing: ${TOML_FILE}"
    parse_colors_toml
    local count
    count=$(wc -l < "$PARSED_FILE" | tr -d ' ')
    local sections
    sections=$(wc -l < "$SECTIONS_FILE" | tr -d ' ')
    echo "  Found: ${count} color definitions in ${sections} sections"
    echo ""
    generate_colors_zsh
}

main "$@"
