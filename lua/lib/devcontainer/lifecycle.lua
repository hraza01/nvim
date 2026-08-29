local core = require('lib.devcontainer.core')
local lsp = require('lib.devcontainer.lsp')

local M = {}

function M.up(opts)
  opts = opts or {}
  local root = core.find_root(0)
  if not root then
    vim.notify('No .devcontainer/ found for this buffer', vim.log.levels.ERROR)
    return
  end
  core.init_state(root)
  local cmd = { 'devcontainer', 'up', '--workspace-folder', root }
  if opts.rebuild then table.insert(cmd, '--remove-existing-container') end
  vim.notify('devcontainer up: building/starting...', vim.log.levels.INFO)
  vim.system(cmd, {}, function(result)
    vim.schedule(function()
      if result.code == 0 then
        core.state.container_id = nil
        local id = core.resolve_container()
        vim.notify('devcontainer up: ready' .. (id and (' (container: ' .. id:sub(1, 12) .. ')') or ''), vim.log.levels.INFO)
      else
        vim.notify('devcontainer up failed:\n' .. (result.stderr or result.stdout or ''), vim.log.levels.ERROR)
      end
    end)
  end)
end

function M.down()
  local root = core.find_root(0)
  if not root then return end
  if not core.init_state(root) then return end
  local compose_dir = vim.fs.joinpath(root, '.devcontainer')
  vim.system({ 'docker', 'compose', '-f', core.state.compose_file, 'down' }, { cwd = compose_dir }, function(result)
    if result.code ~= 0 then
      local id = core.resolve_container()
      if id then vim.system({ 'docker', 'stop', id }):wait() end
    end
    core.state.container_id = nil
    lsp.restore_lsp()
    vim.schedule(function() vim.notify('devcontainer down', vim.log.levels.INFO) end)
  end)
end

function M.exec()
  local root = core.find_root(0)
  if not root then return end
  core.init_state(root)
  local id = core.resolve_container()
  if not id then
    vim.notify('Container not running. Use <leader>cu first.', vim.log.levels.WARN)
    return
  end
  local cmd = { 'docker', 'exec', '-it' }
  if core.state.workspace_folder then
    table.insert(cmd, '-w')
    table.insert(cmd, core.state.workspace_folder)
  end
  if core.state.remote_user then
    table.insert(cmd, '-u')
    table.insert(cmd, core.state.remote_user)
  end
  table.insert(cmd, id)
  table.insert(cmd, 'bash')
  vim.cmd('split | terminal ' .. vim.fn.join(cmd))
end

function M.logs()
  local root = core.find_root(0)
  if not root then return end
  core.init_state(root)
  local compose_dir = vim.fs.joinpath(root, '.devcontainer')
  local cmd = { 'docker', 'compose', '-f', core.state.compose_file, 'logs', '-f', '--tail', '100' }
  vim.cmd('split | terminal ' .. vim.fn.join(cmd))
end

function M.status()
  local root = core.find_root(0)
  if not root then
    vim.notify('No .devcontainer/ found', vim.log.levels.WARN)
    return
  end
  core.init_state(root)
  local r = vim
    .system({
      'docker',
      'ps',
      '--format',
      'table {{.Names}}\\t{{.Status}}\\t{{.Image}}',
      '--filter',
      'label=com.docker.compose.service=' .. core.state.service,
    })
    :wait()
  local out = (r.stdout or ''):gsub('%s+$', '')
  if out == '' then
    vim.notify('No running containers for service: ' .. core.state.service, vim.log.levels.WARN)
  else
    vim.notify(out, vim.log.levels.INFO)
  end
end

function M.ready()
  local root = core.find_root(0)
  if not root then
    vim.notify('No .devcontainer/ found', vim.log.levels.ERROR)
    return
  end
  core.init_state(root)
  local cmd = { 'devcontainer', 'up', '--workspace-folder', root }
  vim.notify('devcontainer up: building/starting...', vim.log.levels.INFO)
  vim.system(cmd, {}, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify('devcontainer up failed:\n' .. (result.stderr or ''), vim.log.levels.ERROR)
        return
      end
      core.state.container_id = nil
      local id = core.resolve_container()
      if not id then
        vim.notify('Container started but ID not found', vim.log.levels.WARN)
        return
      end
      vim.notify('devcontainer ready (container: ' .. id:sub(1, 12) .. ')', vim.log.levels.INFO)
      lsp.configure_lsp()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].filetype == 'python' then
          vim.b[b].devcontainer_active = true
          for _, client in ipairs(vim.lsp.get_clients { bufnr = b, name = 'pyright' }) do
            client:stop(true)
          end
        end
      end
      vim.defer_fn(function()
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].filetype == 'python' then
            pcall(vim.api.nvim_exec_autocmds, 'FileType', { buffer = b, modeline = false })
          end
        end
      end, 200)
    end)
  end)
end

return M
