#!/usr/bin/env zsh
# ============================================================================
# @file        tools/git.zsh
# @description Git — auto-setup, signing, templates, workflow functions.
#              Aliases in config/tools.d/git.zsh
#              Native configs in config/git/
# @version     5.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_GIT_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_GIT_LOADED=1

has "git" || return 0
log_debug "Configuring git"

readonly GIT_TEMPLATES_REPO="https://github.com/ca971/git-templates.git"
readonly GIT_TEMPLATES_DIR="${DOTFILES_DIR}/config/git/git-templates"

# ── Source config (aliases, env vars) ────────────────────────────────────────
[[ -f "${DOTFILES_DIR}/config/tools.d/git.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/git.zsh"

# ============================================================================
# Auto-Setup — Order matters!
# 1. Symlinks FIRST (before any git config --global)
# 2. Local identity
# 3. Git templates clone
# 4. Credential helpers (writes to ~/.gitconfig which is now a symlink)
# ============================================================================

function _git_auto_setup() {

  # ── 1. Ensure local/ exists ──────────────────────────────────────────
  [[ -d "${DOTFILES_DIR}/local" ]] || mkdir -p "${DOTFILES_DIR}/local" 2>/dev/null

  # ── 2. Create local identity if missing ──────────────────────────────
  if [[ ! -f "${DOTFILES_DIR}/local/gitconfig.local" ]]; then
    cat > "${DOTFILES_DIR}/local/gitconfig.local" << 'EOF'
[user]
  name = Your Name
  email = your@email.com
EOF
    log_debug "Created local/gitconfig.local"
  fi

  # ── 3. Symlink ALL config/git/.git* files to ~ ──────────────────────
  # This MUST happen BEFORE any git config --global calls
  # because git config --global writes to ~/.gitconfig
  local _gf _gn _gt
  for _gf in "${DOTFILES_DIR}"/config/git/.git*(N); do
    [[ -f "$_gf" ]] || continue
    _gn="${_gf:t}"       # basename
    _gt="${HOME}/${_gn}"  # target in ~

    # Skip if already correctly linked
    if [[ -L "$_gt" ]] && [[ "$(readlink "$_gt" 2>/dev/null)" == "$_gf" ]]; then
      continue
    fi

    # Backup existing file (not a symlink)
    if [[ -f "$_gt" ]] && [[ ! -L "$_gt" ]]; then
      mv "$_gt" "${_gt}.bak.$(date +%s)" >/dev/null 2>&1
      log_debug "Backed up %s" "$_gn"
    fi

    # Remove stale symlink
    [[ -L "$_gt" ]] && rm -f "$_gt" >/dev/null 2>&1

    # Create symlink
    ln -sf "$_gf" "$_gt" >/dev/null 2>&1
    log_debug "Symlinked %s → %s" "$_gn" "$_gf"
  done

  # ── 4. Clone git-templates (background) ──────────────────────────────
  if [[ ! -d "${GIT_TEMPLATES_DIR}/.git" ]]; then
    { git clone --depth=1 --quiet "$GIT_TEMPLATES_REPO" "$GIT_TEMPLATES_DIR" 2>/dev/null } &!
  else
    { git -C "$GIT_TEMPLATES_DIR" pull --rebase --quiet 2>/dev/null } &!
  fi

  # ── 5. Credential helpers ─────────────────────────────────────────
  # Only set if not already configured (avoid duplicates)
  local _current_helper
  _current_helper=$(git config --global credential.helper 2>/dev/null)

  if [[ -z "$_current_helper" ]]; then
    case "$ZSH_PLATFORM" in
      darwin)
        git config --global credential.helper osxkeychain 2>/dev/null
        ;;
      linux|wsl)
        if has "git-credential-libsecret"; then
          git config --global credential.helper libsecret 2>/dev/null
        else
          git config --global credential.helper "cache --timeout=86400" 2>/dev/null
        fi
        ;;
    esac
  fi

  # GitHub CLI — only add if not already present
  if has "gh"; then
    local _gh_helper
    _gh_helper=$(git config --global --get-all "credential.https://github.com.helper" 2>/dev/null)
    if ! echo "$_gh_helper" | grep -q "gh auth" 2>/dev/null; then
      git config --global "credential.https://github.com.helper" "" 2>/dev/null
      git config --global --add "credential.https://github.com.helper" "!gh auth git-credential" 2>/dev/null
    fi
  fi
}

