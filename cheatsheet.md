# Cheatsheet

Press `<leader>` (Space) and wait 1.25s for which-key to show all available
groups and mappings. This page is the full reference.

`<leader>` = `<Space>` throughout.

---

## Search (Telescope)

| Key | Action |
|-----|--------|
| `<C-p>` | Find files |
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep word under cursor |
| `<leader>sh` | Search help docs |
| `<leader>sk` | Search keymaps |
| `<leader>sc` | Search Ex commands |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Resume last Telescope picker |
| `<leader>s.` | Recent files |
| `<leader>s/` | Live grep in open files only |
| `<leader>sn` | Find files in neovim config |
| `<leader><leader>` | Switch open buffers |
| `<leader>sb` | Fuzzy find in current buffer |

## LSP

| Key | Action |
|-----|--------|
| `grd` | Go to definition |
| `<C-t>` | Jump back from `grd` (tag stack) |
| `grr` | Find references |
| `gri` | Go to implementation |
| `grt` | Go to type definition |
| `grD` | Go to declaration |
| `grn` | Rename symbol |
| `gra` | Code action |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `K` | Hover documentation |
| `<leader>th` | Toggle inlay hints |
| `<leader>q` | Diagnostic quickfix list |

## Git

| Key | Action |
|-----|--------|
| `<leader>gs` | Git status (fugitive) |
| `<leader>gb` | Git blame |
| `<leader>gd` | Vertical diff vs index |
| `<leader>gl` | Log (last 20, oneline) |
| `<leader>gp` | Push |
| `:Gbrowse` | Open GitHub URL for current line (rhubarb) |

## Git hunks (gitsigns)

