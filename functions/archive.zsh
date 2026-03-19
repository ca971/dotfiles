#!/usr/bin/env zsh
# ============================================================================
# @file        functions/archive.zsh
# @description Archive and compression utility functions. Provides a unified
#              interface for creating and extracting archives in all common
#              formats (tar, zip, gz, bz2, xz, 7z, rar, zstd, etc.).
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_ARCHIVE_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_ARCHIVE_LOADED=1

# ============================================================================
# Universal Extractor
# ============================================================================

# @description  Extract any archive format automatically. Detects the format
#               from the file extension and uses the appropriate tool.
#               Supports: tar, gz, bz2, xz, zst, zip, 7z, rar, deb, rpm, etc.
# @param  $1    string  Archive file path
# @param  $2    string  (optional) Target directory (default: current directory)
# @return       0 on success, 1 on error
function extract() {
  local archive="${1:?Usage: extract <archive> [target-dir]}"
  local target_dir="${2:-.}"

  if [[ ! -f "$archive" ]]; then
    log_error "File not found: %s" "$archive"
    return 1
  fi

  # -- Create target directory if it doesn't exist
  [[ -d "$target_dir" ]] || mkdir -p "$target_dir"

  log_info "Extracting: %s → %s" "$(basename "$archive")" "$target_dir"

  case "${archive:l}" in
    *.tar.gz|*.tgz)        tar -xzf  "$archive" -C "$target_dir" ;;
    *.tar.bz2|*.tbz|*.tbz2) tar -xjf  "$archive" -C "$target_dir" ;;
    *.tar.xz|*.txz)        tar -xJf  "$archive" -C "$target_dir" ;;
    *.tar.zst|*.tzst)      tar --zstd -xf "$archive" -C "$target_dir" ;;
    *.tar.lz|*.tlz)        tar --lzip -xf "$archive" -C "$target_dir" ;;
    *.tar.lz4)             lz4 -dc "$archive" | tar -xf - -C "$target_dir" ;;
    *.tar.lzma)            tar --lzma -xf "$archive" -C "$target_dir" ;;
    *.tar)                 tar -xf   "$archive" -C "$target_dir" ;;
    *.gz)                  gunzip -k  "$archive" ;;
    *.bz2)                 bunzip2 -k "$archive" ;;
    *.xz)                  unxz -k    "$archive" ;;
    *.zst)                 unzstd     "$archive" ;;
    *.lz4)                 lz4 -d     "$archive" ;;
    *.lzma)                unlzma     "$archive" ;;
    *.zip|*.jar|*.war)     unzip      "$archive" -d "$target_dir" ;;
    *.7z)                  7z x       "$archive" -o"$target_dir" ;;
    *.rar)                 unrar x    "$archive" "$target_dir" ;;
    *.cab)                 cabextract -d "$target_dir" "$archive" ;;
    *.deb)                 dpkg-deb -x "$archive" "$target_dir" ;;
    *.rpm)                 rpm2cpio "$archive" | (cd "$target_dir" && cpio -idmv) ;;
    *.Z)                   uncompress "$archive" ;;
    *.iso)                 7z x       "$archive" -o"$target_dir" 2>/dev/null || \
                           log_error "ISO extraction requires 7z" ;;
    *.dmg)
      if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
        hdiutil attach "$archive"
      else
        7z x "$archive" -o"$target_dir" 2>/dev/null
      fi
      ;;
    *)
      log_error "Unknown archive format: %s" "$archive"
      return 1
      ;;
  esac

  local exit_code=$?
  if (( exit_code == 0 )); then
    log_success "Extracted: $(basename "$archive")"
  else
    log_error "Extraction failed (exit code: %d)" "$exit_code"
  fi
  return $exit_code
}

# ============================================================================
# Universal Compressor
# ============================================================================

