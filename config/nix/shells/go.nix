{ pkgs }:

pkgs.mkShell {
  name = "go-dev";

  buildInputs = with pkgs; [
    # Go
    go_1_23

    # Tools
    gopls # LSP
    gotools # goimports, etc.
    golangci-lint # Linter
    delve # Debugger
    gomod2nix # Nix integration
    go-task # Task runner

    # Build deps
    gcc
  ];

  env = {
    GOPATH = "$HOME/.local/share/go";
    GOBIN = "$HOME/.local/share/go/bin";
  };

  shellHook = ''
    echo "  🔵 Go dev shell"
    echo "  $(go version)"
    export PATH="$GOBIN:$PATH"
  '';
}