| Key | Action |
|-----|--------|
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage entire buffer |
| `<leader>hR` | Reset entire buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hi` | Preview hunk inline |
| `<leader>hb` | Blame line (full) |
| `<leader>hd` | Diff against index |
| `<leader>hD` | Diff against last commit |
| `<leader>hq` | Quickfix — this file's hunks |
| `<leader>hQ` | Quickfix — all files' hunks |
| `<leader>tb` | Toggle inline blame |
| `<leader>tw` | Toggle word diff |
| `ih` | Select hunk (text object, visual/operator) |

## Formatting (conform.nvim)

| Key | Action |
|-----|--------|
| `<leader>f` | Format buffer (manual, async) |
| `<leader>tF` | Toggle format-on-save (global) |
| `<leader>bf` | Toggle format-on-save (this buffer only) |

Format-on-save is on by default. Formatters: ruff (Python), prettierd
(JS/TS/CSS/HTML/JSON/YAML/Markdown), stylua (Lua). SQL has no auto-formatter.

## Folding (treesitter)

| Key | Action |
|-----|--------|
| `zc` | Close fold under cursor |
| `zo` | Open fold |
| `za` | Toggle fold |
| `zR` | Open all folds |
| `zM` | Close all folds |
| `<leader>z` | Toggle fold under cursor |
| `<leader>Z` | Toggle all (smart zR/zM) |
| `<leader>zM` | Collapse all (present mode) |

Note: `zf` (manual fold) does not work — `foldmethod=expr` (treesitter) is used.

## Multi-cursor (vim-visual-multi)

| Key | Action |
|-----|--------|
| `<C-n>` | Select word + find next occurrence |
| `\A` | Select ALL occurrences (backslash then A) |
| `<M-Down>` | Add cursor on line below |
| `<M-Up>` | Add cursor on line above |
| `n` / `N` | Find next / previous occurrence |
| `]` / `[` | Goto next / previous cursor |
| `<Tab>` | Switch mode (cursor / region) |
| `q` | Skip current region (not quit!) |
| `<Esc>` | Exit multi-cursor |

If `<M-Down>`/`<M-Up>` don't work, your terminal isn't sending Meta. On iTerm2
set "Option key = Esc+". Fallback keys are commented in
`lua/plugins/multi-cursor.lua`.

## Comments

| Key | Action |
|-----|--------|
| `<leader>/` | Toggle comment — normal: current line, visual: selection |
| `gcc` | Toggle comment on current line |
| `gc` | Toggle comment on visual selection |
| `gco` | Add comment below |
| `gcO` | Add comment above |
| `gcA` | Add comment at end of line |

## File explorer (oil.nvim)

| Key | Action |
|-----|--------|
| `-` | Open parent directory |
| `<leader>-` | Floating explorer |
| `<CR>` | Enter directory / open file |
| `dd` + `:w` | Delete file |
| edit line + `:w` | Rename file |
| `g?` | Show oil keymap help |

Edit filenames as text, `:w` to apply. netrw is disabled.

## Harpoon (fast file switching)

| Key | Action |
|-----|--------|
| `<C-a>` | Add current file to harpoon list |
| `<C-e>` | Open harpoon quick menu |
| `<leader>1`–`<leader>4` | Jump to harpoon file 1–4 |

Note: `<C-a>` shadows the builtin increment-number. Change in
`lua/plugins/harpoon.lua` if needed.

## Project switcher

| Key | Action |
|-----|--------|
| `<leader>pp` | Project picker — recent-first (`~/dev/*`) |
| `<leader>pf` | Project picker — alphabetical |

Selecting a project `cd`s into it and opens its directory in oil. Recent
projects are tracked in `~/.local/state/nvim/projects-history.json`.

## Python venv

| Key | Action |
|-----|--------|
| `<leader>va` | Activate detected `.venv` / `venv` |
| `<leader>vs` | `:VenvSelect` — pick from discovered venvs |

Auto-detects `.venv`/`venv` by walking up from the buffer's path. Sets
`python3_host_prog`, configures basedpyright's `pythonPath`, and restarts the
LSP. Terminals opened in a project with a venv get `source <venv>/bin/activate`.

## Overseer (task runner)

| Key | Action |
|-----|--------|
| `<leader>or` | Run task (reads `.vscode/tasks.json`) |
| `<leader>oo` | Toggle output pane |
| `<leader>oa` | Run arbitrary shell command (`:OverseerShell`) |

## Markdown preview

| Key | Action |
|-----|--------|
| `<leader>mp` | Open browser preview |
| `<leader>mP` | Stop preview |

## Editing & navigation

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move focus to split left/down/up/right |
| `<leader>\\` | Vertical split |
| `J` (visual) | Move selected lines down |
| `K` (visual) | Move selected lines up |
| `<C-d>` / `<C-u>` | Half-page jump (centered) |
| `n` / `N` | Next / previous search (centered) |
| `<leader>d` | Delete without yanking (black-hole) |
| `<leader>p` (visual) | Paste without yanking replaced text |
| `<leader>/` | Toggle comment (see Comments above) |
| `<Esc>` | Clear search highlights |
| `<Esc><Esc>` | Exit terminal mode |
| `Q` | Disabled (ex mode) |

## Commands

| Command | What |
|---------|------|
| `:VenvSelect` | Pick a Python virtualenv |
| `:MarkdownPreview` / `:MarkdownPreviewStop` | Browser markdown preview |
| `:OverseerRun` / `:OverseerShell` / `:OverseerToggle` | Task runner |
| `:Git` / `:Git blame` / `:Gvdiffsplit` / `:Gbrowse` | Git (fugitive/rhubarb) |
| `:Oil` / `:Oil --float` | File explorer |
| `:BqRun` / `:BqSchema` / `:BqHistory` | BigQuery (BQNvim) |
| `:Mason` | Install/manage LSP servers and tools |
| `:checkhealth` | System health check |
| `:Telescope` | Open picker for any Telescope builtin |

## Per-project overrides (`.nvim.lua`)

Create a `.nvim.lua` in a project root to override settings for that project
only. `vim.o.exrc = true` enables it; `vim.o.secure = true` prompts before
running unsafe commands from those files.

```lua
-- .nvim.lua
vim.g.format_on_save = false  -- disable format-on-save for this repo
-- vim.g.python3_host_prog = '/abs/path/to/.venv/bin/python'  -- non-standard venv
-- require('conform').formatters_by_ft.python = { 'black' }  -- override formatter
```

## Plugin manager

Uses Neovim's built-in `vim.pack` (no external plugin manager).

- Inspect state: `:lua vim.pack.update(nil, { offline = true })`
- Update all: `:lua vim.pack.update()`
- Lockfile: `nvim-pack-lock.json` (tracked in git)
