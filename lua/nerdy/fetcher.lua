local fetcher = {}
local recents = require('nerdy.recents')
local config_module = require('nerdy.config')
local picker = require('nerdy.picker')

local function on_select(selected_icons, initial_mode, cursor_position)
    if not selected_icons or #selected_icons == 0 then
        return
    end

    local copy_register = config_module.config.copy_register or '+'
    local chars = {}
    for _, icon in ipairs(selected_icons) do
        recents.add_to_recent(icon)
        table.insert(chars, icon.char)
    end

    if config_module.config.copy_to_clipboard then
        vim.fn.setreg(copy_register, table.concat(chars, ''))
        return
    end

    if initial_mode == 'i' then
        vim.cmd('startinsert')
    end
    vim.api.nvim_win_set_cursor(0, cursor_position)
    vim.api.nvim_put({ table.concat(chars, ' ') }, 'c', false, true)
end

local function insert_icon_from_list(icon_list, list_title)
    local initial_mode = vim.api.nvim_get_mode().mode
    local cursor_position = vim.api.nvim_win_get_cursor(0)

    picker.pick(icon_list, list_title, function(selected)
        on_select(selected, initial_mode, cursor_position)
    end)
end

fetcher.list = function()
    local icon_list = require('nerdy.icons')
    insert_icon_from_list(icon_list, 'Nerdy Icons')
end

fetcher.list_recents = function()
    local recent_icons = recents.load_recent_icons()
    if #recent_icons == 0 then
        vim.notify('No recent icons found', vim.log.levels.INFO)
        return
    end
    insert_icon_from_list(recent_icons, 'Recent Nerdy Icons')
end

fetcher.get = function(name)
    if name == nil then
        return ''
    end
    local icon_list = require('nerdy.icons')
    for _, item in ipairs(icon_list) do
        if item.name == name then
            return item.char
        end
    end
    vim.notify('Icon not found: ' .. name, vim.log.levels.WARN)
    return ''
end

fetcher.get_icon_names = function()
    local icon_list = require('nerdy.icons')
    local names = {}
    for _, item in ipairs(icon_list) do
        table.insert(names, item.name)
    end
    return names
end

return fetcher
