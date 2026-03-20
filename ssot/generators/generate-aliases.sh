#!/usr/bin/env bash
# ============================================================================
# @file        ssot/generators/generate-aliases.sh
# @description SSOT Alias Transpiler — generates conditional aliases
#              for ZSH, Bash, Fish, and Nushell. Tool-specific aliases
#              are wrapped in availability checks.
# @version     4.0.0
# ============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TOML_FILE="${CONFIG_ROOT}/ssot/aliases.toml"
GENERATED_DIR="${CONFIG_ROOT}/generated"

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

PARSED_FILE="$(mktemp /tmp/zsh-aliases-parsed.XXXXXX)"
SECTIONS_FILE="$(mktemp /tmp/zsh-aliases-sections.XXXXXX)"
META_FILE="$(mktemp /tmp/zsh-aliases-meta.XXXXXX)"
trap "rm -f '$PARSED_FILE' '$SECTIONS_FILE' '$META_FILE'" EXIT

[[ -f "$TOML_FILE" ]] || {
    echo "ERROR: aliases.toml not found" >&2
    exit 1
}
mkdir -p "$GENERATED_DIR"

# ============================================================================
# TOML Parser
# ============================================================================

parse_aliases_toml() {
    local current_section="" last_description=""

    while IFS= read -r line; do
        line="$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
        [[ -z "$line" ]] && continue

        if echo "$line" | grep -q '^#[[:space:]]*@description'; then
            last_description="$(echo "$line" | sed 's/^#[[:space:]]*@description[[:space:]]*//')"
            continue
        fi
        [[ "$line" == "#"* ]] && continue

        if echo "$line" | grep -qE '^\[[a-zA-Z0-9_]+\]$'; then
            current_section="$(echo "$line" | tr -d '[]')"
            grep -qx "$current_section" "$SECTIONS_FILE" 2> /dev/null || echo "$current_section" >> "$SECTIONS_FILE"
            last_description=""
            continue
        fi

        # meta.binary and meta.binary_alt
        if echo "$line" | grep -qE '^meta\.binary'; then
            local meta_key meta_val
            meta_key="$(echo "$line" | sed 's/[[:space:]]*=.*//')"
            meta_val="$(echo "$line" | sed 's/^[^=]*=[[:space:]]*//' | sed 's/^"//' | sed 's/"$//')"
            printf '%s|%s|%s\n' "$current_section" "$meta_key" "$meta_val" >> "$META_FILE"
            continue
        fi

        if echo "$line" | grep -qE '^[a-zA-Z0-9_.""-]+[[:space:]]*='; then
            local key value
            key="$(echo "$line" | sed 's/[[:space:]]*=.*//' | tr -d '"')"
            value="$(echo "$line" | sed 's/^[^=]*=[[:space:]]*//')"
            if echo "$value" | grep -q '^".*"$'; then
                value="$(echo "$value" | sed 's/^"//' | sed 's/"$//')"
            fi
            printf '%s|%s|%s|%s\n' "$current_section" "$key" "$value" "$last_description" >> "$PARSED_FILE"
            last_description=""
        fi

    done < "$TOML_FILE"
}

# Get meta.binary for a section
get_binary() {
    local section="$1"
    grep "^${section}|meta.binary|" "$META_FILE" 2> /dev/null | head -1 | cut -d'|' -f3
}

get_binary_alt() {
    local section="$1"
    grep "^${section}|meta.binary_alt|" "$META_FILE" 2> /dev/null | head -1 | cut -d'|' -f3
}

# ============================================================================
# File Header
# ============================================================================

_file_header() {
    local shell_name="$1"
    cat << HEADER
# ============================================================================
# Auto-generated aliases for ${shell_name}
# DO NOT EDIT — regenerate from ssot/aliases.toml
# Generated: ${TIMESTAMP}
# ============================================================================

HEADER
}

# ============================================================================
# ZSH Generator
# ============================================================================

