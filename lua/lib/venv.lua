-- Native Python virtualenv activation. No plugin.
--
-- On entering a Python buffer (and once at VimEnter, from the cwd) we walk up
-- to find a `.venv`/`venv` directory and:
--   * set `vim.g.python3_host_prog` to the venv's python (used by Neovim's own
--     python3 host and by `:terminal`-aware tooling);
--   * point pyright at the venv's python via `vim.lsp.config`
--     (which deep-merges, so the server's other settings — e.g. `analysis.*`
--     set in plugins/lsp.lua — are preserved);
--   * restart any pyright-family client already running so it re-indexes
--     against the venv's site-packages.
-- Terminals opened inside a project that has a venv get a best-effort
-- `source <venv>/bin/activate`. `:VenvSelect` and `<leader>va`/`<leader>vs`
-- round it out. See `:help vim.lsp.config` for the merge semantics.

local M = {}

local VENV_NAMES = { '.venv', 'venv', '.env', 'env' }
local PYRIGHT_SERVERS = { 'pyright' }
local NOTIFY_TIMEOUT_MS = 5000

local function py_bin(venv) return vim.fs.joinpath(venv, 'bin', 'python') end

-- `.env`/`env` collide with the common convention of a `.env` *file* holding
-- shell/environment variables (dotenv). Require the candidate to actually be
-- a directory before probing it for `bin/python`, so a `.env` file is never
-- mistaken for a venv.
local function is_venv_dir(venv)
  local stat = vim.uv.fs_stat(venv)
  return stat ~= nil and stat.type == 'directory' and vim.uv.fs_stat(py_bin(venv)) ~= nil
end

-- Like vim.notify, but the message clears itself from the cmdline area after
-- NOTIFY_TIMEOUT_MS instead of sitting there until overwritten by the next
-- message or a `:` command. `history = false` on the follow-up echo means it
-- doesn't leave a blank entry in `:messages`.
local function notify_transient(msg, level)
  vim.notify(msg, level)
  vim.defer_fn(function() vim.api.nvim_echo({ { '', 'None' } }, false, {}) end, NOTIFY_TIMEOUT_MS)
end

--- @param bufnr? integer
--- @return string|nil
function M.find_venv(bufnr)
  bufnr = bufnr or 0
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then path = vim.fn.getcwd() end
  if path == '' then return nil end
  for dir in vim.fs.parents(path) do
    for _, name in ipairs(VENV_NAMES) do
      local venv = vim.fs.joinpath(dir, name)
      if is_venv_dir(venv) then return venv end
    end
    if dir == vim.env.HOME then break end
  end
  return nil
end

--- @param venv string
--- @return boolean ok
function M.activate_path(venv)
  if not venv or not vim.uv.fs_stat(py_bin(venv)) then return false end
  vim.g.python3_host_prog = py_bin(venv)
  for _, name in ipairs(PYRIGHT_SERVERS) do
    vim.lsp.config(name, { settings = { python = { pythonPath = vim.g.python3_host_prog } } })
  end
  local to_restart = false
  for _, name in ipairs(PYRIGHT_SERVERS) do
    for _, client in ipairs(vim.lsp.get_clients { name = name }) do
      client:stop(true)
      to_restart = true
    end
  end
  if to_restart then
    -- Re-fire FileType on python buffers so `vim.lsp.enable` re-attaches a
    -- fresh client with the updated config.
    vim.defer_fn(function()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].filetype == 'python' then
          pcall(vim.api.nvim_exec_autocmds, 'FileType', { buffer = b, modeline = false })
        end
      end
    end, 50)
  end
  return true
end

--- @param bufnr? integer
--- @return string|nil venv
function M.activate(bufnr)
  bufnr = bufnr or 0
  local venv = M.find_venv(bufnr)
  if not venv then return nil end
  if not M.activate_path(venv) then return nil end
  vim.b[bufnr].venv_activated = venv
  notify_transient('venv: ' .. (vim.fs.relpath(vim.env.HOME, venv) or venv), vim.log.levels.INFO)
  return venv
end

