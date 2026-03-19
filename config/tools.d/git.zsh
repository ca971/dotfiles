# ============================================================================
# Git — aliases & options
# @see https://git-scm.com
# ============================================================================

# ── Status ───────────────────────────────────────────────────────────────────
alias gs="git status --short --branch"
alias gst="git status"

# ── Staging ──────────────────────────────────────────────────────────────────
alias ga="git add --all"
alias gap="git add --patch"

# ── Commit ───────────────────────────────────────────────────────────────────
alias gc="git commit -m"
alias gcs="git commit -s -m"
alias gca="git commit --amend --no-edit"

# ── Push / Pull ──────────────────────────────────────────────────────────────
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gpl="git pull --rebase"
alias gfa="git fetch --all --prune --tags"

# ── Log ──────────────────────────────────────────────────────────────────────
alias glog="git log --oneline --graph --decorate --all"
alias glg="git log --graph --pretty=format:'%C(auto)%h%d %s %C(dim)(%ar) %C(blue)<%an>%Creset' --all"

# ── Diff ─────────────────────────────────────────────────────────────────────
alias gd="git diff"
alias gds="git diff --staged"

# ── Branch ───────────────────────────────────────────────────────────────────
alias gb="git branch -vv"
alias gba="git branch -avv"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gsw="git switch"
alias gswc="git switch -c"

# ── Stash ────────────────────────────────────────────────────────────────────
alias gsta="git stash push -m"
alias gstp="git stash pop"
alias gstl="git stash list"

# ── Reset ────────────────────────────────────────────────────────────────────
alias grsh="git reset --soft HEAD~1"
alias grhh="git reset --hard HEAD"

# ── Remote & Tags ────────────────────────────────────────────────────────────
alias grm="git remote -v"
alias gtl="git tag -l --sort=-v:refname"
alias gwt="git worktree list"
