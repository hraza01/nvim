-- LSP: nvim-lspconfig + Mason + servers + fidget + LspAttach keymaps/highlight/inlay.

vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/j-hui/fidget.nvim',
}

require('fidget').setup {}
require('mason').setup {}
require('mason-lspconfig').setup { automatic_enable = false }

-- Language server configs. `pythonPath` for basedpyright is overridden
-- dynamically by lib/venv.lua (via vim.lsp.config deep-merge) when a .venv is
-- found. See `:help lsp-config`.
---@type table<string, vim.lsp.Config>
local servers = {
  stylua = {},
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end
      local current = client.config.settings --[[@as lspconfig.settings.lua_ls]]
      client.config.settings.Lua = vim.tbl_deep_extend('force', current.Lua, {
        runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
        workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file('', true) },
      })
    end,
    settings = { Lua = { format = { enable = false } } },
  },
  basedpyright = {
    settings = {
      python = {
        pythonPath = 'python3',
        analysis = { typeCheckingMode = 'standard', autoSearchPaths = true, useLibraryCodeForTypes = true },
      },
    },
  },
  ruff = {},
  ts_ls = {},
  gopls = {},
  html = {},
  cssls = {},
  tailwindcss = {},
  sqls = {},
  dockerls = {},
  jsonls = {},
  yamlls = {},
}

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, { 'prettierd' })
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

-- Buffer-local LSP keymaps + reference highlighting on attach.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- Telescope LSP pickers
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })

    -- Reference highlighting
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local hl = vim.api.nvim_create_augroup('lsp-highlight-' .. buf, { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = buf, group = hl, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = buf, group = hl, callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(e2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'lsp-highlight-' .. e2.buf, buffer = e2.buf }
        end,
      })
    end

    -- Inlay hints toggle
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
    end
  end,
})
