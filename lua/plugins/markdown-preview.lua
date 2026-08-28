-- markdown-preview.nvim: :MarkdownPreview opens a browser preview.
vim.pack.add { { src = 'https://github.com/iamcco/markdown-preview.nvim' } }

vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0

vim.keymap.set('n', '<leader>mp', '<Cmd>MarkdownPreview<CR>', { desc = '[M]arkdown [P]review' })
vim.keymap.set('n', '<leader>mP', '<Cmd>MarkdownPreviewStop<CR>', { desc = '[M]arkdown preview stop' })