_git_auto_setup

# ── Pager ────────────────────────────────────────────────────────────────────
if has "delta"; then
  export GIT_PAGER="delta"
elif has "bat"; then
  export GIT_PAGER="bat --plain"
fi

# ============================================================================
# Functions — Workflow
# ============================================================================

function gquick() {
  local m="$1" p="${2:-}"
  [[ -z "$m" ]] && { log_error "Usage: gquick <msg> [--push]"; return 1; }
  git add --all
  git commit -m "$m"
  [[ "$p" == "--push" || "$p" == "-p" ]] && git push
}

function gconv() {
  local type="$1" scope="" desc=""
  if [[ -z "$type" ]]; then
    if has "fzf"; then
      type=$(printf "feat\nfix\ndocs\nstyle\nrefactor\ntest\nchore\nci\nperf\nbuild\nrevert\nrelease" | \
        fzf --header='Commit type' --height='40%' --border)
    else
      printf "Type: "; read -r type
    fi
    [[ -z "$type" ]] && return 0
    printf "Scope (optional): "; read -r scope
    printf "Description: "; read -r desc
    [[ -z "$desc" ]] && { log_error "Description required"; return 1; }
  else
    case "$#" in
      1) log_error "Usage: gconv <type> [scope] <desc>"; return 1 ;;
      2) desc="$2" ;;
      *) scope="$2"; shift 2; desc="$*" ;;
    esac
  fi
  [[ -n "$scope" ]] && git commit -m "${type}(${scope}): ${desc}" || git commit -m "${type}: ${desc}"
}

function ginfo() {
  git rev-parse --is-inside-work-tree &>/dev/null || { log_error "Not in a Git repo"; return 1; }
  local b=$(git branch --show-current 2>/dev/null)
  local r=$(git remote get-url origin 2>/dev/null || echo "none")
  local a=0 be=0
  local ab=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
  [[ -n "$ab" ]] && { a=$(echo "$ab" | cut -f1); be=$(echo "$ab" | cut -f2); }
  printf "\n  📊 Git Info\n  ─────────────────────\n"
  printf "  Branch: %s\n  Remote: %s\n" "$b" "$r"
  printf "  Ahead:  %s  Behind: %s\n" "$a" "$be"
  printf "  Stash:  %s\n" "$(git stash list 2>/dev/null | wc -l | tr -d ' ')"
  printf "  Root:   %s\n" "$(git rev-parse --show-toplevel 2>/dev/null)"
  printf "  ─────────────────────\n\n"
}

function gundo()    { git reset --soft HEAD~1; log_info "Undone"; }
function gstats()   { git log --stat --oneline -"${1:-10}"; }
function gcontrib() { git shortlog -sn --all --no-merges; }

function gstandup() {
  local d="${1:-1}" a=$(git config user.name)
  printf "\n  📋 Standup (%s)\n  ─────────────────────\n" "$a"
  [[ "$d" == "today" ]] && d=0
  if (( d == 0 )); then
    git log --since='00:00:00' --author="$a" --oneline --no-merges 2>/dev/null | sed 's/^/    /'
  else
    git log --since="${d} days ago" --author="$a" --oneline --no-merges 2>/dev/null | sed 's/^/    /'
  fi
  printf "\n"
}

