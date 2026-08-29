local lifecycle = require('lib.devcontainer.lifecycle')

local M = {}

function M.setup()
  vim.keymap.set('n', '<leader>cu', lifecycle.up, { desc = '[C]ontainer [u]p (devcontainer up)' })
  vim.keymap.set('n', '<leader>cd', lifecycle.down, { desc = '[C]ontainer [d]own' })
  vim.keymap.set('n', '<leader>cb', function() lifecycle.up { rebuild = true } end, { desc = '[C]ontainer [b]uild (rebuild)' })
  vim.keymap.set('n', '<leader>ce', lifecycle.exec, { desc = '[C]ontainer [e]xec (shell)' })
  vim.keymap.set('n', '<leader>cl', lifecycle.logs, { desc = '[C]ontainer [l]ogs' })
  vim.keymap.set('n', '<leader>cs', lifecycle.status, { desc = '[C]ontainer [s]tatus' })
  vim.keymap.set('n', '<leader>cr', lifecycle.ready, { desc = '[C]ontainer [r]eady (up + bridge LSP)' })
end

return M
