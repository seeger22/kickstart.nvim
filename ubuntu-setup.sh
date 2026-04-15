#!/usr/bin/env bash
set -euo pipefail

echo "=== Neovim Setup (Ubuntu) ==="

# Dependencies: git, gcc, make, ripgrep (telescope), fd (telescope), unzip, curl
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y git gcc make ripgrep fd-find unzip curl

# Install node/npm via nodesource (apt npm is often broken on Ubuntu)
if ! command -v npm &>/dev/null; then
  echo "Installing Node.js + npm..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# Install tree-sitter CLI (needed for treesitter parser compilation)
if ! command -v tree-sitter &>/dev/null; then
  echo "Installing tree-sitter-cli..."
  sudo npm install -g tree-sitter-cli
fi

# Install neovim (latest stable from GitHub releases, apt version is usually outdated)
if command -v nvim &>/dev/null; then
  echo "Neovim already installed: $(nvim --version | head -1)"
else
  echo "Installing Neovim..."
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  rm nvim-linux-x86_64.tar.gz
  echo "Installed: $(nvim --version | head -1)"
fi

# Link or clone config
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "$SCRIPT_DIR" = "$HOME/.config/nvim" ]; then
  echo "Already running from ~/.config/nvim"
elif [ -d "$HOME/.config/nvim" ]; then
  echo "Nvim config already exists at ~/.config/nvim, skipping"
elif [ -f "$SCRIPT_DIR/init.lua" ]; then
  echo "Linking $SCRIPT_DIR -> ~/.config/nvim"
  mkdir -p "$HOME/.config"
  ln -sf "$SCRIPT_DIR" "$HOME/.config/nvim"
else
  echo "Cloning config..."
  mkdir -p "$HOME/.config"
  git clone https://github.com/seeger22/kickstart.nvim.git "$HOME/.config/nvim"
fi

# Install plugins headlessly (lazy.nvim auto-bootstraps, then installs all plugins)
echo "Installing plugins..."
nvim --headless +q 2>/dev/null || true
# Run again to let treesitter parsers compile
nvim --headless +"sleep 15" +q 2>/dev/null || true

# Shell config
if ! grep -q 'EDITOR=nvim' "$HOME/.zshenv" 2>/dev/null && \
   ! grep -q 'EDITOR=nvim' "$HOME/.bashrc" 2>/dev/null; then
  SHELL_RC="$HOME/.bashrc"
  [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"
  echo 'export EDITOR=nvim' >> "$SHELL_RC"
  echo 'export VISUAL=nvim' >> "$SHELL_RC"
  echo "Added EDITOR=nvim to $SHELL_RC"
fi

echo ""
echo "=== Done ==="
echo "Run 'nvim' to start. First launch may take a moment to finish plugin setup."
