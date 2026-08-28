-- Non-plugin autocmds + diagnostic config.
-- Plugin-specific autocmds live in their respective `lua/plugins/*.lua` files.

-- Diagnostic appearance & behavior
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false }
    end,
  },
}

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Live external updates: poll for file changes (opencode/CLI editing the same
-- file). `autoread` (options.lua) silently reloads unchanged buffers; `confirm`
-- prompts when there are unsaved edits.
vim.api.nvim_create_autocmd(
  { 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' },
  { desc = 'Check for file changes (opencode live updates)', command = 'checktime' }
)