# @description  Create an archive from files/directories. Format is determined
#               by the output filename extension.
# @param  $1    string  Output archive name (with extension)
# @param  $@    string  Files/directories to include
# @return       0 on success, 1 on error
function compress() {
  local output="${1:?Usage: compress <output-file> <files...>}"
  shift
  local -a sources=("$@")

  if (( ${#sources} == 0 )); then
    log_error "No source files specified"
    return 1
  fi

  log_info "Creating archive: %s" "$output"

  case "${output:l}" in
    *.tar.gz|*.tgz)        tar -czf  "$output" "${sources[@]}" ;;
    *.tar.bz2|*.tbz)       tar -cjf  "$output" "${sources[@]}" ;;
    *.tar.xz|*.txz)        tar -cJf  "$output" "${sources[@]}" ;;
    *.tar.zst|*.tzst)      tar --zstd -cf "$output" "${sources[@]}" ;;
    *.tar)                 tar -cf   "$output" "${sources[@]}" ;;
    *.zip)                 zip -r    "$output" "${sources[@]}" ;;
    *.7z)                  7z a      "$output" "${sources[@]}" ;;
    *.gz)
      if (( ${#sources} == 1 )) && [[ -f "${sources[1]}" ]]; then
        gzip -k "${sources[1]}" && mv "${sources[1]}.gz" "$output"
      else
        log_error "gz format supports only a single file"
        return 1
      fi
      ;;
    *.bz2)
      if (( ${#sources} == 1 )) && [[ -f "${sources[1]}" ]]; then
        bzip2 -k "${sources[1]}" && mv "${sources[1]}.bz2" "$output"
      else
        log_error "bz2 format supports only a single file"
        return 1
      fi
      ;;
    *.xz)
      if (( ${#sources} == 1 )) && [[ -f "${sources[1]}" ]]; then
        xz -k "${sources[1]}" && mv "${sources[1]}.xz" "$output"
      else
        log_error "xz format supports only a single file"
        return 1
      fi
      ;;
    *.zst)
      if (( ${#sources} == 1 )) && [[ -f "${sources[1]}" ]]; then
        zstd "${sources[1]}" -o "$output"
      else
        log_error "zst format supports only a single file"
        return 1
      fi
      ;;
    *)
      log_error "Unknown archive format: %s" "$output"
      return 1
      ;;
  esac

  local exit_code=$?
  if (( exit_code == 0 )); then
    local size
    if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
      size=$(stat -f%z "$output" 2>/dev/null)
    else
      size=$(stat --printf="%s" "$output" 2>/dev/null)
    fi
    if (( size > 1048576 )); then
      size="$(( size / 1048576 ))MB"
    elif (( size > 1024 )); then
      size="$(( size / 1024 ))KB"
    else
      size="${size}B"
    fi
    log_success "Created: %s (%s)" "$output" "$size"
  fi
  return $exit_code
}

# ============================================================================
# Archive Inspection
# ============================================================================

# @description  List the contents of an archive without extracting
# @param  $1    string  Archive file path
# @return       void (prints file listing to stdout)
function archive_list() {
  local archive="${1:?Usage: archive_list <archive>}"

  if [[ ! -f "$archive" ]]; then
    log_error "File not found: %s" "$archive"
    return 1
  fi

  case "${archive:l}" in
    *.tar.gz|*.tgz)         tar -tzf  "$archive" ;;
    *.tar.bz2|*.tbz|*.tbz2) tar -tjf  "$archive" ;;
    *.tar.xz|*.txz)         tar -tJf  "$archive" ;;
    *.tar.zst|*.tzst)       tar --zstd -tf "$archive" ;;
    *.tar)                  tar -tf   "$archive" ;;
    *.zip|*.jar|*.war)      unzip -l  "$archive" ;;
    *.7z)                   7z l      "$archive" ;;
    *.rar)                  unrar l   "$archive" ;;
    *.deb)                  dpkg-deb --contents "$archive" ;;
    *.rpm)                  rpm -qlp  "$archive" ;;
    *)
      log_error "Unknown format: %s" "$archive"
      return 1
      ;;
  esac
}

# @description  Show archive information (size, format, file count)
# @param  $1    string  Archive file path
# @return       void
function archive_info() {
  local archive="${1:?Usage: archive_info <archive>}"

  if [[ ! -f "$archive" ]]; then
    log_error "File not found: %s" "$archive"
    return 1
  fi

  local size file_count
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    size=$(stat -f%z "$archive" 2>/dev/null)
  else
    size=$(stat --printf="%s" "$archive" 2>/dev/null)
  fi
  file_count=$(archive_list "$archive" 2>/dev/null | wc -l | tr -d ' ')

  printf "\n  📦 Archive Info\n"
  printf "  ─────────────────────────\n"
  printf "  File:    %s\n" "$(basename "$archive")"
  printf "  Size:    %s\n" "$(numfmt --to=iec "$size" 2>/dev/null || echo "${size}B")"
  printf "  Files:   %s\n" "$file_count"
  printf "  Format:  %s\n" "${archive##*.}"
  printf "  ─────────────────────────\n\n"
}

log_debug "Archive functions loaded"
