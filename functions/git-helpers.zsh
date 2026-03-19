#!/usr/bin/env zsh
# ============================================================================
# @file        functions/git-helpers.zsh
# @description Advanced Git workflow functions. Extends tools/git.zsh with
#              complex operations: interactive staging, worktree management,
#              bisect helpers, and repository analysis.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/tool-check.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_GIT_HELPERS_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_GIT_HELPERS_LOADED=1

has "git" || return 0

# ============================================================================
# Interactive Staging
# ============================================================================

# @description  Interactive file stager — select changed files via FZF to stage
# @return       void
function git-stage() {
  if ! has "fzf"; then
    git add -p
    return
  fi

  local files
  files=$(git diff --name-only --diff-filter=ACMR 2>/dev/null)
  local untracked
  untracked=$(git ls-files --others --exclude-standard 2>/dev/null)

  local all="${files}\n${untracked}"
  all=$(echo "$all" | grep -v '^$' | sort -u)

  if [[ -z "$all" ]]; then
    log_info "No changes to stage"
    return 0
  fi

  local selected
  selected=$(echo "$all" | \
    fzf --multi --header='📝 Select files to stage (Tab to multi-select)' \
        --preview='git diff --color=always {} 2>/dev/null || bat --color=always {} 2>/dev/null || cat {}' \
        --preview-window='right:60%:wrap')

  if [[ -n "$selected" ]]; then
    echo "$selected" | xargs git add
    log_info "Staged %d files" "$(echo "$selected" | wc -l)"
    git status --short
  fi
}

# ============================================================================
# Worktree Management
# ============================================================================

# @description  Create a Git worktree for a branch (parallel development)
# @param  $1    string  Branch name
# @param  $2    string  (optional) Directory path
# @return       void
function git-wt-add() {
  local branch="${1:?Usage: git-wt-add <branch> [path]}"
  local wt_path="${2:-../${branch}}"

  if git show-ref --verify --quiet "refs/heads/${branch}" 2>/dev/null; then
    git worktree add "$wt_path" "$branch"
  else
    git worktree add -b "$branch" "$wt_path"
  fi
  log_info "Worktree created: %s → %s" "$branch" "$wt_path"
}

# @description  Remove a Git worktree interactively
# @return       void
function git-wt-remove() {
  if ! has "fzf"; then
    git worktree list
    return
  fi

  local wt
  wt=$(git worktree list | grep -v "(bare)" | \
    fzf --header='🌳 Select worktree to remove' | awk '{print $1}')

  if [[ -n "$wt" ]]; then
    if confirm "Remove worktree: ${wt}?"; then
      git worktree remove "$wt"
      log_info "Worktree removed: %s" "$wt"
    fi
  fi
}

# ============================================================================
# Commit Utilities
# ============================================================================

# @description  Fixup a previous commit interactively (select via FZF)
# @return       void
function git-fixup() {
  if ! has "fzf"; then
    log_warn "fzf required for interactive fixup"
    return 1
  fi

  local commit
  commit=$(git log --oneline -30 | \
    fzf --header='🔧 Select commit to fixup' \
        --preview='git show --color=always {1}' | \
    awk '{print $1}')

  if [[ -n "$commit" ]]; then
    git commit --fixup "$commit"
    log_info "Fixup commit created for: %s" "$commit"
    printf "Auto-squash now? [y/N] "
    read -rk1 answer
    echo
    if [[ "${answer:l}" == "y" ]]; then
      git rebase -i --autosquash "${commit}^"
    fi
  fi
}

# @description  Show recent activity across all branches
# @param  $1    integer  (optional) Number of days (default: 7)
# @return       void
function git-recent() {
  local days="${1:-7}"
  printf "\n  📋 Git activity (last %d days)\n\n" "$days"
  git log --all --oneline --graph --since="${days} days ago" \
    --format="%C(auto)%h %C(blue)%an %C(dim)%ar%C(auto)%d %s"
}

# @description  Show a summary of changes between two refs
# @param  $1    string  From ref
# @param  $2    string  (optional) To ref (default: HEAD)
# @return       void
function git-changelog() {
  local from="${1:?Usage: git-changelog <from-ref> [to-ref]}"
  local to="${2:-HEAD}"

  printf "\n  📝 Changelog: %s → %s\n\n" "$from" "$to"
  git log --oneline --no-merges "${from}..${to}" | \
    awk '{
      type = "other"
      if ($2 ~ /^feat/) type = "✨ Features"
      else if ($2 ~ /^fix/) type = "🐛 Fixes"
      else if ($2 ~ /^docs/) type = "📚 Docs"
      else if ($2 ~ /^refactor/) type = "♻️  Refactor"
      else if ($2 ~ /^chore/) type = "🔧 Chores"
      else if ($2 ~ /^ci/) type = "🔄 CI"
      else if ($2 ~ /^test/) type = "🧪 Tests"
      printf "  %s\n", $0
    }'
}

# ============================================================================
# Repository Analysis
# ============================================================================

# @description  Show the largest files tracked in Git history
# @param  $1    integer  (optional) Number of results (default: 10)
# @return       void
function git-largest-files() {
  local count="${1:-10}"

  printf "\n  📊 Largest files in Git history (top %d)\n\n" "$count"

  git rev-list --objects --all | \
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
    awk '/^blob/{print $3, $4}' | \
    sort -rn | \
    head -"$count" | \
    numfmt --to=iec --field=1 2>/dev/null || \
    head -"$count"
}

# @description  Show code frequency (additions/deletions per week)
# @return       void
function git-frequency() {
  git log --format=format: --numstat | \
    awk '{add+=$1; del+=$2} END {printf "  Added: %d lines\n  Deleted: %d lines\n  Net: %+d lines\n", add, del, add-del}'
}

log_debug "Git helper functions loaded"
