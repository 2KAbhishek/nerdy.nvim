local M = {}

local recent_icons_file = vim.fn.stdpath('data') .. '/nerdy_recent.json'

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
    local file = io.open(recent_icons_file, 'w')
    if file then
        file:write(vim.json.encode(recent_icons))
        file:close()
    end
end

M.add_to_recent = function(icon)
    local config = require('nerdy.config')
    local recent_icons = M.load_recent_icons()
    local max_recent = config.options.max_recent

    -- Remove if already exists
    for i, recent_icon in ipairs(recent_icons) do
        if recent_icon.name == icon.name then
            table.remove(recent_icons, i)
            break
        end
    end

    -- Add to front
    table.insert(recent_icons, 1, icon)

    -- Trim to max size
    while #recent_icons > max_recent do
        table.remove(recent_icons, #recent_icons)
    end

    M.save_recent_icons(recent_icons)
end

return M
