{ pkgs }:

pkgs.mkShell {
  name = "python-dev";

  buildInputs = with pkgs; [
    # Python
    python313
    python313Packages.pip
    python313Packages.virtualenv
    python313Packages.ipython
    python313Packages.pytest
    python313Packages.black
    python313Packages.ruff
    python313Packages.mypy

    # Tools
    uv # Fast pip replacement
    ruff # Linter + formatter
    pyright # Type checker

    # Build deps
    gcc
    stdenv.cc.cc.lib
  ];

  env = {
    VIRTUAL_ENV_DISABLE_PROMPT = "1";
    PYTHONDONTWRITEBYTECODE = "1";
  };

  shellHook = ''
    echo "  🐍 Python dev shell"
    echo "  $(python --version)"
    # Auto-create venv if not exists
    if [ ! -d .venv ]; then
      echo "  Creating .venv..."
      python -m venv .venv
    fi
    source .venv/bin/activate
  '';
}
