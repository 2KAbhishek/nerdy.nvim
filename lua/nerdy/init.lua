local nerdy = {}

nerdy.list = function()
    local icon_list = require('nerdy.icons')

    vim.ui.select(icon_list, {
        prompt = 'Nerdy Icons',
        format_item = function(item)
            local item_str = string.format('%s (%s) : %s', item.name, item.code, item.char)
            return item_str
        end,
    }, function(item, _)
        if item ~= nil then
            vim.api.nvim_put({ item.char }, 'c', true, true)
        end
    end)
end

return nerdy
