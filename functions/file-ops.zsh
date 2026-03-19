#!/usr/bin/env zsh
# ============================================================================
# @file        functions/file-ops.zsh
# @description File operation utility functions. Provides enhanced file
#              manipulation: backup, swap, bulk rename, secure delete,
#              file comparison, and template creation.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_FILE_OPS_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_FILE_OPS_LOADED=1

# ============================================================================
# Backup & Restore
# ============================================================================

# @description  Create a timestamped backup of a file or directory
# @param  $1    string  Path to file or directory to back up
# @return       void (creates .bak.TIMESTAMP copy)
function backup() {
  local target="${1:?Usage: backup <file-or-dir>}"

  if [[ ! -e "$target" ]]; then
    log_error "Not found: %s" "$target"
    return 1
  fi

  local timestamp
  timestamp=$(date '+%Y%m%d_%H%M%S')
  local backup_path="${target}.bak.${timestamp}"

  cp -a "$target" "$backup_path"
  log_info "Backup created: %s" "$backup_path"
}

# @description  Swap the names of two files
# @param  $1    string  File A
# @param  $2    string  File B
# @return       void
function swap() {
  local a="${1:?Usage: swap <file1> <file2>}"
  local b="${2:?Usage: swap <file1> <file2>}"

  if [[ ! -e "$a" ]] || [[ ! -e "$b" ]]; then
    log_error "Both files must exist"
    return 1
  fi

  local tmp
  tmp=$(mktemp "${a}.swap.XXXXXX")
  mv "$a" "$tmp"
  mv "$b" "$a"
  mv "$tmp" "$b"
  log_info "Swapped: %s ↔ %s" "$a" "$b"
}

# ============================================================================
# Secure Operations
# ============================================================================

# @description  Securely delete a file by overwriting with random data first
# @param  $1    string  File to securely delete
# @return       void
function secure_delete() {
  local file="${1:?Usage: secure_delete <file>}"

  if [[ ! -f "$file" ]]; then
    log_error "File not found: %s" "$file"
    return 1
  fi

  if ! confirm "Securely delete ${file}? (UNRECOVERABLE)"; then
    return 0
  fi

  if has "shred"; then
    shred -vfz -n 3 "$file" && rm -f "$file"
  else
    # -- Fallback: overwrite with random data
    local size
    size=$(wc -c < "$file")
    dd if=/dev/urandom of="$file" bs=1 count="$size" conv=notrunc 2>/dev/null
    rm -f "$file"
  fi
  log_info "Securely deleted: %s" "$file"
}

# ============================================================================
# Bulk Operations
# ============================================================================

# @description  Bulk rename files using a pattern (find + sed)
# @param  $1    string  Search pattern (in filename)
# @param  $2    string  Replacement string
# @param  $3    string  (optional) Directory to operate in (default: current)
# @return       void
function bulk_rename() {
  local search="${1:?Usage: bulk_rename <search> <replace> [dir]}"
  local replace="${2:?Usage: bulk_rename <search> <replace> [dir]}"
  local dir="${3:-.}"

  local files
  files=$(find "$dir" -maxdepth 1 -name "*${search}*" -not -name ".*" 2>/dev/null)

  if [[ -z "$files" ]]; then
    log_info "No files matching: *%s*" "$search"
    return 0
  fi

  printf "  Files to rename:\n"
  echo "$files" | while read -r f; do
    local newname="${f//${search}/${replace}}"
    printf "    %s → %s\n" "$(basename "$f")" "$(basename "$newname")"
  done

  if confirm "Apply rename?"; then
    echo "$files" | while read -r f; do
      local newname="${f//${search}/${replace}}"
      mv "$f" "$newname"
    done
    log_info "Rename complete"
  fi
}

