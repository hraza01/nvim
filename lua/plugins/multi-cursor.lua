-- Multi-cursor: vim-visual-multi. No mini.move (J/K already moves lines).
--
-- VM actual defaults (leader = backslash `\`):
--   <C-n>     select word + next occurrence
--   \A        select ALL occurrences
--   <M-Down>  add cursor below (remapped from <C-Down> — macOS eats that)
--   <M-Up>    add cursor above (remapped from <C-Up>)
--   <Tab>     switch mode (cursor ↔ region)
--   ] / [     goto next / previous cursor
--   q         skip current region (NOT quit!)
--   <Esc>     EXIT multi-cursor (the real quit key)
--   n / N     find next / previous occurrence
vim.pack.add { { src = 'https://github.com/mg979/vim-visual-multi', version = 'master' } }

vim.g.VM_default_mappings = 1

vim.g.VM_maps = {
  ['Add Cursor Down'] = '<M-Down>',
  ['Add Cursor Up'] = '<M-Up>',
}
