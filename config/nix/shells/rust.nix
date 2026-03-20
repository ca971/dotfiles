{ pkgs }:

pkgs.mkShell {
  name = "rust-dev";

  buildInputs = with pkgs; [
    # Rust toolchain
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
    })

    # Build dependencies
    pkg-config
    openssl.dev
    libiconv

    # Tools
    cargo-watch
    cargo-edit
    cargo-nextest
    sccache
  ];

  env = {
    RUST_BACKTRACE = "1";
  };

  shellHook = ''
    echo "  🦀 Rust dev shell"
    echo "  $(rustc --version)"
    echo "  $(cargo --version)"
  '';
}
