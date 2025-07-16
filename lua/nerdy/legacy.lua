local fetcher = require('nerdy.fetcher')

local M = {}

---Helper to add a Neovim user command
---@param name string
---@param func fun(opts: table)
---@param opts? table
local function add_command(name, func, opts)
    vim.api.nvim_create_user_command(name, func, opts or {})
end

---Add legacy Nerdy commands
---@deprecated Use the new unified :Nerdy command instead
function M.add_legacy_commands()
    add_command('Nerdy', function()
        fetcher.list()
    end, {})

    add_command('NerdyRecents', function()
        fetcher.list_recent()
    end, {})
end

return M