generate_zsh() {
    local output="${GENERATED_DIR}/aliases.zsh"
    local current_section=""

    {
        _file_header "zsh"
        echo '[[ -n "${_ZSH_GENERATED_ALIASES_LOADED:-}" ]] && return 0'
        echo 'readonly _ZSH_GENERATED_ALIASES_LOADED=1'
        echo ''

        while IFS= read -r section; do
            local binary binary_alt alias_count
            binary=$(get_binary "$section")
            binary_alt=$(get_binary_alt "$section")

            # Count aliases in this section — skip if empty
            alias_count=$(grep -c "^${section}|" "$PARSED_FILE")
            if [[ "$alias_count" -eq 0 ]]; then
                continue
            fi

            local section_upper
            section_upper="$(echo "$section" | tr '[:lower:]' '[:upper:]')"

            # Open conditional block if tool-specific
            if [[ -n "$binary" ]]; then
                echo "# ── ${section_upper} (requires: ${binary}) ──"
                if [[ -n "$binary_alt" ]]; then
                    echo "if (( \$+commands[${binary}] || \$+commands[${binary_alt}] )); then"
                else
                    echo "if (( \$+commands[${binary}] )); then"
                fi
            else
                echo "# ── ${section_upper} ──"
            fi
            echo ""

            grep "^${section}|" "$PARSED_FILE" | while IFS='|' read -r _sec name command description; do
                [[ -n "$description" ]] && printf '# %s\n' "$description"
                local escaped
                escaped="$(printf '%s' "$command" | sed "s/'/'\\\\''/g")"
                case "$name" in
                    ..*) printf "alias '%s'='%s'\n" "$name" "$escaped" ;;
                    *) printf "alias %s='%s'\n" "$name" "$escaped" ;;
                esac
            done

            # Close conditional block
            if [[ -n "$binary" ]]; then
                echo ""
                echo "fi"
            fi
            echo ""

        done < "$SECTIONS_FILE"

        echo "# vim: ft=zsh ts=2 sw=2 et"
    } > "$output"

    echo "  → ${output} ($(wc -l < "$output" | tr -d ' ') lines)"
}

# ============================================================================
# Bash Generator
# ============================================================================

generate_bash() {
    local output="${GENERATED_DIR}/aliases.bash"
    local current_section=""

    {
        _file_header "bash"
        echo '[ -n "${_BASH_GENERATED_ALIASES_LOADED:-}" ] && return 0'
        echo '_BASH_GENERATED_ALIASES_LOADED=1'
        echo ''

        while IFS= read -r section; do
            local binary binary_alt alias_count
            binary=$(get_binary "$section")
            binary_alt=$(get_binary_alt "$section")

            # Count aliases in this section — skip if empty
            alias_count=$(grep -c "^${section}|" "$PARSED_FILE")
            if [[ "$alias_count" -eq 0 ]]; then
                continue
            fi

            local section_upper
            section_upper="$(echo "$section" | tr '[:lower:]' '[:upper:]')"

            if [[ -n "$binary" ]]; then
                echo "# ── ${section_upper} (requires: ${binary}) ──"
                if [[ -n "$binary_alt" ]]; then
                    echo "if command -v ${binary} &>/dev/null || command -v ${binary_alt} &>/dev/null; then"
                else
                    echo "if command -v ${binary} &>/dev/null; then"
                fi
            else
                echo "# ── ${section_upper} ──"
            fi
            echo ""

            grep "^${section}|" "$PARSED_FILE" | while IFS='|' read -r _sec name command description; do
                case "$name" in ..* | "-" | "~")
                    printf "# SKIPPED: %s\n" "$name"
                    continue
                    ;;
                esac
                local escaped
                escaped="$(printf '%s' "$command" | sed "s/'/'\\\\''/g")"
                printf "alias %s='%s'\n" "$name" "$escaped"
            done

            if [[ -n "$binary" ]]; then
                echo ""
                echo "fi"
            fi
            echo ""

        done < "$SECTIONS_FILE"

        echo "# vim: ft=bash ts=2 sw=2 et"
    } > "$output"

    echo "  → ${output} ($(wc -l < "$output" | tr -d ' ') lines)"
}

