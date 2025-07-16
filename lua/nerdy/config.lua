local M = {}

M.config = {
    max_recent = 30,
    use_new_command = false,
}

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

return M
