return {
    setup = function(opts)
        require('nerdy.config').setup(opts)
        require('nerdy.commands').setup()
    end,
}
