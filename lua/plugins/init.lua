-- Plugin manager: vim.pack build hooks + auto-loader for lua/plugins/*.lua.
--
-- Each file in `lua/plugins/` is self-contained: it calls `vim.pack.add`,
-- `setup()`, and defines its own keymaps/autocmds. This file provides the
-- `PackChanged` build hook and iterates all plugin files.
-- `telescope.lua` is loaded first (it installs plenary.nvim, which other
-- plugins like harpoon depend on at require-time).

-- Run a build command synchronously, notifying on failure.
local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local output = (result.stderr or '') ~= '' and result.stderr or (result.stdout or '')
    if output == '' then output = 'No output from build command.' end
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

-- Run build steps after plugins are installed or updated.
-- See `:help vim.pack-events`
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pack-build-hooks', { clear = true }),
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make' }, ev.data.path)
      return
    end

    if name == 'LuaSnip' and vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make', 'install_jsregexp' }, ev.data.path)
      return
    end

    if name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
      return
    end

    if name == 'markdown-preview.nvim' then
      if not ev.data.active then vim.cmd.packadd 'markdown-preview.nvim' end
      vim.schedule(function() pcall(vim.fn['mkdp#util#install']) end)
      return
    end
  end,
})

-- Load telescope first (it installs plenary.nvim, which other plugins like
-- harpoon depend on at require-time).
require 'plugins.telescope'

-- Load the rest alphabetically (except init.lua and telescope.lua, already loaded).
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir, { follow = true }) do
  if (type == 'file' or type == 'link') and file_name:match '%.lua$' and file_name ~= 'init.lua' and file_name ~= 'telescope.lua' then
    local module = file_name:gsub('%.lua$', '')
    require('plugins.' .. module)
  end
end

-- Load lib modules. devcontainer must load before venv so its FileType autocmd
-- (which sets b:devcontainer_active) fires before venv.lua's (which checks it).
require 'lib.devcontainer'
require 'lib.projects'
require 'lib.venv'
