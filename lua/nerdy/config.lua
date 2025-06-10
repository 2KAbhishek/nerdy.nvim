local M = {}

M.options = {
    max_recent = 30,
}

M.setup = function(opts)
    M.options = vim.tbl_deep_extend('force', M.options, opts or {})
end

return M
