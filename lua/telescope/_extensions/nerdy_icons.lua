local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local nerdy = require('nerdy')

return function(opts)
    opts = opts or require("telescope.themes").get_dropdown({})
    pickers
        .new(opts, {
            prompt_title = "Nerdy Icons",
            finder = finders.new_table({
                results = nerdy.generate(),

                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry,
                        ordinal = entry,
                    }
                end,
            }),
            sorter = conf.generic_sorter(opts),
            ---@diagnostic disable-next-line: unused-local
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    local icon = vim.split(action_state.get_selected_entry().value, ' : ')[2]
                    actions.close(prompt_bufnr)
                    local cursor_position = vim.api.nvim_win_get_cursor(0)
                    local row = cursor_position[1]
                    local column = cursor_position[2]
                    -- insert icon after cursor
                    vim.api.nvim_buf_set_text(0, row - 1, column, row - 1, column, { icon })
                    -- move cursor to the end of the inserted icon
                    vim.api.nvim_win_set_cursor(0, { row, column + #icon })
                end)
                return true
            end,
        })
        :find()
end