# ============================================================================
# Fish Generator
# ============================================================================

generate_fish() {
    local output="${GENERATED_DIR}/aliases.fish"

    {
        _file_header "fish"

        while IFS= read -r section; do
            local binary binary_alt alias_count
            binary=$(get_binary "$section")
            binary_alt=$(get_binary_alt "$section")

            # Count aliases in this section — skip if empty
            alias_count=$(grep -c "^${section}|" "$PARSED_FILE")
            if [[ "$alias_count" -eq 0 ]]; then
                continue
            fi

            local section_upper
            section_upper="$(echo "$section" | tr '[:lower:]' '[:upper:]')"

            if [[ -n "$binary" ]]; then
                echo "# ── ${section_upper} (requires: ${binary}) ──"
                if [[ -n "$binary_alt" ]]; then
                    echo "if type -q ${binary}; or type -q ${binary_alt}"
                else
                    echo "if type -q ${binary}"
                fi
            else
                echo "# ── ${section_upper} ──"
            fi
            echo ""

            grep "^${section}|" "$PARSED_FILE" | while IFS='|' read -r _sec name command description; do
                case "$name" in ..* | "-" | "~")
                    printf '# SKIPPED: %s\n' "$name"
                    continue
                    ;;
                esac
                local escaped
                escaped="$(printf '%s' "$command" | sed "s/'/\\\\'/g")"

                # Skip bash-incompatible commands
                if echo "$command" | grep -qE '\bfor\b.*\bdo\b|\(\(|\\e\[|\bfi\b|\bdone\b'; then
                    printf '# SKIPPED (bash syntax): %s\n' "$name"
                    continue
                fi

                if echo "$command" | grep -qE '[|><;&]'; then
                    printf "alias %s '%s'\n" "$name" "$escaped"
                else
                    printf "abbr -a %s '%s'\n" "$name" "$escaped"
                fi
            done

            if [[ -n "$binary" ]]; then
                echo ""
                echo "end"
            fi
            echo ""

        done < "$SECTIONS_FILE"

        echo "# vim: ft=fish ts=2 sw=2 et"
    } > "$output"

    echo "  → ${output} ($(wc -l < "$output" | tr -d ' ') lines)"
}

# ============================================================================
# Nushell Generator
# ============================================================================

generate_nu() {
    local output="${GENERATED_DIR}/aliases.nu"

    {
        _file_header "nu"

        while IFS= read -r section; do
            local binary
            binary=$(get_binary "$section")
            local section_upper
            section_upper="$(echo "$section" | tr '[:lower:]' '[:upper:]')"

            echo "# ── ${section_upper} ──"

            # Nushell can't do conditional alias loading easily
            # We generate all aliases and let nushell handle missing commands
            grep "^${section}|" "$PARSED_FILE" | while IFS='|' read -r _sec name command description; do
                case "$name" in ..* | "-" | "~")
                    printf '# SKIPPED: %s\n' "$name"
                    continue
                    ;;
                esac

                if echo "$command" | grep -qE '[|&$\\]|\bfor\b|\(\('; then
                    printf '# SKIPPED (complex): %s\n' "$name"
                    continue
                fi

                printf 'alias %s = %s\n' "$name" "$command"
            done
            echo ""

        done < "$SECTIONS_FILE"

        echo "# vim: ft=nu ts=2 sw=2 et"
    } > "$output"

    echo "  → ${output} ($(wc -l < "$output" | tr -d ' ') lines)"
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo "  Parsing: ${TOML_FILE}"
    parse_aliases_toml
    local count
    count=$(wc -l < "$PARSED_FILE" | tr -d ' ')
    local sections
    sections=$(wc -l < "$SECTIONS_FILE" | tr -d ' ')
    echo "  Found: ${count} aliases in ${sections} sections"
    echo ""

    generate_zsh
    generate_bash
    generate_fish
    generate_nu

    echo ""
    echo "  Aliases generated for 4 shells (with conditional loading)"
}

main "$@"
