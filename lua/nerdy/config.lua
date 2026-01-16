local M = {}

---@class nerdy.config
---@field max_recents integer : Max number of recent icons to keep
---@field copy_to_clipboard boolean : -- Copy glyph to clipboard instead of inserting
M.config = {
    max_recents = 30,
    copy_to_clipboard = false,
    copy_register = '+',
}

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

return M
