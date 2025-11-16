local M = {}

local data_path = vim.fn.stdpath('data')
local recent_icons_file = data_path .. '/nerdy_recent.json'

M.load_recent_icons = function()
    local file = io.open(recent_icons_file, 'r')
    if not file then
        return {}
    end
    local content = file:read('*all')
    file:close()

    local ok, data = pcall(vim.json.decode, content)
    if ok and type(data) == 'table' then
        return data
    end
    return {}
end

M.save_recent_icons = function(recent_icons)
    if vim.fn.isdirectory(data_path) == 0 then
        vim.fn.mkdir(data_path, 'p')
    end
    local file = io.open(recent_icons_file, 'w')
    if file then
        file:write(vim.json.encode(recent_icons))
        file:close()
    end
end

M.add_to_recent = function(icon)
    local recent_icons = M.load_recent_icons()
    local config = require('nerdy.config').config
    local max_recents = config.max_recents

    for i, recent_icon in ipairs(recent_icons) do
        if recent_icon.name == icon.name then
            table.remove(recent_icons, i)
            break
        end
    end

    table.insert(recent_icons, 1, icon)
    while #recent_icons > max_recents do
        table.remove(recent_icons, #recent_icons)
    end
    M.save_recent_icons(recent_icons)
end

return M
