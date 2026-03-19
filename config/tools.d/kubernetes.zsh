# ============================================================================
# Kubernetes — aliases
# ============================================================================

alias k="kubectl"
alias kx="kubectl exec -it"
alias kl="kubectl logs --tail=100"
alias klf="kubectl logs -f --tail=200"
alias kd="kubectl describe"
alias krm="kubectl delete"
alias kga="kubectl get all"
alias kgp="kubectl get pods"
alias kgpw="kubectl get pods -o wide"
alias kgs="kubectl get svc"
alias kgd="kubectl get deploy"
alias kgn="kubectl get nodes -o wide"
alias kgns="kubectl get ns"
alias ka="kubectl apply -f"
alias kdel="kubectl delete -f"
alias kpf="kubectl port-forward"
alias ktop="kubectl top pods"
alias ktopn="kubectl top nodes"

export KUBECONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}/kube/config"
export KUBE_EDITOR="${EDITOR:-nvim}"
