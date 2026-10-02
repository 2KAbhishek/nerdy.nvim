local M = {}

---@class nerdy.config
---@field max_recents integer : Max number of recent icons to keep
---@field copy_to_clipboard boolean : -- Copy glyph to clipboard instead of inserting
---@field copy_register string : -- Register to copy to (default '+')
---@field picker? 'auto' | 'snacks' | 'fzf_lua' | 'fzf-lua' | 'telescope' | 'select' : -- Picker provider to use
M.config = {
    max_recents = 100,
    copy_to_clipboard = false,
    copy_register = '+',
    picker = 'auto',
}

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

return M
