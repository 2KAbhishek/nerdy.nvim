local nerdy = {}

nerdy.list = function()
    local icon_list = require('nerdy.icons')
    local initial_mode = vim.api.nvim_get_mode().mode

    vim.ui.select(icon_list, {
        prompt = 'Nerdy Icons',
        format_item = function(item)
            local item_str = string.format('%s (%s) : %s', item.name, item.code, item.char)
            return item_str
        end,
    }, function(item, _)
        if item ~= nil then
            local is_insert_mode = (initial_mode == 'i')

            vim.api.nvim_put({ item.char }, 'c', not is_insert_mode, true)

            if is_insert_mode then
              vim.cmd('startinsert')
            end
        end
    end)
end

return nerdy
