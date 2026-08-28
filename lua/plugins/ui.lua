-- UI & core UX: guess-indent, which-key, colorscheme, todo-comments,
-- mini.nvim modules (ai, surround, comment), lualine.

vim.pack.add {
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/Mofiqul/vscode.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-lualine/lualine.nvim',
}

require('guess-indent').setup {}

require('which-key').setup {
  delay = 1250,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { '<leader>g', group = '[G]it' },
    { '<leader>p', group = '[P]roject' },
    { '<leader>o', group = '[O]verseer' },
    { '<leader>v', group = '[V]env' },
    { '<leader>m', group = '[M]arkdown' },
    { '<leader>z', group = '[Z]olds' },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}

require('vscode').setup {
  transparent = true,
  italic_comments = false,
}
vim.cmd.colorscheme 'vscode'

require('todo-comments').setup { signs = false }

if vim.g.have_nerd_font then
  require('mini.icons').setup()
  MiniIcons.mock_nvim_web_devicons()
end

require('mini.ai').setup {
  mappings = { around_next = 'aa', inside_next = 'ii' },
  n_lines = 500,
}

require('mini.surround').setup()

require('mini.comment').setup()

require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'vscode',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = { statusline = {}, winbar = {} },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = true,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
      refresh_time = 16,
      events = {
        'WinEnter', 'BufEnter', 'BufWritePost', 'SessionLoadPost',
        'FileChangedShellPost', 'VimResized', 'Filetype',
        'CursorMoved', 'CursorMovedI', 'ModeChanged',
      },
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { { 'branch', icon = '' }, { 'diagnostics', sources = { 'nvim_lsp' } } },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', { 'filetype', icons_enabled = false } },
    lualine_y = {},
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
}
