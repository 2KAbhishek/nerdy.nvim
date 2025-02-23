local nerdy = {}

nerdy.list = function()
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
            local is_insert_mode = (initial_mode == 'i')

            if is_insert_mode then
                vim.cmd('startinsert')
            end
            vim.api.nvim_win_set_cursor(0, cursor_position)

            vim.api.nvim_put({ item.char }, 'c', not is_insert_mode, true)
        end
    end)
end

return nerdy
