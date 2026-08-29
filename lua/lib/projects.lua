-- Project switcher. Native, no plugin.
--
-- `<leader>pp` opens a Telescope picker over `~/dev/*` (recent-first); `<leader>pf`
-- lists them alphabetically. Includes top-level dirs plus any nested dir
-- containing `.vscode/tasks.json`. Selecting one `cd`s into it, clears buffers,
-- and opens the project in oil. Records the project as most-recent in
-- `~/.local/state/nvim/projects-history.json`.

local M = {}

local function dev_root() return vim.fs.joinpath(vim.env.HOME, 'dev') end
local function history_path() return vim.fs.joinpath(vim.fn.stdpath 'state', 'projects-history.json') end

local function load_history()
  local f = io.open(history_path(), 'r')
  if not f then return {} end
  local data = f:read '*a'
  f:close()
  local ok, tbl = pcall(vim.fn.json_decode, data)
  return ok and type(tbl) == 'table' and tbl or {}
end

local function save_history(order)
  vim.fn.mkdir(vim.fn.stdpath 'state', 'p')
  local f = io.open(history_path(), 'w')
  if not f then return end
  f:write(vim.fn.json_encode(order))
  f:close()
end

-- Move `name` to front of history (most-recent), capped at 50.
local function record(name)
  local order = load_history()
  for i, n in ipairs(order) do
    if n == name then
      table.remove(order, i)
      break
    end
  end
  table.insert(order, 1, name)
  while #order > 50 do
    table.remove(order)
  end
  save_history(order)
end

-- Pruned during scan to avoid descending into heavy/vendored trees.
local PRUNE_DIRS = {
  ['.git'] = true, ['.hg'] = true, ['node_modules'] = true, ['.venv'] = true,
  ['venv'] = true, ['__pycache__'] = true, ['.cache'] = true, ['.tox'] = true,
  ['.pytest_cache'] = true, ['.mypy_cache'] = true, ['.ruff_cache'] = true,
  ['dist'] = true, ['build'] = true, ['target'] = true, ['.next'] = true,
  ['.terraform'] = true, ['.idea'] = true, ['.vscode'] = true,
}

-- Max scan depth under `~/dev` for `.vscode/tasks.json`.
local MAX_SCAN_DEPTH = 5

---Find directories under `root` (up to MAX_SCAN_DEPTH) containing
---`.vscode/tasks.json`.
---@param root string absolute path to scan from
---@return string[] absolute paths of project roots
local function find_task_roots(root)
  local results = {}
  local function walk(dir, depth)
    if depth > MAX_SCAN_DEPTH then return end
    for name, type in vim.fs.dir(dir) do
      if type == 'directory' and not PRUNE_DIRS[name] then
        local child = vim.fs.joinpath(dir, name)
        if vim.uv.fs_stat(vim.fs.joinpath(child, '.vscode', 'tasks.json')) then
          table.insert(results, child)
        end
        walk(child, depth + 1)
      end
    end
  end
  walk(root, 1)
  return results
end

---List projects under `~/dev`: top-level dirs plus nested dirs containing
---`.vscode/tasks.json` (named by path relative to `~/dev`).
---`{ name = , path = , rank = }` where `rank` is the 1-based position in
---history (1 = most recent; nil = never opened).
---@return {name:string, path:string, rank:integer?}[]
function M.list_projects()
  local order = load_history()
  local rank = {}
  for i, n in ipairs(order) do
    rank[n] = i
  end
  local projects = {}
  local seen = {}
  local root = dev_root()

  local function add(path, name)
    if seen[path] then return end
    seen[path] = true
    table.insert(projects, { name = name, path = path, rank = rank[name] })
  end

  -- Top-level ~/dev/* directories.
  for name, type in vim.fs.dir(root) do
    if type == 'directory' then
      add(vim.fs.joinpath(root, name), name)
    end
  end

  -- Nested roots containing .vscode/tasks.json (named relative to ~/dev).
  for _, path in ipairs(find_task_roots(root)) do
    local rel = path:sub(#root + 2) -- strip "<root>/" prefix
    add(path, rel)
  end
  return projects
end

---`cd` into `~/dev/<name>`, clear buffers, and open the project directory in
---oil so its contents are visible immediately. Records the project as most-recent.
---@param name string
function M.switch(name)
  local path = vim.fs.joinpath(dev_root(), name)
  if vim.fn.isdirectory(path) == 0 then
    vim.notify('No such project: ' .. name, vim.log.levels.ERROR)
    return
  end
  vim.cmd('cd ' .. vim.fn.fnameescape(path))
  -- Start fresh: drop every buffer (force; switching projects is intentional),
  -- then open the project directory in oil (oil intercepts `:edit <dir>` as
  -- the netrw replacement) so its contents are visible immediately.
  pcall(vim.cmd, '%bdelete!')
  vim.cmd('edit ' .. vim.fn.fnameescape(path))
  record(name)
  vim.notify('project: ' .. name, vim.log.levels.INFO)
end

local function open_picker(opts)
  opts = opts or {}
  local projects = M.list_projects()
  if #projects == 0 then
    vim.notify('No projects under ' .. dev_root(), vim.log.levels.WARN)
    return
  end
  if opts.recent_first then
    table.sort(projects, function(a, b)
      if a.rank and b.rank then return a.rank < b.rank end
      if a.rank then return true end
      if b.rank then return false end
      return a.name < b.name
    end)
  else
    table.sort(projects, function(a, b) return a.name < b.name end)
  end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local actions = require 'telescope.actions'
  local state = require 'telescope.actions.state'
  local conf = require 'telescope.config'.values

  pickers
    .new({}, {
      prompt_title = opts.recent_first and 'Projects (recent)' or 'Projects (all)',
      finder = finders.new_table {
        results = projects,
        entry_maker = function(p)
          local dc = require('lib.devcontainer').has_devcontainer(p.path)
          local display = dc and ('🐳 ' .. p.name) or p.name
          return { value = p.name, display = display, ordinal = p.name, path = p.path }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then M.switch(entry.value) end
        end)
        return true
      end,
    })
    :find()
end

vim.keymap.set('n', '<leader>pp', function() open_picker { recent_first = true } end, { desc = '[P]roject [p]icker (recent)' })
vim.keymap.set('n', '<leader>pf', function() open_picker { recent_first = false } end, { desc = '[P]roject [f]ind all' })

return M
