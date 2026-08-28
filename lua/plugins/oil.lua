-- oil.nvim: edit the filesystem like a buffer. Primary file explorer.

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add { { src = 'https://github.com/stevearc/oil.nvim', version = vim.version.range '*' } }

require('oil').setup { view_options = { show_hidden = true } }

vim.keymap.set('n', '-', function() require('oil').open() end, { desc = 'Oil: open parent dir' })
vim.keymap.set('n', '<leader>-', function() require('oil').open_float() end, { desc = 'Oil: floating explorer' })

-- Follow oil navigation: update cwd to the displayed directory.
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('oil-auto-cd', { clear = true }),
  pattern = 'oil:///*',
  callback = function()
    local dir = require('oil').get_current_dir()
    if dir and dir ~= vim.fn.getcwd() then
      vim.cmd('cd ' .. vim.fn.fnameescape(dir))
    end
  end,
})
