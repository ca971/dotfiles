{ pkgs }:

with pkgs; [
  # ── Shell & Prompt ─────────────────────────────────────────────────
  zsh
  bash
  fish
  nushell
  starship

  # ── Core CLI ───────────────────────────────────────────────────────
  eza
  bat
  fd
  ripgrep
  fzf
  zoxide
  delta
  sd
  dust
  duf
  tokei
  hyperfine

  # ── Editor ─────────────────────────────────────────────────────────
  neovim

  # ── Git ────────────────────────────────────────────────────────────
  git
  git-lfs
  lazygit
  gh
  difftastic

  # ── Data & HTTP ────────────────────────────────────────────────────
  jq
  yq-go
  xh
  curlie

  # ── Security ───────────────────────────────────────────────────────
  gnupg
  age
  sops
  openssh

  # ── Runtime ────────────────────────────────────────────────────────
  mise

  # ── Monitoring ─────────────────────────────────────────────────────
  btop
  fastfetch
  viddy

  # ── Files ──────────────────────────────────────────────────────────
  yazi
  glow
  lnav

  # ── Shell Tools ────────────────────────────────────────────────────
  tldr
  navi
  direnv
  just
  topgrade
  gum
  carapace

  # ── Multiplexers ───────────────────────────────────────────────────
  tmux
  zellij

  # ── Utilities ──────────────────────────────────────────────────────
  shellcheck
  shfmt
  tree
  wget
  curl
  rsync
  most
]
