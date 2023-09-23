local nerdy = {}

nerdy.generate = function()
    local icon_list = {}
    for k, v in pairs(require('nerdy.icons').get_icons()) do
        table.insert(icon_list, k .. ' : ' .. v)
    end
    return icon_list
end

nerdy.list = function()
    local icon_list = nerdy.generate()

    if #icon_list > 0 then
        vim.ui.select(icon_list, { prompt = 'Select an icon:' }, function(item, _)
            if item then
                local string = "'" .. vim.split(item, ' : ')[2] .. " '"
                local cursor_position = vim.api.nvim_win_get_cursor(0)
                local line = cursor_position[1]
                local column = cursor_position[2]
                -- insert icon after cursor
                vim.api.nvim_buf_set_text(0, line - 1, column, line - 1, column, { string })
                -- move cursor to the end of the inserted icon
                vim.api.nvim_win_set_cursor(0, { line, column + #string })
            end
        end)
    end
end

return nerdy
