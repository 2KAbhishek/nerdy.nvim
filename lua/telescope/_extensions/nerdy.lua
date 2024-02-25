local telescope = require("telescope")

return telescope.register_extension({
    exports = {
        icons = require("telescope._extensions.nerdy_icons"),
    },
})
