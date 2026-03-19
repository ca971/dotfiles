#!/usr/bin/env bash
# ============================================================================
# @file        ssot/generators/generate-aliases.sh
# @description SSOT Alias Transpiler. Reads aliases.toml and generates
#              shell-specific alias files for ZSH, Fish, Nushell, and Bash.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
#
# @changelog   1.1.0 — Full Bash 3.x compatibility. Replaced declare -A
#              and arrays of structs with line-based parsing and temp files.
# ============================================================================

set -uo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TOML_FILE="${CONFIG_ROOT}/ssot/aliases.toml"
GENERATED_DIR="${CONFIG_ROOT}/generated"

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# -- Temp file to store parsed aliases (section|name|command|description)
PARSED_FILE="$(mktemp /tmp/zsh-aliases-parsed.XXXXXX)"
trap "rm -f '$PARSED_FILE'" EXIT

# ============================================================================
# Validation
# ============================================================================

if [[ ! -f "$TOML_FILE" ]]; then
    echo "ERROR: aliases.toml not found at ${TOML_FILE}" >&2
    exit 1
fi

mkdir -p "$GENERATED_DIR"

# ============================================================================
# TOML Parser
# ============================================================================

parse_aliases_toml() {
    local current_section=""
    local last_description=""
    local line

    while IFS= read -r line; do
        # -- Strip leading/trailing whitespace
        line="$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"

        # -- Skip empty lines
        [[ -z "$line" ]] && continue

        # -- Capture @description comments
        if echo "$line" | grep -q '^#[[:space:]]*@description'; then
            last_description="$(echo "$line" | sed 's/^#[[:space:]]*@description[[:space:]]*//')"
            continue
        fi

        # -- Skip other comments
        [[ "$line" == "#"* ]] && continue

        # -- Section header: [section_name]
        if echo "$line" | grep -qE '^\[[a-zA-Z0-9_]+\]$'; then
            current_section="$(echo "$line" | tr -d '[]')"
            last_description=""
            continue
        fi

        # -- Key-value pair: key = "value"
        # Extract key: everything before the first =
        # Extract value: everything after the first = , stripped of surrounding quotes
        if echo "$line" | grep -qE '^[a-zA-Z0-9_.""-]+[[:space:]]*='; then
            local key value

            # -- Extract key (before first =)
            key="$(echo "$line" | sed 's/[[:space:]]*=.*//' | tr -d '"')"

            # -- Extract value (after first =, strip leading space and outer quotes)
            # Use a more robust approach: cut everything after first =
            value="$(echo "$line" | sed 's/^[^=]*=[[:space:]]*//')"

            # -- Remove exactly one layer of surrounding double quotes
            if echo "$value" | grep -q '^".*"$'; then
                value="$(echo "$value" | sed 's/^"//' | sed 's/"$//')"
            fi

            # -- Remove exactly one layer of surrounding single quotes
            if echo "$value" | grep -q "^'.*'$"; then
                value="$(echo "$value" | sed "s/^'//" | sed "s/'$//")"
            fi

            # -- Write to temp file
            printf '%s|%s|%s|%s\n' "$current_section" "$key" "$value" "$last_description" >> "$PARSED_FILE"
            last_description=""
        fi

    done < "$TOML_FILE"
}

# ============================================================================
# File Header
# ============================================================================

_file_header() {
    local shell_name="$1"
    local comment="${2:-#}"

    cat << HEADER
${comment} ============================================================================
${comment} @file        generated/aliases.${shell_name}
${comment} @description Auto-generated alias definitions for ${shell_name}.
${comment}              DO NOT EDIT MANUALLY — regenerate from ssot/aliases.toml
${comment}              using: just generate-aliases
${comment} @repository  https://github.com/ca971/zsh-config.git
${comment} @generated   ${TIMESTAMP}
${comment} @source      ssot/aliases.toml
${comment} @author      ca971 (auto-generated)
${comment} @license     MIT
${comment} ============================================================================

HEADER
}

# ============================================================================
# ZSH Generator
# ============================================================================

