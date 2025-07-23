-- Neovim Configuration
-- ~/.config/nvim/init.lua

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.mouse = "a"

-- Leader key
vim.g.mapleader = " "

-- Basic keymaps
vim.keymap.set("n", "<leader>e", ":terminal yazi<CR>", { desc = "Open Yazi file manager" })
vim.keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Open terminal" })
vim.keymap.set("n", "<leader>gg", ":terminal gitui<CR>", { desc = "Open GitUI" })
vim.keymap.set("n", "<leader>lg", ":terminal lazygit<CR>", { desc = "Open LazyGit" })

-- File navigation with modern tools
vim.keymap.set("n", "<leader>ff", ":terminal fd . | fzf<CR>", { desc = "FZF file finder" })
vim.keymap.set("n", "<leader>fg", ":terminal rg . | fzf<CR>", { desc = "FZF grep" })
vim.keymap.set("n", "<leader>fb", ":terminal git branch | fzf<CR>", { desc = "FZF git branches" })

-- System monitoring shortcuts
vim.keymap.set("n", "<leader>sm", ":terminal btm<CR>", { desc = "System monitor" })
vim.keymap.set("n", "<leader>sp", ":terminal procs<CR>", { desc = "Process viewer" })

-- Terminal integration
vim.keymap.set("n", "<leader>tt", ":terminal<CR>", { desc = "Open terminal" })
vim.keymap.set("n", "<leader>tz", ":terminal zellij<CR>", { desc = "Open zellij" })

-- File managers
vim.keymap.set("n", "<leader>br", ":terminal broot<CR>", { desc = "Open broot" })

-- Yazi integration with directory change
vim.keymap.set("n", "<leader>f", function()
  local current_file = vim.fn.expand("%:p")
  if current_file ~= "" then
    vim.cmd("terminal yazi " .. vim.fn.shellescape(vim.fn.expand("%:p:h")))
  else
    vim.cmd("terminal yazi")
  end
end, { desc = "Open Yazi in current directory" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Resize window up" })
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Resize window down" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Resize window left" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Resize window right" })

-- Save and quit shortcuts
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", ":x<CR>", { desc = "Save and quit" })

-- Search and replace
vim.keymap.set("n", "<leader>s", ":%s/", { desc = "Search and replace" })
vim.keymap.set("v", "<leader>s", ":s/", { desc = "Search and replace selection" })

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlighting" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

-- Remove whitespace on save
autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    pcall(function() vim.cmd([[%s/\s\+$//e]]) end)
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Basic colorscheme (fallback)
vim.cmd.colorscheme("default")