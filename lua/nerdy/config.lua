local M = {}

---@class nerdy.config
---@field max_recents integer : Max number of recent icons to keep
---@field add_default_keybindings boolean : Whether to add default keybindings
---@field output_location string|nil : Register to output icon to (nil for insert in place)
---@field copy_to_clipboard boolean|nil : @deprecated Use output_location instead
M.config = {
	max_recents = 30,
	add_default_keybindings = true,
	output_location = nil,
}

M.setup = function(opts)
	-- Handle deprecated copy_to_clipboard option
	if opts and opts.copy_to_clipboard ~= nil then
		if opts.copy_to_clipboard then
			opts.output_location = '+'
			vim.notify(
				'nerdy.nvim: copy_to_clipboard is deprecated, use output_location = "+" instead',
				vim.log.levels.WARN
			)
		else
			opts.output_location = nil
		end
		opts.copy_to_clipboard = nil
	end
	
	M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

return M