# @description  Change file extensions in bulk
# @param  $1    string  Old extension (without dot)
# @param  $2    string  New extension (without dot)
# @param  $3    string  (optional) Directory (default: current)
# @return       void
function change_ext() {
  local old_ext="${1:?Usage: change_ext <old_ext> <new_ext> [dir]}"
  local new_ext="${2:?Usage: change_ext <old_ext> <new_ext> [dir]}"
  local dir="${3:-.}"

  local count=0
  local file
  for file in "${dir}"/*.${old_ext}(N); do
    mv "$file" "${file%.${old_ext}}.${new_ext}"
    (( count++ ))
  done
  log_info "Renamed %d files: .%s → .%s" "$count" "$old_ext" "$new_ext"
}

# ============================================================================
# File Information
# ============================================================================

# @description  Show detailed information about a file (type, size, permissions, etc.)
# @param  $1    string  File path
# @return       void
function fileinfo() {
  local file="${1:?Usage: fileinfo <file>}"

  if [[ ! -e "$file" ]]; then
    log_error "Not found: %s" "$file"
    return 1
  fi

  printf "\n  📄 File Info: %s\n" "$file"
  printf "  ─────────────────────────────────\n"
  printf "  Type:      %s\n" "$(file -b "$file")"
  printf "  MIME:      %s\n" "$(file -b --mime-type "$file")"

  if [[ -f "$file" ]]; then
    local size
    if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
      size=$(stat -f%z "$file")
    else
      size=$(stat --printf="%s" "$file")
    fi
    printf "  Size:      %s (%s bytes)\n" "$(numfmt --to=iec "$size" 2>/dev/null || echo "${size}B")" "$size"
    printf "  Lines:     %s\n" "$(wc -l < "$file" | tr -d ' ')"
    printf "  Words:     %s\n" "$(wc -w < "$file" | tr -d ' ')"
    printf "  Encoding:  %s\n" "$(file -b --mime-encoding "$file")"
  fi

  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    printf "  Perms:     %s\n" "$(stat -f '%Sp (%Lp)' "$file")"
    printf "  Owner:     %s:%s\n" "$(stat -f '%Su' "$file")" "$(stat -f '%Sg' "$file")"
    printf "  Modified:  %s\n" "$(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$file")"
  else
    printf "  Perms:     %s (%a)\n" "$(stat --printf='%A' "$file")" "$(stat --printf='%a' "$file")"
    printf "  Owner:     %s:%s\n" "$(stat --printf='%U' "$file")" "$(stat --printf='%G' "$file")"
    printf "  Modified:  %s\n" "$(stat --printf='%y' "$file" | cut -d. -f1)"
  fi

  if [[ -L "$file" ]]; then
    printf "  Symlink→:  %s\n" "$(readlink -f "$file")"
  fi

  printf "  ─────────────────────────────────\n\n"
}

# @description  Compare two files side by side (using diff/delta)
# @param  $1    string  File A
# @param  $2    string  File B
# @return       void
function compare() {
  local a="${1:?Usage: compare <file1> <file2>}"
  local b="${2:?Usage: compare <file1> <file2>}"

  if has "delta"; then
    delta "$a" "$b"
  elif has "bat"; then
    diff -u "$a" "$b" | bat --language diff
  else
    diff -u --color "$a" "$b"
  fi
}

# ============================================================================
# Quick File Creation
# ============================================================================

# @description  Create a file with content from stdin or argument
# @param  $1    string  File path
# @param  $2    string  (optional) Content
# @return       void
function mkfile() {
  local file="${1:?Usage: mkfile <file> [content]}"
  shift
  local content="$*"

  mkdir -p "$(dirname "$file")"

  if [[ -n "$content" ]]; then
    printf "%s\n" "$content" > "$file"
  else
    touch "$file"
  fi
  log_info "Created: %s" "$file"
}

# @description  Create a temporary file and open it in the editor
# @param  $1    string  (optional) File extension (default: txt)
# @return       void (prints temp file path to stdout)
function tmpfile() {
  local ext="${1:-txt}"
  local tmp
  tmp=$(mktemp "/tmp/scratch-XXXXXX.${ext}")
  "${EDITOR:-nvim}" "$tmp"
  printf "%s\n" "$tmp"
}

log_debug "File operation functions loaded"
