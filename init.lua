-- Neovim configuration entry point.
-- Everything lives in lua/ — this file just sets the load order.
--
-- Structure:
--   lua/config/    options, keymaps, autocmds (loaded first)
--   lua/plugins/   all plugins (self-contained, auto-loaded by plugins/init.lua)
--   lua/lib/       non-plugin utilities (venv detection, project switcher)
--
-- See cheatsheet.md for the full keymap reference.

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'plugins'
