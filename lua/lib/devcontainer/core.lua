local M = {}

M.state = {
  root = nil, -- host path containing .devcontainer/
  container_id = nil, -- cached container ID
  service = nil, -- docker-compose service name
  compose_file = nil, -- absolute path to docker-compose.yml
  workspace_folder = nil, -- container workspaceFolder
  remote_user = nil, -- remoteUser from devcontainer.json
}

--- @return string|nil root host path containing .devcontainer/
function M.find_root(bufnr)
  bufnr = bufnr or 0
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then path = vim.fn.getcwd() end
  if path == '' then return nil end
  local function check(dir) return vim.uv.fs_stat(vim.fs.joinpath(dir, '.devcontainer', 'devcontainer.json')) ~= nil end
  if check(path) then return path end
  for dir in vim.fs.parents(path) do
    if check(dir) then return dir end
    if dir == vim.env.HOME then break end
  end
  return nil
end

--- @return boolean
function M.has_devcontainer(project_path)
  if vim.uv.fs_stat(vim.fs.joinpath(project_path, '.devcontainer', 'devcontainer.json')) then return true end
  for name, type in vim.fs.dir(project_path) do
    if type == 'directory' then
      if vim.uv.fs_stat(vim.fs.joinpath(project_path, name, '.devcontainer', 'devcontainer.json')) then return true end
    end
  end
  return false
end

--- @return table|nil cfg
function M.parse_config(root)
  local json_path = vim.fs.joinpath(root, '.devcontainer', 'devcontainer.json')
  local f = io.open(json_path, 'r')
  if not f then return nil end
  local data = f:read '*a'
  f:close()
  data = data:gsub('//[^\n]*', ''):gsub('/%*.-%*/', ''):gsub(',%s*([}%]])', '%%1')
  local ok, cfg = pcall(vim.fn.json_decode, data)
  if not ok or type(cfg) ~= 'table' then return nil end
  return cfg
end

--- @return boolean ok
function M.init_state(root)
  local cfg = M.parse_config(root)
  if not cfg then return false end
  M.state.root = root
  M.state.service = cfg.service or 'devcontainer'
  local compose_rel = cfg.dockerComposeFile or 'docker-compose.yml'
  if type(compose_rel) == 'table' then compose_rel = compose_rel[1] end
  M.state.compose_file = vim.fs.joinpath(root, '.devcontainer', compose_rel)
  M.state.workspace_folder = cfg.workspaceFolder or '/workspace'
  M.state.remote_user = cfg.remoteUser
  M.state.container_id = nil
  return true
end

function M.resolve_container()
  if M.state.container_id then
    local r = vim.system({ 'docker', 'inspect', '-f', '{{.State.Running}}', M.state.container_id }):wait()
    if r.stdout and r.stdout:match 'true' then return M.state.container_id end
    M.state.container_id = nil
  end
  if not M.state.service then return nil end
  local r = vim
    .system({
      'docker',
      'ps',
      '-q',
      '--filter',
      'status=running',
      '--filter',
      'label=com.docker.compose.service=' .. M.state.service,
    })
    :wait()
  local out = (r.stdout or ''):gsub('%s+$', '')
  if out == '' then return nil end
  M.state.container_id = out:match '^(%w+)'
  return M.state.container_id
end

function M.is_active(bufnr)
  local root = M.find_root(bufnr)
  if not root then return false end
  if not M.state.root or M.state.root ~= root then
    if not M.init_state(root) then return false end
  end
  return M.resolve_container() ~= nil
end

return M
