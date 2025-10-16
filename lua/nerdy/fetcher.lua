local fetcher = {}
local recents = require('nerdy.recents')
local config_module = require('nerdy.config')

local function multi_select(icon_list, list_title, snacks)
    local initial_mode = vim.api.nvim_get_mode().mode
    local cursor_position = vim.api.nvim_win_get_cursor(0)

    local items = {}
    for _, icon in ipairs(icon_list) do
        items[#items + 1] = {
            text = string.format('%s (%s) : %s', icon.name, icon.code, icon.char),
            icon = icon
        }
    end

    snacks.picker.pick({
        items = items,
        format = 'text',
        layout = {
            preset = "select"
        },
        title = list_title,
        confirm = function(picker, item)
            local selected = picker:selected({ fallback = true })
            picker:close()

            if #selected > 0 then
                local chars = {}
                for _, selected_item in ipairs(selected) do
                    recents.add_to_recent(selected_item.icon)
                    table.insert(chars, selected_item.icon.char)
                end
                if config_module.config.copy_to_clipboard then
                    vim.fn.setreg('+', table.concat(chars, ''))
                    return
                end
                if initial_mode == 'i' then
                    vim.cmd('startinsert')
                end
                vim.api.nvim_win_set_cursor(0, cursor_position)
                vim.api.nvim_put({ table.concat(chars, ' ') }, 'c', false, true)
            end
        end
    })
end

local function single_select(icon_list, list_title)
    local initial_mode = vim.api.nvim_get_mode().mode
    local cursor_position = vim.api.nvim_win_get_cursor(0)

    vim.ui.select(icon_list, {
        prompt = list_title,
        format_item = function(item)
            local item_str = string.format('%s (%s) : %s', item.name, item.code, item.char)
            return item_str
        end,
    }, function(item, _)
        if item ~= nil then
            recents.add_to_recent(item)
            if config_module.config.copy_to_clipboard then
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

local function insert_icon_from_list(icon_list, list_title)
    local ok, snacks = pcall(require, 'snacks')
    if ok and snacks.picker then
        multi_select(icon_list, list_title, snacks)
    else
        single_select(icon_list, list_title)
    end
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
