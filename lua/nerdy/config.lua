local M = {}

---@class nerdy.config
---@field max_recents integer : Max number of recent icons to keep
---@field add_default_keybindings boolean : Whether to add default keybindings
---@field use_new_command boolean : Whether to use new Nerdy command
M.config = {
    max_recents = 30,
    add_default_keybindings = true,
    use_new_command = false,
}

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

return M
