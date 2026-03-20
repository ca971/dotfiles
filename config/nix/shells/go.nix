{ pkgs }:

pkgs.mkShell {
  name = "go-dev";

  buildInputs = with pkgs; [
    go
    gopls
    gotools
    golangci-lint
    delve
    go-task
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