function grepo() {
  git rev-parse --is-inside-work-tree &>/dev/null || return 1
  local root=$(git rev-parse --show-toplevel)
  printf "\n  📊 Repo Health\n  ═══════════════════════\n"
  printf "  Name:     %s\n" "$(basename "$root")"
  printf "  Branch:   %s\n" "$(git branch --show-current)"
  printf "  Commits:  %s\n" "$(git rev-list --count HEAD 2>/dev/null)"
  printf "  .git:     %s\n" "$(du -sh "${root}/.git" 2>/dev/null | awk '{print $1}')"
  printf "  Last:     %s\n" "$(git log -1 --format='%ar by %an' 2>/dev/null)"
  printf "  ═══════════════════════\n\n"
}

function ginit() {
  local d="${1:-.}"
  [[ "$d" != "." ]] && { mkdir -p "$d" && cd "$d"; }
  git init && git checkout -b main 2>/dev/null
  echo "# $(basename "$PWD")" > README.md
  git add README.md && git commit -m "chore: initial commit"
  log_info "Initialized"
}

# ============================================================================
# Functions — Branch
# ============================================================================

function gbranch() {
  local t tk desc
  if has "fzf"; then
    t=$(printf "feat\nfix\nchore\ndocs\nrefactor\ntest\nci\nhotfix\nrelease" | \
      fzf --header='Branch type' --height='40%' --border)
  else
    printf "Type: "; read -r t
  fi
  [[ -z "$t" ]] && return 0
  printf "Ticket (optional): "; read -r tk
  printf "Description: "; read -r desc
  [[ -z "$desc" ]] && { log_error "Required"; return 1; }
  desc=$(echo "$desc" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | tr -cd 'a-z0-9-')
  local name
  [[ -n "$tk" ]] && name="${t}/$(echo "$tk" | tr '[:lower:]' '[:upper:]')-${desc}" || name="${t}/${desc}"
  git switch -c "$name"
  log_info "Created: %s" "$name"
}

function gclean-branches() {
  local br=$(git branch --merged | grep -vE '(main|master|develop|\*)' | sed 's/^[[:space:]]*//')
  [[ -z "$br" ]] && { log_info "No merged branches"; return 0; }
  if has "fzf"; then
    echo "$br" | fzf --multi --header='Delete branches' \
      --preview 'git log --oneline --max-count=10 {}' | xargs -r git branch -d
  else
    echo "$br" | xargs -r git branch -d
  fi
}

# ============================================================================
# Functions — Rebase
# ============================================================================

function grebase() {
  has "fzf" || return 1
  local c=$(git log --oneline -40 | \
    fzf --header='Rebase onto' --preview='git show --color=always {1}' | awk '{print $1}')
  [[ -n "$c" ]] && git rebase -i "${c}^"
}

function gsquash() {
  local n="${1:-2}" m="${2:-}"
  [[ -z "$m" ]] && { printf "Message: "; read -r m; }
  git reset --soft "HEAD~${n}"
  [[ -n "$m" ]] && git commit -m "$m" || git commit
}

function gfixup() {
  has "fzf" || return 1
  local c=$(git log --oneline -30 | \
    fzf --header='Fixup' --preview='git show --color=always {1}' | awk '{print $1}')
  [[ -z "$c" ]] && return 0
  git commit --fixup "$c"
  printf "Auto-squash? [y/N]: "; read -rk1 a; echo
  [[ "${a:l}" == "y" ]] && GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash "${c}^"
}

# ============================================================================
# Functions — Changelog & Release
# ============================================================================

function gchangelog() {
  local from="${1:-$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)}"
  local to="${2:-HEAD}"
  printf "\n  📝 Changelog: %s → %s\n\n" "$from" "$to"
  local -A L=(
    [feat]="✨ Features" [fix]="🐛 Fixes" [docs]="📚 Docs"
    [refactor]="♻️  Refactor" [chore]="🔧 Chores" [ci]="🔄 CI"
    [test]="🧪 Tests" [perf]="⚡ Perf" [build]="📦 Build" [release]="🚀 Release"
  )
  local t
  for t in feat fix docs refactor chore ci test perf build release; do
    local c=$(git log --oneline --no-merges "${from}..${to}" --grep="^${t}" 2>/dev/null)
    if [[ -n "$c" ]]; then
      printf "  %s\n" "${L[$t]}"
      echo "$c" | while read -r l; do printf "    • %s\n" "$l"; done
      printf "\n"
    fi
  done
}

