{ pkgs }:

pkgs.mkShell {
  name = "devops";

  buildInputs = with pkgs; [
    # Containers
    docker-client
    lazydocker
    dive

    # Kubernetes
    kubectl
    k9s
    kubernetes-helm
    kustomize
    stern
    kubectx
    argocd

    # Infrastructure
    terraform
    terragrunt
    packer
    ansible
    pulumi

    # Cloud CLIs
    awscli2
    google-cloud-sdk

    # Monitoring
    prometheus
    grafana

    # CI/CD
    act
    gh

    # Security
    trivy
    tfsec
    checkov

    # Networking
    nmap
    mtr
    iperf3
  ];

  shellHook = ''
    echo "  ☸  DevOps shell"
    echo "  kubectl: $(kubectl version --client --short 2>/dev/null || echo 'N/A')"
    echo "  terraform: $(terraform version -json 2>/dev/null | jq -r '.terraform_version' || echo 'N/A')"
  '';
}
