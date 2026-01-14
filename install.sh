#!/bin/bash
set -e # Arrête le script en cas d'erreur

echo "🚀 Bootstrapping dotfiles..."

# 1. Déterminer si chezmoi est déjà installé
if ! command -v chezmoi &> /dev/null; then
  echo "📥 Installation de chezmoi via le script officiel..."
  bin_dir="$HOME/.local/bin"
  mkdir -p "$bin_dir"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin_dir"
  export PATH="$bin_dir:$PATH"
fi

# 2. Lancer l'initialisation de chezmoi
# --apply va lancer automatiquement votre script run_once_before_ que nous avons créé
echo "⚙️ Initialisation avec le dépôt ca971..."
chezmoi init --apply ca971

echo "✨ Terminé ! Relancez votre terminal ou tapez 'zsh'."

