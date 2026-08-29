local core = require('lib.devcontainer.core')
local M = {}

M.original_pyright = nil
M.lsp_bridged = false

local function detect_bench_python(bufnr)
  if vim.g.devcontainer_python_path then return vim.g.devcontainer_python_path end
  bufnr = bufnr or 0
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then path = vim.fn.getcwd() end
  local function check_env(dir)
    local env_dir = vim.fs.joinpath(dir, 'env', 'bin')
    return vim.uv.fs_lstat(env_dir) ~= nil
  end
  if check_env(path) then return vim.fs.joinpath(path, 'env', 'bin', 'python') end
  for dir in vim.fs.parents(path) do
    if check_env(dir) then return vim.fs.joinpath(dir, 'env', 'bin', 'python') end
    if dir == vim.env.HOME then break end
  end
  return nil
end

function M.configure_lsp()
  local root = core.find_root(0)
  if not root or not core.init_state(root) then
    M.restore_lsp()
    return
  end
  local id = core.resolve_container()
  if not id then
    M.restore_lsp()
    return
  end

  if not M.original_pyright then
    local current = vim.lsp.config['pyright'] or {}
    M.original_pyright = {}
    for k, v in pairs(current) do
      M.original_pyright[k] = v
    end
  end

  local container_python = detect_bench_python(0)

  local cmd = { 'docker', 'exec', '-i' }
  if core.state.workspace_folder then
    table.insert(cmd, '-w')
    table.insert(cmd, core.state.workspace_folder)
  end
  if core.state.remote_user then
    table.insert(cmd, '-u')
    table.insert(cmd, core.state.remote_user)
  end
  table.insert(cmd, id)
  table.insert(cmd, 'pyright-langserver')
  table.insert(cmd, '--stdio')

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.workspace = capabilities.workspace or {}
  capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }

  vim.lsp.config('pyright', {
    cmd = cmd,
    capabilities = capabilities,
    before_init = function(init_params, config) init_params.processId = vim.NIL end,
    root_dir = function(bufnr, on_dir)
      local path = vim.api.nvim_buf_get_name(bufnr)
      if path == '' then path = vim.fn.getcwd() end
      local markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'pyrightconfig.json', 'Pipfile' }
      for dir in vim.fs.parents(path) do
        for _, marker in ipairs(markers) do
          if vim.uv.fs_stat(vim.fs.joinpath(dir, marker)) then
            on_dir(dir)
            return
          end
        end
        if dir == root then
          on_dir(dir)
          return
        end
        if dir == vim.env.HOME then break end
      end
      on_dir(root)
    end,
    settings = {
      python = {
        pythonPath = container_python,
        analysis = (M.original_pyright.settings or {}).python and (M.original_pyright.settings.python).analysis or {
          typeCheckingMode = 'off',
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  })

  M.lsp_bridged = true
  vim.notify('LSP bridged to container: ' .. id:sub(1, 12), vim.log.levels.INFO)
end

function M.restore_lsp()
  if not M.lsp_bridged then return end
  if M.original_pyright then vim.lsp.config('pyright', M.original_pyright) end
  M.lsp_bridged = false
  for _, client in ipairs(vim.lsp.get_clients { name = 'pyright' }) do
    client:stop(true)
  end
end

return M
