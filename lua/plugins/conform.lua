-- conform.nvim: format-on-save + per-filetype formatters + toggles.

vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    if vim.g.format_on_save == false then return nil end
    if vim.b[bufnr].format_on_save == false then return nil end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
  default_format_opts = { lsp_format = 'fallback' },
  formatters_by_ft = {
    python = { 'ruff_organize_imports', 'ruff_format' },
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    css = { 'prettierd', 'prettier', stop_after_first = true },
    scss = { 'prettierd', 'prettier', stop_after_first = true },
    html = { 'prettierd', 'prettier', stop_after_first = true },
    json = { 'prettierd', 'prettier', stop_after_first = true },
    jsonc = { 'prettierd', 'prettier', stop_after_first = true },
    yaml = { 'prettierd', 'prettier', stop_after_first = true },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    lua = { 'stylua' },
  },
}

-- Manual format
vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })

-- Global format-on-save toggle
vim.keymap.set('n', '<leader>tF', function()
  if vim.g.format_on_save == false then
    vim.g.format_on_save = nil
    vim.notify('format-on-save: ON (global)', vim.log.levels.INFO)
  else
    vim.g.format_on_save = false
    vim.notify('format-on-save: OFF (global)', vim.log.levels.WARN)
  end
end, { desc = '[T]oggle format-on-save (global)' })

-- Buffer-local format-on-save toggle
vim.keymap.set('n', '<leader>bf', function()
  if vim.b.format_on_save == false then
    vim.b.format_on_save = nil
    vim.notify('format-on-save: ON (buffer)', vim.log.levels.INFO)
  else
    vim.b.format_on_save = false
    vim.notify('format-on-save: OFF (buffer)', vim.log.levels.WARN)
  end
end, { desc = '[B]uffer format-on-save toggle' })
