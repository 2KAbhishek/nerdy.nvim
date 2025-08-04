local fetcher = {}
local recents = require('nerdy.recents')
local config = require('nerdy.config').config

fetcher.list = function()
    local icon_list = require('nerdy.icons')
    local initial_mode = vim.api.nvim_get_mode().mode
    local cursor_position = vim.api.nvim_win_get_cursor(0)

    vim.ui.select(icon_list, {
        prompt = 'Nerdy Icons',
        format_item = function(item)
            local item_str = string.format('%s (%s) : %s', item.name, item.code, item.char)
            return item_str
        end,
    }, function(item, _)
        if item ~= nil then
            recents.add_to_recent(item)
            if config.copy_to_clipboard then
                vim.fn.setreg('+', item.char)
                return
            end
            if initial_mode == 'i' then
                vim.cmd('startinsert')
            end
            vim.api.nvim_win_set_cursor(0, cursor_position)
            vim.api.nvim_put({ item.char }, 'c', false, true)
        end
    end)
end

fetcher.list_recents = function()
    local recent_icons = recents.load_recent_icons()
    if #recent_icons == 0 then
        vim.notify('No recent icons found', vim.log.levels.INFO)
        return
    end

    local initial_mode = vim.api.nvim_get_mode().mode
    local cursor_position = vim.api.nvim_win_get_cursor(0)

    vim.ui.select(recent_icons, {
        prompt = 'Recent Nerdy Icons',
        format_item = function(item)
            local item_str = string.format('%s (%s) : %s', item.name, item.code, item.char)
            return item_str
        end,
    }, function(item, _)
        if item ~= nil then
            recents.add_to_recent(item)
            if config.copy_to_clipboard then
                vim.fn.setreg('+', item.char)
                return
            end
            if initial_mode == 'i' then
                vim.cmd('startinsert')
            end
            vim.api.nvim_win_set_cursor(0, cursor_position)
            vim.api.nvim_put({ item.char }, 'c', false, true)
        end
    end)
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
