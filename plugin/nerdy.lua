if vim.g.loaded_nerdicons then
  return
end

vim.g.loaded_nerdicons = true

vim.cmd('command! Nerdy lua require("nerdy").list()')

