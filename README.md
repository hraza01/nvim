# neovim config

A modular, lean Neovim configuration built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) as a starting point. It uses Neovim's built-in `vim.pack` plugin manager (no lazy.nvim, no packer) and targets fast startup (~100ms warm) with a low plugin count.

## What's in it

- **LSP** — basedpyright + ruff (Python), ts_ls (JS/TS), gopls (Go), lua_ls, html/cssls/tailwindcss, sqls, dockerls, jsonls, yamlls. Auto-installed via Mason.
- **Formatting** — conform.nvim with format-on-save (ruff for Python, prettierd for web, stylua for Lua). Per-buffer and global toggles.
- **Completion** — blink.cmp + LuaSnip.
- **Folding** — native treesitter folds (no nvim-ufo).
- **File explorer** — oil.nvim (edit the filesystem like a buffer).
- **Fuzzy finder** — Telescope (files, grep, LSP symbols, commands, help).
- **Git** — vim-fugitive (status/blame/diff/push) + gitsigns (hunk navigation/staging).
- **Multi-cursor** — vim-visual-multi.
- **Task runner** — overseer.nvim (reads `.vscode/tasks.json`).
- **Project switcher** — native Telescope picker over `~/dev/*` (no plugin).
- **Python venv** — native `.venv` detection, auto-sets `python3_host_prog` + pyright `pythonPath` + activates in terminals (no plugin).
- **Markdown preview** — markdown-preview.nvim (opens browser).
- **Comments** — mini.comment with `<leader>/` toggle.
- **Auto-pairs** — bracket/quote auto-closing.
- **Indent guides** — indent-blankline.nvim.
- **BigQuery** — [BQNvim](https://github.com/hraza01/bqnvim) (run queries, browse schema, table aliases).

## Structure

```
init.lua                  # 14-line bootstrap — sets load order only
lua/
  config/
    options.lua           # vim options (leader, numbers, folds, exrc, etc.)
    keymaps.lua           # non-plugin keymaps (navigation, folds, comments)
    autocmds.lua          # non-plugin autocmds (yank highlight, live reload)
  plugins/
    init.lua              # vim.pack build hooks + auto-loader
    ui.lua                # guess-indent, which-key, colorscheme, todo-comments, mini.*, lualine
    telescope.lua         # fuzzy finder + keymaps
    lsp.lua               # lspconfig, mason, servers, LspAttach keymaps
    conform.lua           # format-on-save + toggles
    completion.lua        # blink.cmp + luasnip
    treesitter.lua        # parsers, highlighting, folds, indentation
    gitsigns.lua          # hunk navigation/staging
    git.lua               # fugitive + rhubarb
    oil.lua               # file explorer
    harpoon.lua           # fast file switching
    overseer.lua          # task runner
    multi-cursor.lua      # vim-visual-multi
    markdown-preview.lua  # browser markdown preview
    autopairs.lua         # bracket auto-closing
    indent-line.lua       # indentation guides
    bqnvim.lua            # BigQuery CLI wrapper
  lib/
    venv.lua              # python venv detection (native, no plugin)
    projects.lua          # project switcher (native, no plugin)
```

Each plugin file is self-contained — it calls `vim.pack.add`, runs `setup()`, and defines its own keymaps. You can understand any plugin by reading one file.

## Requirements

- **Neovim 0.12+** (stable)
- `git`, `make`, `unzip`, a C compiler (`gcc`/`clang`)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation) (for Telescope grep)
- [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md#installation) (optional, for parser compilation)
- A clipboard tool (`xclip`/`xsel` on Linux; macOS has it built-in)
- [Nerd Font](https://www.nerdfonts.com/) — optional; set `vim.g.have_nerd_font = true` in `lua/config/options.lua` if you have one
- Language runtimes for the LSPs you want (e.g. `npm` for ts_ls, `go` for gopls, `python` for basedpyright/ruff)

## Install

1. Back up your existing config if you have one:
   ```sh
   mv ~/.config/nvim ~/.config/nvim.bak
   mv ~/.local/share/nvim ~/.local/share/nvim.bak
   ```

2. Clone this repo:
   ```sh
   git clone https://github.com/<your-username>/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
   ```

3. Start Neovim:
   ```sh
   nvim
   ```

`vim.pack` will install all plugins automatically on first launch. Mason will install LSP servers and formatters in the background. Wait a few seconds, then restart nvim.

## Post-install

- Run `:checkhealth` to verify your setup.
- Run `:Mason` to see LSP/tool installation status.
- Press `<leader>` (Space) and wait ~1.25s for which-key to show all available keymaps.
- Read [`cheatsheet.md`](cheatsheet.md) for the full keymap reference.

## Plugin management

Uses Neovim's built-in `vim.pack` — no external plugin manager.

- Inspect state: `:lua vim.pack.update(nil, { offline = true })`
- Update all plugins: `:lua vim.pack.update()` (then `:write` to apply, `:quit` to cancel)
- Lockfile: `nvim-pack-lock.json` (tracked in git for reproducible installs)

## Per-project overrides

Create a `.nvim.lua` in a project root to override settings for that project:

```lua
-- .nvim.lua
vim.g.format_on_save = false  -- disable format-on-save for this repo
-- vim.g.python3_host_prog = '/abs/path/to/.venv/bin/python'  -- non-standard venv path
```

`vim.o.exrc = true` enables this; `vim.o.secure = true` prompts before running unsafe commands from those files.

## Customizing

- **Add a plugin**: create `lua/plugins/<name>.lua`, call `vim.pack.add`, `setup()`, define keymaps. It's auto-loaded.
- **Change options**: edit `lua/config/options.lua`.
- **Add keymaps**: edit `lua/config/keymaps.lua` (non-plugin) or the relevant plugin file.
- **Add an LSP**: add an entry to the `servers` table in `lua/plugins/lsp.lua`.
- **Add a formatter**: add an entry to `formatters_by_ft` in `lua/plugins/conform.lua` and the tool to `ensure_installed` in `lua/plugins/lsp.lua`.
- **Change the project directory**: edit `dev_root()` in `lua/lib/projects.lua` (defaults to `~/dev`).

## License

MIT
