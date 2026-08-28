-- oil.nvim: edit the filesystem like a buffer. Primary file explorer.

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add { { src = 'https://github.com/stevearc/oil.nvim', version = vim.version.range '*' } }

require('oil').setup { view_options = { show_hidden = true } }

vim.keymap.set('n', '-', function() require('oil').open() end, { desc = 'Oil: open parent dir' })
vim.keymap.set('n', '<leader>-', function() require('oil').open_float() end, { desc = 'Oil: floating explorer' })