--- Name for statusline display: the directory the venv lives in (i.e. the
--- project name), not the venv's own path. Only shown for python buffers,
--- even though venv_activated can technically be set on any buffer (e.g. via
--- `:VenvSelect` invoked from a non-python buffer).
--- @param bufnr? integer
--- @return string
function M.status(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].filetype ~= 'python' then return '' end
  local venv = vim.b[bufnr].venv_activated
  if not venv then return '' end
  return vim.fs.basename(vim.fs.dirname(venv)) or ''
end

--- @return {path: string, label: string}[]
function M.discover_venvs()
  local found, seen = {}, {}
  local function add(venv)
    if venv and not seen[venv] and is_venv_dir(venv) then
      seen[venv] = true
      table.insert(found, { path = venv, label = vim.fs.relpath(vim.env.HOME, venv) or venv })
    end
  end
  local cwd = vim.fn.getcwd()
  for _, name in ipairs(VENV_NAMES) do
    add(vim.fs.joinpath(cwd, name))
  end
  for dir in vim.fs.parents(cwd) do
    for _, name in ipairs(VENV_NAMES) do
      add(vim.fs.joinpath(dir, name))
    end
    if dir == vim.env.HOME then break end
  end
  if vim.env.WORKON_HOME and vim.uv.fs_stat(vim.env.WORKON_HOME) then
    for name in vim.fs.dir(vim.env.WORKON_HOME) do
      add(vim.fs.joinpath(vim.env.WORKON_HOME, name))
    end
  end
  table.sort(found, function(a, b) return a.label < b.label end)
  return found
end

local group = vim.api.nvim_create_augroup('lib.venv', { clear = true })

-- Seed `python3_host_prog` + pyright config from the cwd's venv at startup, so
-- the first python-buffer attach already has the right pythonPath (no
-- first-open restart needed in the common "cd into project then :e file" case).
vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  once = true,
  callback = function()
    local venv = M.find_venv(0)
    if not venv then return end
    vim.g.python3_host_prog = py_bin(venv)
    for _, name in ipairs(PYRIGHT_SERVERS) do
      vim.lsp.config(name, { settings = { python = { pythonPath = vim.g.python3_host_prog } } })
    end
  end,
})

-- Re-activate when entering a python buffer whose venv differs from the
-- active one (e.g. switching projects in one session).
-- Skipped when a devcontainer is active for this buffer (lib/devcontainer.lua
-- sets b:devcontainer_active before this autocmd fires — it loads first).
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'python',
  callback = function(args)
    if vim.b[args.buf].devcontainer_active then return end
    local venv = M.find_venv(args.buf)
    if venv and venv ~= vim.b[args.buf].venv_activated then M.activate(args.buf) end
  end,
})

-- Best-effort: source the venv in a freshly-opened terminal whose cwd has one.
-- The defer lets the shell finish booting before we `chan_send`.
vim.api.nvim_create_autocmd('TermOpen', {
  group = group,
  callback = function(args)
    local venv = M.find_venv(args.buf)
    if not venv then return end
    local ch = vim.bo[args.buf].channel
    if not ch or ch == 0 then return end
    vim.defer_fn(function() pcall(vim.api.nvim_chan_send, ch, ('source %s/bin/activate\n'):format(venv)) end, 150)
  end,
})

-- :VenvSelect — pick a discovered venv (routed through Telescope ui-select).
vim.api.nvim_create_user_command('VenvSelect', function()
  local venvs = M.discover_venvs()
  if #venvs == 0 then
    vim.notify('No virtualenvs found', vim.log.levels.WARN)
    return
  end
  vim.ui.select(venvs, {
    prompt = 'Select virtualenv',
    format_item = function(v) return v.label end,
  }, function(choice)
    if not choice then return end
    if M.activate_path(choice.path) then
      vim.b[0].venv_activated = choice.path
      notify_transient('venv: ' .. (vim.fs.relpath(vim.env.HOME, choice.path) or choice.path), vim.log.levels.INFO)
    end
  end)
end, { desc = 'Select a Python virtualenv' })

vim.keymap.set('n', '<leader>va', function()
  local venv = M.activate(0)
  if not venv then vim.notify('No venv found for this buffer', vim.log.levels.WARN) end
end, { desc = '[V]env [a]ctivate detected' })
vim.keymap.set('n', '<leader>vs', '<Cmd>VenvSelect<CR>', { desc = '[V]env [s]elect' })

return M
