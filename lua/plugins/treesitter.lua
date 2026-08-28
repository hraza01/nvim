-- Treesitter: parsers, highlighting, native folds, indentation.

vim.pack.add { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } }

-- Pre-warm common parsers; filetypes not listed here are still auto-installed
-- on first open by the FileType autocmd below.
local parsers = {
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline',
  'query', 'vim', 'vimdoc',
  'python', 'javascript', 'typescript', 'tsx', 'jsdoc',
  'go', 'gomod', 'gosum',
  'css', 'scss',
  'json', 'yaml', 'toml',
  'dockerfile', 'sql', 'jinja', 'regex',
}
require('nvim-treesitter').install(parsers)

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  if not vim.treesitter.language.add(language) then return end
  vim.treesitter.start(buf, language)

  -- Native treesitter folds (no nvim-ufo)
  vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.wo.foldmethod = 'expr'

  local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
  if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available_parsers = require('nvim-treesitter').get_available()
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
  callback = function(args)
    local buf, filetype = args.buf, args.match
    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    local installed = require('nvim-treesitter').get_installed 'parsers'
    if vim.tbl_contains(installed, language) then
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      treesitter_try_attach(buf, language)
    end
  end,
})