generate_zsh() {
    local output="${GENERATED_DIR}/aliases.zsh"
    local current_section=""

    {
        _file_header "zsh" "#"

        echo '# ── Guard: prevent double-sourcing ───────────────────────────────────────────'
        echo '[[ -n "${_ZSH_GENERATED_ALIASES_LOADED:-}" ]] && return 0'
        echo 'readonly _ZSH_GENERATED_ALIASES_LOADED=1'
        echo ''

        while IFS='|' read -r section name command description; do
            # -- Section header
            if [[ "$section" != "$current_section" ]]; then
                [[ -n "$current_section" ]] && echo ""
                printf '# ── %s ──\n\n' "$(echo "$section" | tr '[:lower:]' '[:upper:]')"
                current_section="$section"
            fi

            # -- Skip invalid alias names
            case "$name" in
                - | -- | -*)
                    printf '# SKIPPED: %s\n' "$name"
                    continue
                    ;;
                "~")
                    printf '# SKIPPED: %s\n' "$name"
                    continue
                    ;;
            esac

            # -- Description
            [[ -n "$description" ]] && printf '# @description  %s\n' "$description"

            # -- Escape single quotes in command
            local escaped_command
            escaped_command="$(printf '%s' "$command" | sed "s/'/'\\\\''/g")"

            # -- Output alias
            if echo "$name" | grep -qE '^\.\.\.*$'; then
                printf "alias '%s'='%s'\n" "$name" "$escaped_command"
            elif echo "$name" | grep -qE '^[a-zA-Z_][a-zA-Z0-9_-]*$'; then
                printf "alias %s='%s'\n" "$name" "$escaped_command"
            else
                printf "alias '%s'='%s'\n" "$name" "$escaped_command"
            fi

        done < "$PARSED_FILE"

        echo ""
        echo "# vim: ft=zsh ts=2 sw=2 et"

    } > "$output"

    echo "  → ${output} ($(wc -l < "$output" | tr -d ' ') lines)"
}

# ============================================================================
# Fish Generator
# ============================================================================

generate_fish() {
    local output="${GENERATED_DIR}/aliases.fish"
    local current_section=""

    {
        _file_header "fish" "#"

        while IFS='|' read -r section name command description; do
            # -- Section header
            if [[ "$section" != "$current_section" ]]; then
                [[ -n "$current_section" ]] && echo ""
                printf '# ── %s ──\n\n' "$(echo "$section" | tr '[:lower:]' '[:upper:]')"
                current_section="$section"
            fi

            # -- Skip invalid fish abbreviation names
            case "$name" in
                ..* | "-" | "~")
                    printf '# SKIPPED (invalid name): %s\n' "$name"
                    continue
                    ;;
            esac

            # -- Description
            [[ -n "$description" ]] && printf '# %s\n' "$description"

            # -- Detect commands incompatible with Fish shell
            # Fish cannot handle: bash for loops, (( )), ${}, $(), process substitution,
            # bash-specific syntax like && || with complex grouping, etc.
            local skip_fish=0

            # Bash-only constructs
            if echo "$command" | grep -qE '\bfor\b.*\bdo\b'; then
                skip_fish=1
            elif echo "$command" | grep -qE '\(\('; then
                skip_fish=1
            elif echo "$command" | grep -qE '\$\{[^}]*:-'; then
                skip_fish=1
            elif echo "$command" | grep -qE '\\e\['; then
                # ANSI escape sequences with backslash-e are bash-specific
                skip_fish=1
            elif echo "$command" | grep -qE '\bdo\b|\bdone\b|\bfi\b|\bthen\b'; then
                skip_fish=1
            elif echo "$command" | grep -qE 'xargs.*\{'; then
                skip_fish=1
            elif echo "$command" | grep -qE '2>/dev/null \|\|'; then
                # Complex fallback chains — often bash-specific
                # Allow simple ones, skip complex
                if echo "$command" | grep -qE '\$\('; then
                    skip_fish=1
                fi
            fi

            if [[ "$skip_fish" -eq 1 ]]; then
                printf '# SKIPPED (bash-incompatible): %s\n' "$name"
                continue
            fi

            # -- Escape single quotes for Fish
            local escaped_command
            escaped_command="$(printf '%s' "$command" | sed "s/'/\\\\'/g")"

            # -- Complex commands (pipes, redirections, semicolons) → alias
            # Simple commands → abbr (expands inline, more fish-idiomatic)
            if echo "$command" | grep -qE '[|><;]|&&|\|\|'; then
                printf "alias %s '%s'\n" "$name" "$escaped_command"
            else
                printf "abbr -a %s '%s'\n" "$name" "$escaped_command"
            fi

        done < "$PARSED_FILE"

        echo ""
        echo "# vim: ft=fish ts=2 sw=2 et"

    } > "$output"

    echo "  → ${output} ($(wc -l < "$output" | tr -d ' ') lines)"
}

