-- Harpoon: fast project-scoped file switching.
vim.pack.add { { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' } }

local harpoon = require 'harpoon'
harpoon:setup { settings = { save_on_toggle = true } }

vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon quick menu' })
vim.keymap.set('n', '<C-a>', function() harpoon:list():add() end, { desc = 'Harpoon add current file' })

for i = 1, 4 do
  vim.keymap.set('n', '<leader>' .. i, function() harpoon:list():select(i) end, { desc = ('Harpoon file %d'):format(i) })
end
