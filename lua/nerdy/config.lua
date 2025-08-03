local M = {}

---@class nerdy.config
---@field max_recents integer : Max number of recent icons to keep
---@field add_default_keybindings boolean : Whether to add default keybindings
---@field use_new_command boolean : Whether to use new Nerdy command
---@field selection_to_clipboard boolean : Whether to copy selected icon to clipboard
M.config = {
    max_recents = 30,
    add_default_keybindings = true,
    use_new_command = false,
    selection_to_clipboard = false,
}

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

return M
