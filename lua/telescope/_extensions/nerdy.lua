local telescope = require('telescope')

return telescope.register_extension({
    exports = { 
        nerdy = require('telescope._extensions.nerdy_icons'),
        nerdy_recent = require('telescope._extensions.nerdy_recent')
    },
})
