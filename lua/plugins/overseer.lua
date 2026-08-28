-- Overseer: task runner (reads .vscode/tasks.json).
vim.pack.add { 'https://github.com/stevearc/overseer.nvim' }

require('overseer').setup {
  task_list = {
    direction = 'bottom',
    max_height = { 0.4 },
    min_height = 15,
  },
  output = { use_terminal = true },
  component_aliases = {
    default = {
      'on_exit_set_status',
      'on_complete_notify',
      { 'on_complete_dispose', require_view = { 'SUCCESS', 'FAILURE' } },
      { 'open_output', on_start = 'always', direction = 'horizontal', focus = true },
    },
    default_vscode = {
      'default',
      'on_result_diagnostics',
    },
  },
}

vim.keymap.set('n', '<leader>or', '<Cmd>OverseerRun<CR>', { desc = '[O]verseer [r]un task' })
vim.keymap.set('n', '<leader>oo', '<Cmd>OverseerToggle<CR>', { desc = '[O]verseer [o]utput toggle' })
vim.keymap.set('n', '<leader>oa', '<Cmd>OverseerShell<CR>', { desc = '[O]verseer run [a]rbitrary command' })
