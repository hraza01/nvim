-- Core Neovim options.
-- Loaded first by init.lua — before any plugins.
vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Mouse
vim.o.mouse = 'a'

vim.o.showmode = false

-- OS clipboard sync (scheduled to avoid slowing startup)
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Editing
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true

-- Whitespace visibility
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Live substitution preview
vim.o.inccommand = 'split'

-- Cursor line + scroll padding
vim.o.cursorline = true
vim.o.scrolloff = 10

-- Prompt instead of failing on unsaved changes
vim.o.confirm = true

-- Per-project config (`.nvim.lua` / `.exrc`). `secure` prompts before
-- running shell/autocmd commands from those files.
vim.o.exrc = true
vim.o.secure = true

-- Auto-reload files changed outside nvim (e.g. by opencode). Pairs with the
-- `checktime` autocmd in autocmds.lua.
vim.o.autoread = true

-- Folds: native treesitter folding (enabled per-buffer in plugins/treesitter.lua).
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Session options for `:restart` / `:mksession`. 'buffers' and 'blank' are
-- removed because oil buffers (buftype=acwrite) get saved by name and cause
-- E95 on restore (oil re-creates the buffer before the session tries to name it).
vim.o.sessionoptions = 'curdir,folds,help,tabpages,winsize,terminal'
