-- Minimal neovim config: Tokyo Night + sane defaults. Deliberately small.
-- Uses nvim 0.12's built-in vim.pack rather than lazy.nvim -- for a single
-- plugin it removes an entire dependency and its bootstrap block.
-- If vim.pack ever misbehaves, lazy.nvim is the drop-in fallback.

vim.g.mapleader = " "
vim.o.termguicolors = true

vim.pack.add({ "https://github.com/folke/tokyonight.nvim" })

require("tokyonight").setup({
  style = "night",
  -- transparent=true makes nvim use the TERMINAL's background. Without it,
  -- opening a file paints an opaque rectangle inside the 0.93-transparent
  -- window. Same rule as fzf bg:-1, btop theme_background, tmux bg=default.
  transparent = true,
  styles = { sidebars = "transparent", floats = "transparent" },
})
vim.cmd.colorscheme("tokyonight-night")

-- Defaults worth having; not an IDE.
vim.o.number         = true
vim.o.relativenumber = true
vim.o.signcolumn     = "yes"
vim.o.cursorline     = true
vim.o.expandtab      = true
vim.o.shiftwidth     = 4
vim.o.tabstop        = 4
vim.o.smartindent    = true
vim.o.ignorecase     = true
vim.o.smartcase      = true
vim.o.undofile       = true
vim.o.scrolloff      = 6
vim.o.clipboard      = "unnamedplus"   -- shares the Wayland clipboard
vim.o.splitright     = true
vim.o.splitbelow     = true

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
