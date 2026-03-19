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
    cargo-outdated
    cargo-nextest
    cargo-deny
    sccache # Compilation cache
    mold # Fast linker (Linux)

    # WASM
    wasm-pack
    trunk
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.Security
    pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
  ];

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