function grelease() {
  local v="${1:-}"
  if [[ -z "$v" ]]; then
    local lt=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    local ma=$(echo "${lt#v}" | cut -d. -f1)
    local mi=$(echo "${lt#v}" | cut -d. -f2)
    local pa=$(echo "${lt#v}" | cut -d. -f3)
    if has "fzf"; then
      v=$(printf "v%s.%s.%s (patch)\nv%s.%s.0 (minor)\nv%s.0.0 (major)" \
        "$ma" "$mi" "$((pa+1))" "$ma" "$((mi+1))" "$((ma+1))" | \
        fzf --header="Last: ${lt}" --height='30%' --border | awk '{print $1}')
    else
      printf "Version: "; read -r v
    fi
  fi
  [[ -z "$v" ]] && return 0
  [[ "$v" != v* ]] && v="v${v}"
  gchangelog
  printf "  Create %s? [y/N]: " "$v"
  read -rk1 c; echo
  if [[ "${c:l}" == "y" ]]; then
    git tag -a "$v" -m "Release ${v}" && git push origin "$v"
    if has "gh"; then
      printf "  GitHub release? [y/N]: "
      read -rk1 g; echo
      [[ "${g:l}" == "y" ]] && gh release create "$v" --generate-notes
    fi
  fi
}

# ============================================================================
# Functions — Signing
# ============================================================================

function _git_discover_github_keys() {
  local k
  for k in "${HOME}/.ssh"/id_github_*(N) "${HOME}/.ssh"/id_fallback_*(N); do
    [[ -f "$k" && "$k" != *.pub ]] && echo "$k"
  done
}

