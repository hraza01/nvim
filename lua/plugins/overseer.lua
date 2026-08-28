-- Overseer: task runner (reads .vscode/tasks.json).
vim.pack.add { 'https://github.com/stevearc/overseer.nvim' }

require('overseer').setup {}

vim.keymap.set('n', '<leader>or', '<Cmd>OverseerRun<CR>', { desc = '[O]verseer [r]un task' })
vim.keymap.set('n', '<leader>oo', '<Cmd>OverseerToggle<CR>', { desc = '[O]verseer [o]utput toggle' })
vim.keymap.set('n', '<leader>oa', '<Cmd>OverseerShell<CR>', { desc = '[O]verseer run [a]rbitrary command' })
