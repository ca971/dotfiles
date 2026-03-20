{ pkgs }:

pkgs.mkShell {
  name = "rust-dev";

  buildInputs = with pkgs; [
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
    pkg-config
    openssl.dev
    libiconv
    cargo-watch
    cargo-edit
    cargo-nextest
  ];

  shellHook = ''
    echo "  🦀 Rust dev shell"
    echo "  $(rustc --version)"
  '';
}
