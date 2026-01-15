#!/bin/bash
set -e # Exit on error

echo "🚀 Starting Power User Bootstrap..."

# 1. Ensure bin directory exists
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# 2. Install chezmoi if missing
if ! command -v chezmoi &> /dev/null; then
    echo "📥 Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
fi

# 3. Initialize dotfiles
# This will trigger the run_once_ scripts automatically
echo "⚙️ Initializing dotfiles from ca971 repository..."
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    chezmoi apply
else
    # Replace 'ca971' with your full GitHub repo URL if needed
    chezmoi init --apply ca971
fi

echo "✨ Bootstrap complete! Please restart your terminal or type 'zsh'."

