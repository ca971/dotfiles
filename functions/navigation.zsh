#!/usr/bin/env zsh
# ============================================================================
# @file        functions/navigation.zsh
# @description Smart navigation functions for quick directory traversal,
#              project jumping, bookmark management, and path manipulation.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_NAVIGATION_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_NAVIGATION_LOADED=1

# ============================================================================
# Project Navigation
# ============================================================================

# @description  Jump to a project directory via FZF selection.
#               Searches common project directories for repos/projects.
# @return       void (cd into selected project)
function proj() {
  local -a project_dirs=(
    "${HOME}/Projects"
    "${HOME}/projects"
    "${HOME}/Dev"
    "${HOME}/dev"
    "${HOME}/Code"
    "${HOME}/code"
    "${HOME}/Work"
    "${HOME}/work"
    "${HOME}/src"
    "${HOME}/repos"
  )

  # -- Find existing project directories
  local -a existing_dirs=()
  local d
  for d in "${project_dirs[@]}"; do
    [[ -d "$d" ]] && existing_dirs+=("$d")
  done

  if (( ${#existing_dirs} == 0 )); then
    log_warn "No project directories found"
    return 1
  fi

  if ! has "fzf"; then
    log_warn "fzf required for interactive project selection"
    return 1
  fi

  local project
  project=$(find "${existing_dirs[@]}" -maxdepth 2 -type d -name ".git" 2>/dev/null | \
    sed 's|/\.git$||' | sort | \
    fzf --header='📂 Select project' \
        --preview='eza --icons --tree --level=1 --color=always {} 2>/dev/null || ls -la {}' \
        --preview-window='right:40%')

  [[ -n "$project" ]] && cd "$project"
}

# @description  Create a new project directory with standard structure
# @param  $1    string  Project name
# @param  $2    string  (optional) Base directory (default: ~/Projects)
# @return       void
function mkproj() {
  local name="${1:?Usage: mkproj <project-name> [base-dir]}"
  local base="${2:-${HOME}/Projects}"

  local project_dir="${base}/${name}"
  mkdir -p "${project_dir}"/{src,docs,tests,scripts}
  cd "$project_dir"

  # -- Initialize Git if available
  if has "git"; then
    git init
    echo "# ${name}" > README.md
    echo "" >> README.md
    echo "## Getting Started" >> README.md
    git add README.md
    git commit -m "chore: initial commit"
  fi

  log_info "Project created: %s" "$project_dir"
}

# ============================================================================
# Smart Directory Navigation
# ============================================================================

# @description  Navigate up to a parent directory by name
#               Example: upfind "src" → cd up until a dir named "src" is found
# @param  $1    string  Target directory name
# @return       void
function upfind() {
  local target="${1:?Usage: upfind <dir-name>}"
  local dir="$PWD"

  while [[ "$dir" != "/" ]]; do
    if [[ "$(basename "$dir")" == "$target" ]]; then
      cd "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  log_error "Directory not found in parents: %s" "$target"
  return 1
}

# @description  Navigate to the Git root directory
# @return       void
function cdroot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$root" ]]; then
    cd "$root"
  else
    log_warn "Not inside a Git repository"
  fi
}

# @description  Go back N directories
# @param  $1    integer  (optional) Number of directories to go back (default: 1)
# @return       void
function back() {
  local count="${1:-1}"
  local path=""
  local i
  for (( i=0; i < count; i++ )); do
    path+="../"
  done
  cd "$path"
}

# ============================================================================
# Directory Stack
# ============================================================================

# @description  Show the directory stack with FZF selection
# @return       void
function dstack() {
  if ! has "fzf"; then
    dirs -v
    return
  fi

  local dir
  dir=$(dirs -v | \
    fzf --header='📚 Directory stack' \
        --preview='eza --icons --tree --level=1 --color=always {2} 2>/dev/null || ls {2}' | \
    awk '{print $1}')

  [[ -n "$dir" ]] && cd ~"$dir"
}

# ============================================================================
# Fuzzy Navigation
# ============================================================================

# @description  Fuzzy cd — type a partial path and jump to it
# @param  $1    string  Partial directory name
# @return       void
function fcd() {
  local query="${1:-}"

  if ! has "fzf"; then
    log_warn "fzf required for fuzzy cd"
    return 1
  fi

  local dir
  if has "fd"; then
    dir=$(fd --type d --hidden --follow --exclude .git --max-depth 5 . "${2:-.}" 2>/dev/null | \
      fzf --query "$query" \
          --header='📂 Fuzzy cd' \
          --preview='eza --icons --tree --level=1 --color=always {} 2>/dev/null || ls {}')
  else
    dir=$(find "${2:-.}" -type d -maxdepth 5 2>/dev/null | \
      fzf --query "$query" --header='📂 Fuzzy cd')
  fi

  [[ -n "$dir" ]] && cd "$dir"
}

# @description  Open a recent directory from ZSH directory history via FZF
# @return       void
function recent() {
  if ! has "fzf"; then
    dirs -v | head -20
    return
  fi

  if has "zoxide"; then
    local dir
    dir=$(zoxide query --list --score 2>/dev/null | \
      awk '{print $2}' | \
      fzf --header='🕐 Recent directories' \
          --preview='eza --icons --tree --level=1 --color=always {} 2>/dev/null || ls {}')
    [[ -n "$dir" ]] && cd "$dir"
  else
    dstack
  fi
}

log_debug "Navigation functions loaded"
