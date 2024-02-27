local nerdy = {}

nerdy.generate = function()
    local icon_list = {}
    for k, v in pairs(require('nerdy.icons')) do
        table.insert(icon_list, k .. ' : ' .. v)
    end
    return icon_list
end

nerdy.list = function()
    local icon_list = nerdy.generate()

    if #icon_list > 0 then
        vim.ui.select(icon_list, { prompt = 'Nerdy Icons' }, function(item, _)
            if item ~= nil then
                local icon = vim.split(item, ' : ')[2]
                local cursor_position = vim.api.nvim_win_get_cursor(0)
                local row = cursor_position[1]
                local column = cursor_position[2]
                -- insert icon after cursor
                vim.api.nvim_buf_set_text(0, row - 1, column, row - 1, column, { icon })
                -- move cursor to the end of the inserted icon
                vim.api.nvim_win_set_cursor(0, { row, column + #icon })
            end
        end)
    end
end

return nerdy
