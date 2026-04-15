# kickstart.nvim

Personal fork of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with custom plugins and config.

## Quick Setup (Ubuntu)

One-liner to install neovim + this config from scratch:

```bash
curl -fsSL https://raw.githubusercontent.com/seeger22/kickstart.nvim/master/setup.sh | bash
```

Or step by step:

```bash
git clone https://github.com/seeger22/kickstart.nvim.git ~/.config/nvim
cd ~/.config/nvim
bash setup.sh
```

## What's Included

Plugins:
- **oil.nvim** - file explorer (replaces netrw, open with `-`)
- **snacks.nvim** - image viewer (kitty graphics protocol)
- **smear-cursor.nvim** - cursor animations
- **telescope** - fuzzy finder
- **treesitter** - syntax highlighting
- **LSP** - language server support
- **gitsigns** - git integration

Custom config:
- Nerd Font enabled, relative line numbers, arrow keys disabled
- CSV files auto-open with `csvlens`
- Image re-render fix for tmux
- `<leader>yp` to yank file path
- `<leader>o` to open file in native program (from oil)
- `<leader>y` to copy file path (from oil)
- `<C-s>` to open in vertical split (from oil)

## Requirements

- Ubuntu (setup script uses apt)
- A terminal with kitty graphics protocol support (ghostty, kitty, wezterm) for images
- A [Nerd Font](https://www.nerdfonts.com/) installed in your terminal
