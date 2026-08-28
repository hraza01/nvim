-- Git: vim-fugitive (status/blame/diff/push) + vim-rhubarb (:Gbrowse).
-- Gitsigns hunk keymaps are in gitsigns.lua.

vim.pack.add {
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/tpope/vim-rhubarb',
}

vim.keymap.set('n', '<leader>gs', '<Cmd>Git<CR>', { desc = '[G]it [s]tatus' })
vim.keymap.set('n', '<leader>gb', '<Cmd>Git blame<CR>', { desc = '[G]it [b]lame' })
vim.keymap.set('n', '<leader>gd', '<Cmd>Gvdiffsplit<CR>', { desc = '[G]it [d]iff (vsplit)' })
vim.keymap.set('n', '<leader>gl', '<Cmd>Git log --oneline -20<CR>', { desc = '[G]it [l]og (last 20)' })
vim.keymap.set('n', '<leader>gp', '<Cmd>Git push<CR>', { desc = '[G]it [p]ush' })