function git-signing-ssh() {
  local mode="${1:-}" pub_key=""
  local -a keys=() labels=()
  local k fp name

  # GitHub keys first
  while IFS= read -r k; do
    [[ -z "$k" ]] && continue
    name=$(basename "$k")
    fp=$(ssh-keygen -lf "${k}.pub" 2>/dev/null | awk '{print $2}')
    [[ -f "${k}.pub" ]] || continue
    keys+=("${k}.pub")
    labels+=("★ ${name} (${fp}) — GitHub")
  done < <(_git_discover_github_keys)

  # Other keys
  for k in "${HOME}/.ssh"/id_*(N); do
    [[ -f "$k" && "$k" != *.pub ]] || continue
    local skip=0
    while IFS= read -r gk; do
      [[ "$k" == "$gk" ]] && { skip=1; break; }
    done < <(_git_discover_github_keys)
    (( skip )) && continue
    [[ -f "${k}.pub" ]] || continue
    name=$(basename "$k")
    fp=$(ssh-keygen -lf "${k}.pub" 2>/dev/null | awk '{print $2}')
    keys+=("${k}.pub")
    labels+=("  ${name} (${fp})")
  done

  (( ${#keys} == 0 )) && { log_error "No SSH keys found"; return 1; }

  if [[ -n "$mode" && -f "$mode" ]]; then
    pub_key="$mode"
  elif [[ -n "$mode" && -f "${mode}.pub" ]]; then
    pub_key="${mode}.pub"
  elif has "fzf"; then
    local sel
    sel=$(printf '%s\n' "${labels[@]}" | \
      fzf --header='🔐 Signing key (★=GitHub)' --height='40%' --border)
    [[ -z "$sel" ]] && return 0
    local idx=1
    for l in "${labels[@]}"; do
      [[ "$l" == "$sel" ]] && { pub_key="${keys[$idx]}"; break; }
      idx=$((idx+1))
    done
  else
    printf "\n  Select:\n"
    local i=1
    for l in "${labels[@]}"; do printf "    %d) %s\n" "$i" "$l"; i=$((i+1)); done
    printf "  Choice: "; local ch; read -r ch
    [[ "$ch" =~ ^[0-9]+$ ]] && (( ch >= 1 && ch <= ${#keys} )) && pub_key="${keys[$ch]}"
  fi

  [[ -z "$pub_key" || ! -f "$pub_key" ]] && { log_error "No valid key"; return 1; }

  git config --global gpg.format ssh
  git config --global user.signingkey "$pub_key"
  git config --global commit.gpgSign true
  git config --global tag.gpgSign true
  git config --global gpg.ssh.allowedSignersFile "${DOTFILES_DIR}/config/git/.allowed_signers"

  local email=$(git config --global user.email 2>/dev/null)
  if [[ -n "$email" ]] && [[ -f "${DOTFILES_DIR}/config/git/.allowed_signers" ]]; then
    grep -q "$email" "${DOTFILES_DIR}/config/git/.allowed_signers" 2>/dev/null || \
      printf "%s %s\n" "$email" "$(cat "$pub_key")" >> "${DOTFILES_DIR}/config/git/.allowed_signers"
  fi
  log_info "SSH signing: %s" "$(basename "$pub_key")"
}

function git-signing-info() {
  printf "\n  🔐 Signing\n  ─────────────────\n"
  printf "  Format:  %s\n" "$(git config --global gpg.format 2>/dev/null || echo 'not set')"
  printf "  Key:     %s\n" "$(basename "$(git config --global user.signingkey 2>/dev/null || echo 'not set')")"
  printf "  Commits: %s\n" "$(git config --global commit.gpgSign 2>/dev/null || echo 'false')"
  printf "  Tags:    %s\n" "$(git config --global tag.gpgSign 2>/dev/null || echo 'false')"
  printf "  ─────────────────\n\n"
}

function git-signing-off() {
  git config --global --unset commit.gpgSign 2>/dev/null
  git config --global --unset tag.gpgSign 2>/dev/null
  git config --global --unset user.signingkey 2>/dev/null
  log_info "Signing disabled"
}

function git-verify() {
  printf "  Verifying %s... " "${1:-HEAD}"
  git verify-commit "${1:-HEAD}" 2>/dev/null && printf "✅\n" || printf "❌\n"
}

function git-trust() {
  local e="${1:?Usage: git-trust <email> <key>}" kf="${2:?}"
  [[ -f "$kf" ]] || { log_error "Key not found"; return 1; }
  local sf="${DOTFILES_DIR}/config/git/.allowed_signers"
  [[ -f "$sf" ]] || touch "$sf"
  grep -q "$e" "$sf" 2>/dev/null && { log_warn "Already trusted"; return 0; }
  printf "%s %s\n" "$e" "$(cat "$kf")" >> "$sf"
  log_info "Trusted: %s" "$e"
}

# ============================================================================
# Functions — Templates
# ============================================================================

function git-templates-install() {
  if [[ -d "${GIT_TEMPLATES_DIR}/.git" ]]; then
    git -C "$GIT_TEMPLATES_DIR" pull --rebase
  else
    rm -rf "$GIT_TEMPLATES_DIR" 2>/dev/null
    git clone --depth=1 "$GIT_TEMPLATES_REPO" "$GIT_TEMPLATES_DIR"
  fi
  git config --global init.templateDir "$GIT_TEMPLATES_DIR"
  git config --global core.hooksPath "${GIT_TEMPLATES_DIR}/hooks"
  [[ -x "${GIT_TEMPLATES_DIR}/install.sh" ]] && bash "${GIT_TEMPLATES_DIR}/install.sh"
  log_info "Templates configured"
}

function git-templates-info() {
  printf "\n  🪝 Git Templates\n  ─────────────────\n"
  printf "  Repo: %s\n  Local: %s\n" "$GIT_TEMPLATES_REPO" "$GIT_TEMPLATES_DIR"
  if [[ -d "${GIT_TEMPLATES_DIR}/.git" ]]; then
    printf "  Status: ✅ (%s)\n  Hooks:\n" "$(git -C "$GIT_TEMPLATES_DIR" rev-parse --short HEAD 2>/dev/null)"
    for h in "${GIT_TEMPLATES_DIR}"/hooks/*(N:t); do
      [[ "$h" == _* || "$h" == *.sample ]] && continue
      printf "    • %s\n" "$h"
    done
  else
    printf "  Status: ❌\n"
  fi
  printf "  ─────────────────\n\n"
}

function git-templates-remove() {
  [[ -d "$GIT_TEMPLATES_DIR" ]] && rm -rf "$GIT_TEMPLATES_DIR"
  git config --global --unset init.templateDir 2>/dev/null
  git config --global --unset core.hooksPath 2>/dev/null
  log_info "Removed"
}

# ============================================================================
# Functions — PR/GitHub
# ============================================================================

function gflow() {
  has "gh" || { log_error "gh required"; return 1; }
  printf "\n  🔀 Flow\n  1) Branch  2) Push+PR  3) Review  4) Merge  5) Cleanup\n  Choice: "
  read -rk1 c; echo
  case "$c" in
    1) gbranch ;;
    2) git push -u origin "$(git branch --show-current)"; gpr ;;
    3) greview ;;
    4)
      if has "fzf"; then
        local pr=$(gh pr list --json number,title \
          --template '{{range .}}#{{.number}} {{.title}}{{"\n"}}{{end}}' | \
          fzf | awk '{print $1}' | tr -d '#')
        [[ -n "$pr" ]] && {
          printf "  [m]erge [s]quash [r]ebase: "; read -rk1 m; echo
          case "${m:l}" in
            m) gh pr merge "$pr" --merge --delete-branch ;;
            s) gh pr merge "$pr" --squash --delete-branch ;;
            r) gh pr merge "$pr" --rebase --delete-branch ;;
          esac
        }
      fi ;;
    5) gclean-branches ;;
  esac
}

function gpr() {
  has "gh" || return 1
  local base=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
  local title body
  printf "Title: "; read -r title; [[ -z "$title" ]] && return 0
  printf "Notes: "; read -r body
  gh pr create --title "$title" --body "${body:-}" --base "${base:-main}"
}

function greview() {
  has "gh" || return 1
  local pr
  if has "fzf"; then
    pr=$(gh pr list --limit 20 --json number,title,author \
      --template '{{range .}}#{{.number}} {{.title}} ({{.author.login}}){{"\n"}}{{end}}' | \
      fzf --header='PR' --preview='gh pr view {1} 2>/dev/null' | \
      awk '{print $1}' | tr -d '#')
  else
    gh pr list; printf "PR#: "; read -r pr
  fi
  [[ -z "$pr" ]] && return 0
  printf "  [d]iff [c]heckout [a]pprove [w]eb: "; read -rk1 a; echo
  case "${a:l}" in
    d) gh pr diff "$pr" ;; c) gh pr checkout "$pr" ;;
    a) gh pr review "$pr" --approve ;; w) gh pr view "$pr" --web ;;
  esac
}

function gissue() {
  has "gh" || return 1
  local t title body
  if has "fzf"; then
    t=$(printf "bug\nfeature\ndocs\nquestion" | fzf --header='Type' --height='30%')
  else
    printf "Type: "; read -r t
  fi
  [[ -z "$t" ]] && return 0
  printf "Title: "; read -r title; [[ -z "$title" ]] && return 0
  printf "Body: "; read -r body
  gh issue create --title "$title" --body "${body:-}" --label "$t"
}

function gh-actions() {
  has "gh" || return 1
  if has "fzf"; then
    local r=$(gh run list --limit 20 --json databaseId,displayTitle,status \
      --template '{{range .}}{{.databaseId}}	{{.status}}	{{.displayTitle}}{{"\n"}}{{end}}' | \
      fzf --header='Runs' --delimiter='\t' --preview='gh run view {1}' | \
      awk -F'\t' '{print $1}')
    [[ -n "$r" ]] && {
      printf "  [v]iew [l]ogs [r]erun [w]eb: "; read -rk1 a; echo
      case "${a:l}" in
        v) gh run view "$r" ;; l) gh run view "$r" --log ;;
        r) gh run rerun "$r" ;; w) gh run view "$r" --web ;;
      esac
    }
  else
    gh run list --limit 10
  fi
}

# ============================================================================
# Functions — Maintenance
# ============================================================================

function git-optimize() {
  git rev-parse --is-inside-work-tree &>/dev/null || return 1
  printf "  Optimizing...\n"
  git commit-graph write --reachable --changed-paths 2>/dev/null
  git gc --aggressive --prune=now 2>/dev/null
  git repack -a -d --depth=250 --window=250 2>/dev/null
  printf "  ✅ Done (.git: %s)\n\n" "$(du -sh "$(git rev-parse --git-dir)" 2>/dev/null | awk '{print $1}')"
}

function git-maintenance-enable() {
  git rev-parse --is-inside-work-tree &>/dev/null || return 1
  git maintenance start
  log_info "Maintenance enabled"
}

function git-lfs-setup() {
  has "git-lfs" || { log_error "git-lfs not installed"; return 1; }
  git lfs install
  printf "Track binaries? [y/N]: "; read -rk1 c; echo
  [[ "${c:l}" == "y" ]] && {
    for ext in png jpg jpeg gif svg webp mp3 mp4 wav zip tar.gz 7z pdf psd woff woff2 ttf; do
      git lfs track "*.${ext}" 2>/dev/null
    done
    git add .gitattributes
  }
}

function git-sparse() {
  case "${1:-}" in
    init)    git sparse-checkout init --cone ;;
    add)     shift; git sparse-checkout add "$@" ;;
    list|ls) git sparse-checkout list 2>/dev/null ;;
    disable) git sparse-checkout disable ;;
    *)       printf "  Usage: git-sparse <init|add|list|disable>\n" ;;
  esac
}

function gworktree() {
  case "${1:-list}" in
    add|a)
      local b="${2:-}"
      [[ -z "$b" ]] && { printf "Branch: "; read -r b; }
      [[ -z "$b" ]] && return 0
      local w="../$(basename "$PWD")-${b}"
      git worktree add "$w" -b "$b" 2>/dev/null || git worktree add "$w" "$b"
      cd "$w"
      ;;
    remove|rm)
      if has "fzf"; then
        local wt=$(git worktree list | grep -v "(bare)" | fzf --header='Worktree' | awk '{print $1}')
        [[ -n "$wt" ]] && git worktree remove "$wt"
      else
        git worktree list
      fi
      ;;
    list|ls|"")
      git worktree list
      ;;
  esac
}

function git-secrets-scan() {
  local m="${1:-staged}" files
  [[ "$m" == "staged" ]] && files=$(git diff --cached --name-only 2>/dev/null) || files=$(git ls-files 2>/dev/null)
  [[ -z "$files" ]] && return 0
  local issues=0
  local patterns=(
    'PRIVATE KEY'
    'password\s*[:=]\s*["\x27]'
    'secret\s*[:=]\s*["\x27]'
    'api[_-]?key\s*[:=]\s*["\x27]'
    'token\s*[:=]\s*["\x27]'
    'AWS_SECRET'
    'GITHUB_TOKEN'
    'gh[pousr]_[A-Za-z0-9_]{36,}'
    'sk-[A-Za-z0-9]{20,}'
  )
  echo "$files" | while read -r f; do
    [[ -z "$f" || ! -f "$f" ]] && continue
    file -b --mime-type "$f" 2>/dev/null | grep -q "text" || continue
    for p in "${patterns[@]}"; do
      grep -inE "$p" "$f" 2>/dev/null | head -3 | while read -r match; do
        printf "  ❌ %s: %s\n" "$f" "$(echo "$match" | cut -c1-80)"
        issues=$((issues+1))
      done
    done
  done
  (( issues > 0 )) && return 1 || return 0
}

log_debug "git configured"
