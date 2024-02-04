if vim.g.loaded_nerdy then
    return
end

vim.g.loaded_nerdy = true

vim.api.nvim_create_user_command('Nerdy', 'lua require("nerdy").list()', {})
