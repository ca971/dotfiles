#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_GH_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_GH_LOADED=1
has "gh" || return 0
log_debug "Configuring gh"


function gh-pr()    { has "fzf" && { local pr=$(gh pr list --limit 50 --json number,title,author,headRefName --template '{{range .}}{{.number}}	{{.title}}	{{.author.login}}{{"\n"}}{{end}}' 2>/dev/null | fzf --header='PR' --delimiter='\t' --preview='gh pr view {1} 2>/dev/null' | awk -F'\t' '{print $1}'); [[ -n "$pr" ]] && { printf "  [C]heckout [V]iew [W]eb [D]iff: "; read -rk1 a; echo; case "${a:l}" in c) gh pr checkout "$pr" ;; v) gh pr view "$pr" ;; w) gh pr view "$pr" --web ;; d) gh pr diff "$pr" ;; esac; }; } || gh pr list; }
function gh-issue() { has "fzf" && { local i=$(gh issue list --limit 50 --json number,title --template '{{range .}}{{.number}}	{{.title}}{{"\n"}}{{end}}' 2>/dev/null | fzf --header='Issue' --delimiter='\t' --preview='gh issue view {1} 2>/dev/null' | awk -F'\t' '{print $1}'); [[ -n "$i" ]] && { printf "  [V]iew [W]eb [C]omment: "; read -rk1 a; echo; case "${a:l}" in v) gh issue view "$i" ;; w) gh issue view "$i" --web ;; c) gh issue comment "$i" ;; esac; }; } || gh issue list; }
function gh-repos() { local q="${1:-}"; [[ -z "$q" ]] && { printf "Search: "; read -r q; }; has "fzf" && { local r=$(gh search repos "$q" --limit 30 --json fullName,stargazersCount --template '{{range .}}{{.fullName}}	⭐{{.stargazersCount}}{{"\n"}}{{end}}' 2>/dev/null | fzf --header="$q" --delimiter='\t' --preview='gh repo view {1} 2>/dev/null' | awk -F'\t' '{print $1}'); [[ -n "$r" ]] && { printf "  [C]lone [V]iew [W]eb: "; read -rk1 a; echo; case "${a:l}" in c) gh repo clone "$r" ;; v) gh repo view "$r" ;; w) gh repo view "$r" --web ;; esac; }; } || gh search repos "$q" --limit 20; }
function gh-notif() { gh api notifications --jq '.[] | "\(.subject.type): \(.subject.title)"' 2>/dev/null | head -20; }

log_debug "gh configured"