# ============================================================================
# Nushell Generator
# ============================================================================

generate_nu() {
    local output="${GENERATED_DIR}/aliases.nu"
    local current_section=""

    {
        _file_header "nu" "#"

        while IFS='|' read -r section name command description; do
            # -- Section header
            if [[ "$section" != "$current_section" ]]; then
                [[ -n "$current_section" ]] && echo ""
                printf '# ── %s ──\n\n' "$(echo "$section" | tr '[:lower:]' '[:upper:]')"
                current_section="$section"
            fi

            # -- Skip invalid nushell alias names
            case "$name" in
                ..* | "-" | "~")
                    printf '# SKIPPED (invalid name): %s\n' "$name"
                    continue
                    ;;
            esac

            # -- Description
            [[ -n "$description" ]] && printf '# %s\n' "$description"

            # -- Detect commands incompatible with Nushell
            local skip_nu=0

            # Bash-only constructs
            if echo "$command" | grep -qE '\bfor\b.*\bdo\b'; then
                skip_nu=1
            elif echo "$command" | grep -qE '\(\('; then
                skip_nu=1
            elif echo "$command" | grep -qE '\$\{'; then
                skip_nu=1
            elif echo "$command" | grep -qE '\\e\['; then
                skip_nu=1
            elif echo "$command" | grep -qE '\bdo\b|\bdone\b|\bfi\b|\bthen\b'; then
                skip_nu=1
            elif echo "$command" | grep -qE '[|]|&&|\|\|'; then
                skip_nu=1
            elif echo "$command" | grep -qE '\$\('; then
                skip_nu=1
            elif echo "$command" | grep -qE 'xargs|awk|sed|grep.*-[EiIvP]'; then
                skip_nu=1
            fi

            if [[ "$skip_nu" -eq 1 ]]; then
                printf '# SKIPPED (bash-incompatible): %s\n' "$name"
                continue
            fi

            # -- Simple external commands → alias
            printf 'alias %s = %s\n' "$name" "$command"

        done < "$PARSED_FILE"

        echo ""
        echo "# vim: ft=nu ts=2 sw=2 et"

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
        _file_header "bash" "#"

        echo '# ── Guard: prevent double-sourcing ──'
        echo '[ -n "${_BASH_GENERATED_ALIASES_LOADED:-}" ] && return 0'
        echo '_BASH_GENERATED_ALIASES_LOADED=1'
        echo ''

        while IFS='|' read -r section name command description; do
            # -- Section header
            if [[ "$section" != "$current_section" ]]; then
                [[ -n "$current_section" ]] && echo ""
                printf '# ── %s ──\n\n' "$(echo "$section" | tr '[:lower:]' '[:upper:]')"
                current_section="$section"
            fi

            # -- Skip invalid alias names for bash
            case "$name" in
                - | -- | -*)
                    printf '# SKIPPED: %s\n' "$name"
                    continue
                    ;;
                "~")
                    printf '# SKIPPED: %s\n' "$name"
                    continue
                    ;;
            esac

            # -- Description
            [[ -n "$description" ]] && printf '# %s\n' "$description"

            # -- Escape the command for bash single-quoted alias
            # Strategy: replace every ' with '\'' (end quote, escaped quote, start quote)
            local escaped_command
            escaped_command="$(printf '%s' "$command" | sed "s/'/'\\\\''/g")"

            printf "alias %s='%s'\n" "$name" "$escaped_command"

        done < "$PARSED_FILE"

        echo ""
        echo "# vim: ft=bash ts=2 sw=2 et"

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
    echo "  Found: ${count} aliases"
    echo ""

    generate_zsh
    generate_fish
    generate_nu
    generate_bash

    echo ""
    echo "  Aliases generated for 4 shells"
}

main "$@"
