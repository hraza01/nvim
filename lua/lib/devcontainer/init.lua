-- Devcontainer lifecycle + LSP bridge.
-- Wraps `@devcontainers/cli` and proxies pyright via `docker exec`.
-- Assumes a path-equal mount in devcontainer.json.
--
-- Override container python path via `.nvim.lua`:
--   vim.g.devcontainer_python_path = '/path/to/venv/bin/python'

local core = require('lib.devcontainer.core')
local lsp = require('lib.devcontainer.lsp')
local keymaps = require('lib.devcontainer.keymaps')

local M = {}

M.has_devcontainer = core.has_devcontainer

-- Configure LSP bridge BEFORE FileType fires.
local group = vim.api.nvim_create_augroup('lib.devcontainer', { clear = true })
vim.api.nvim_create_autocmd('BufReadPre', {
  group = group,
  pattern = '*.py',
  callback = function(args)
    local root = core.find_root(args.buf)
    if not root then return end
    if not core.init_state(root) then return end
    local id = core.resolve_container()
    if id then
      lsp.configure_lsp()
      vim.b[args.buf].devcontainer_active = true
    else
      lsp.restore_lsp()
      vim.b[args.buf].devcontainer_active = nil
    end
  end,
})

keymaps.setup()

return M
