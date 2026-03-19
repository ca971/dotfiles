{ pkgs }:

with pkgs; [
  # ── Containers ─────────────────────────────────────────────────────
  docker-client
  lazydocker
  dive

  # ── Kubernetes ─────────────────────────────────────────────────────
  kubectl
  k9s
  kubernetes-helm
  kustomize
  stern # Multi-pod log tailing
  kubectx # Context/namespace switching

  # ── Infrastructure ─────────────────────────────────────────────────
  terraform
  ansible
  act # GitHub Actions local
  trivy # Security scanner

  # ── Database CLI ───────────────────────────────────────────────────
  postgresql_16 # psql
  sqlite

  # ── API & Testing ──────────────────────────────────────────────────
  grpcurl # gRPC CLI
  hey # HTTP load testing
  k6 # Load testing

  # ── Documentation ──────────────────────────────────────────────────
  mdbook # Rust-based book generator
  pandoc # Universal document converter

  # ── Build Tools ────────────────────────────────────────────────────
  gnumake
  cmake
  pkg-config
]
