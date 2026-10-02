local config_module = require('nerdy.config')

local M = {}

local provider_aliases = {
    ['fzf-lua'] = 'fzf_lua',
    ['fzf_lua'] = 'fzf_lua',
    ['fzf'] = 'fzf_lua',
    ['snacks'] = 'snacks',
    ['snacks.picker'] = 'snacks',
    ['snacks_picker'] = 'snacks',
    ['telescope'] = 'telescope',
    ['select'] = 'select',
    ['vim.ui.select'] = 'select',
    ['ui_select'] = 'select',
    ['ui-select'] = 'select',
}

M.provider_priority = { 'snacks', 'telescope', 'fzf_lua' }

---Normalize user configured picker name to canonical form
---@param name? string
---@return string
function M.normalize_provider(name)
    if not name or name == 'auto' then
        return 'auto'
    end
    local lower = string.lower(name)
    return provider_aliases[lower] or lower
end

---Check if a given provider is available in the environment
---@param provider string
---@return boolean
function M.is_available(provider)
    if provider == 'snacks' then
        local ok, snacks = pcall(require, 'snacks')
        return ok and type(snacks.picker) == 'table' and type(snacks.picker.pick) == 'function'
    elseif provider == 'fzf_lua' then
        local ok, fzf = pcall(require, 'fzf-lua')
        return ok and type(fzf.fzf_exec) == 'function'
    elseif provider == 'telescope' then
        local ok, pickers = pcall(require, 'telescope.pickers')
        return ok and type(pickers) == 'table'
    elseif provider == 'select' then
        return true
    end
    return false
end

---Find the first available provider according to priority
---@return string
local function find_available_provider()
    for _, provider in ipairs(M.provider_priority) do
        if M.is_available(provider) then
            return provider
        end
    end
    return 'select'
end

---Resolve the active provider based on config and availability
---@return string
function M.get_provider()
    local preferred = M.normalize_provider(config_module.config.picker)
    if preferred == 'auto' then
        return find_available_provider()
    end

    if M.is_available(preferred) then
        return preferred
    end

    vim.notify(
        string.format('nerdy.nvim: Configured picker "%s" is not available. Falling back to auto-detect.', preferred),
        vim.log.levels.WARN
    )
    return find_available_provider()
end

---Pick using snacks.picker
---@param icon_list table[]
---@param list_title string
---@param on_select fun(selected: table[])
local function snacks_select(icon_list, list_title, on_select)
    local snacks = require('snacks')
    local items = {}
    for _, icon in ipairs(icon_list) do
        items[#items + 1] = {
            text = string.format('%s (%s) : %s', icon.name, icon.code, icon.char),
            icon = icon,
        }
    end

    snacks.picker.pick({
        items = items,
        format = 'text',
        layout = {
            preset = 'select',
        },
        title = list_title,
        confirm = function(p, _)
            local selected = p:selected({ fallback = true })
            p:close()

            if selected and #selected > 0 then
                local chosen = {}
                for _, selected_item in ipairs(selected) do
                    table.insert(chosen, selected_item.icon)
                end
                on_select(chosen)
            end
        end,
    })
end

---Pick using fzf-lua
---@param icon_list table[]
---@param list_title string
---@param on_select fun(selected: table[])
local function fzf_lua_select(icon_list, list_title, on_select)
    local fzf = require('fzf-lua')
    local items = {}
    local item_map = {}
    for _, icon in ipairs(icon_list) do
        local display = string.format('%s (%s) : %s', icon.name, icon.code, icon.char)
        table.insert(items, display)
        item_map[display] = icon
    end

    fzf.fzf_exec(items, {
        prompt = list_title .. '  ',
        previewer = false,
        fzf_opts = {
            ['--multi'] = true,
            ['--margin'] = '0',
            ['--padding'] = '0',
        },
        actions = {
            ['default'] = function(selected)
                if not selected or #selected == 0 then
                    return
                end
                if type(selected) == 'string' then
                    selected = { selected }
                end
                local chosen = {}
                for _, line in ipairs(selected) do
                    if item_map[line] then
                        table.insert(chosen, item_map[line])
                    end
                end
                if #chosen > 0 then
                    on_select(chosen)
                end
            end,
        },
    })
end

---Pick using telescope
---@param icon_list table[]
---@param list_title string
---@param on_select fun(selected: table[])
local function telescope_select(icon_list, list_title, on_select)
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    local opts = require('telescope.themes').get_dropdown({})
    pickers
        .new(opts, {
            prompt_title = list_title,
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
                    local current_picker = action_state.get_current_picker(prompt_bufnr)
                    local multi_selection = current_picker:get_multi_selection()
                    actions.close(prompt_bufnr)

                    if multi_selection and #multi_selection > 0 then
                        local chosen = {}
                        for _, entry in ipairs(multi_selection) do
                            table.insert(chosen, entry.value)
                        end
                        on_select(chosen)
                    else
                        local entry = action_state.get_selected_entry()
                        if entry and entry.value then
                            on_select({ entry.value })
                        end
                    end
                end)
                return true
            end,
        })
        :find()
end

---Pick using vim.ui.select fallback
---@param icon_list table[]
---@param list_title string
---@param on_select fun(selected: table[])
local function ui_select(icon_list, list_title, on_select)
    vim.ui.select(icon_list, {
        prompt = list_title,
        format_item = function(item)
            return string.format('%s (%s) : %s', item.name, item.code, item.char)
        end,
    }, function(item, _)
        if item ~= nil then
            on_select({ item })
        end
    end)
end

M.providers = {
    snacks = snacks_select,
    fzf_lua = fzf_lua_select,
    telescope = telescope_select,
    select = ui_select,
}

---Display icon picker using resolved provider
---@param icon_list table[]
---@param list_title string
---@param on_select fun(selected: table[])
function M.pick(icon_list, list_title, on_select)
    local provider = M.get_provider()
    local handler = M.providers[provider] or ui_select
    handler(icon_list, list_title, on_select)
end

return M
