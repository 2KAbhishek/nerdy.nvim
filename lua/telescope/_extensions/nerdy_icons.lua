local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local icon_list = require('nerdy.icons')

local recent_utils = require('nerdy.recent')

return function(opts)
    opts = opts or require('telescope.themes').get_dropdown({})
    pickers
        .new(opts, {
            prompt_title = 'Nerdy Icons',
            finder = finders.new_table({
                results = icon_list,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = string.format('%s (%s) : %s', entry.name, entry.code, entry.char),
                        ordinal = entry.name .. ' ' .. entry.code,
                    }
                end,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    local selected_entry = action_state.get_selected_entry().value
                    local icon = selected_entry.char
                    recent_utils.add_to_recent(selected_entry)
                    actions.close(prompt_bufnr)
                    vim.api.nvim_put({ icon }, 'c', true, true)
                end)
                return true
            end,
        })
        :find()
end
