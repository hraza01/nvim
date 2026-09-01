-- Non-plugin keymaps. Plugin-specific keymaps live in their respective
-- `lua/plugins/*.lua` files. Loaded after options, before plugins.

-- Clear search highlights on <Esc>
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic quickfix
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation: <C-hjkl>
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })

-- Vertical split
vim.keymap.set('n', '<leader>\\', vim.cmd.vsplit, { desc = 'Vertical split' })
-- Horizontal split
vim.keymap.set('n', '<leader>_', vim.cmd.split, { desc = 'Horizontal split' })

-- Disable ex mode
vim.keymap.set('n', 'Q', '<nop>')

-- <leader> = <Nop> so it doesn't move the cursor
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Centered scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', 'J', 'mzJ`z')

-- Move selected lines up/down (visual mode)
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Black-hole delete (don't yank on d/p)
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d')
vim.keymap.set('x', '<leader>p', '"_dP')

-- Word-wrap-aware j/k
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Folding (treesitter folds enabled in plugins/treesitter.lua)
vim.keymap.set('n', '<leader>z', 'za', { desc = '[Z]old: toggle under cursor' })
vim.keymap.set('n', '<leader>Z', function()
  if vim.wo.foldlevel == 0 then
    vim.cmd 'normal! zR'
  else
    vim.cmd 'normal! zM'
  end
end, { desc = '[Z]old: toggle all (zR/zM)' })
vim.keymap.set('n', '<leader>zM', 'zM', { desc = '[Z]old: collapse all (present mode)' })

-- Comment toggle (mini.comment)
vim.keymap.set('n', '<leader>/', 'gcc', { remap = true, desc = 'Toggle comment' })
vim.keymap.set('x', '<leader>/', 'gc', { remap = true, desc = 'Toggle comment' })
