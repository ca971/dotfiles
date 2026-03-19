#!/usr/bin/env zsh
# ============================================================================
# @file        tools/kubernetes.zsh
# @description Kubernetes — context/namespace management + functions.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_KUBERNETES_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_KUBERNETES_LOADED=1

has "kubectl" || return 0
log_debug "Configuring kubernetes"

[[ -f "${DOTFILES_DIR}/config/tools.d/kubernetes.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/kubernetes.zsh"

[[ -d "$(dirname "$KUBECONFIG")" ]] || mkdir -p "$(dirname "$KUBECONFIG")" 2>/dev/null

function kctx()   { local c; has "fzf" && c=$(kubectl config get-contexts -o name | fzf --header='Context' --preview='kubectl config view --context={} --minify') || { kubectl config get-contexts; printf "Context: "; read -r c; }; [[ -n "$c" ]] && kubectl config use-context "$c"; }
function kns()    { local ns="${1:-}"; [[ -z "$ns" ]] && has "fzf" && ns=$(kubectl get ns -o name | sed 's|namespace/||' | fzf --header='Namespace'); [[ -n "$ns" ]] && kubectl config set-context --current --namespace="$ns"; }
function kwhere() { printf "  ☸ Context: %s\n  📦 Namespace: %s\n" "$(kubectl config current-context 2>/dev/null)" "$(kubectl config view --minify -o 'jsonpath={..namespace}' 2>/dev/null || echo 'default')"; }
function kall()   { kubectl get all,ingress,configmap,secret,pvc "$@"; }
function kwatch() { kubectl get pods --watch "$@"; }
function ksh()    { local pod shell="${1:-/bin/sh}"; has "fzf" && pod=$(kubectl get pods --no-headers -o custom-columns=':metadata.name,:status.phase' | fzf --header='Pod' | awk '{print $1}') || { kubectl get pods; printf "Pod: "; read -r pod; }; [[ -n "$pod" ]] && kubectl exec -it "$pod" -- "$shell"; }
function klogs()  { local pod; has "fzf" && pod=$(kubectl get pods --no-headers -o custom-columns=':metadata.name' | fzf --header='Logs') || { kubectl get pods; printf "Pod: "; read -r pod; }; [[ -n "$pod" ]] && kubectl logs -f --tail=200 "$pod"; }
function ktop()   { printf "\n  ☸ Nodes\n"; kubectl top nodes 2>/dev/null; printf "\n  ☸ Pods\n"; kubectl top pods --sort-by=cpu 2>/dev/null | head -20; printf "\n"; }
function kinfo()  { printf "\n  ☸ Cluster\n  ─────────────────\n"; kwhere; printf "  Nodes: %s\n  Pods:  %s\n  ─────────────────\n\n" "$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')" "$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l | tr -d ' ')"; }
function kapply() { log_info "Dry-run:"; kubectl apply --dry-run=client "$@"; printf "\nApply? [y/N]: "; read -rk1 c; echo; [[ "${c:l}" == "y" ]] && kubectl apply "$@"; }

log_debug "kubernetes configured"
