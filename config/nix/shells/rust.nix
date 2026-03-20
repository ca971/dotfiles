{ pkgs }:

pkgs.mkShell {
  name = "rust-dev";

  buildInputs = with pkgs; [
    # Rust toolchain (latest stable via overlay)
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
      targets = [ "wasm32-unknown-unknown" ];
    })

    # Build dependencies
    pkg-config
    openssl.dev
    libiconv

    # Tools
    cargo-watch
    cargo-edit
    cargo-expand
    cargo-audit
    cargo-nextest
    sccache

    # WASM
    wasm-pack
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.apple-sdk.frameworks; [
    Security
    SystemConfiguration
  ]);

  env = {
    RUST_BACKTRACE = "1";
    RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
  };

  shellHook = ''
    echo "  🦀 Rust dev shell"
    echo "  $(rustc --version)"
    echo "  $(cargo --version)"
  '';
}
