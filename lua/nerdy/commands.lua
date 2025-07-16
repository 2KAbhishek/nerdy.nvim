local config = require('nerdy.config').config
local legacy = require('nerdy.legacy')
local fetcher = require('nerdy.fetcher')

local M = {}

---Completion for Nerdy subcommands
---@return string[]
local function complete_nerdy_subcommands()
    return { 'list', 'recent', 'get' }
end

---Main completion function for Nerdy command
---@param arglead string
---@param cmdline string
---@param cursorpos integer
---@return string[]
local function complete_nerdy(arglead, cmdline, cursorpos)
    local args = vim.split(cmdline, ' ')
    local arg_count = #args

    args = vim.tbl_filter(function(arg)
        return arg ~= ''
    end, args)

    if arg_count == 2 then
        return vim.tbl_filter(function(cmd)
            return cmd:sub(1, #arglead) == arglead
        end, complete_nerdy_subcommands())
    elseif arg_count > 2 then
        local subcommand = args[2]
        if subcommand == 'get' and arg_count == 3 then
            return vim.tbl_filter(function(icon)
                return icon:sub(1, #arglead) == arglead
            end, fetcher.get_icon_names())
        end
    end

    return {}
end

---Add the main Nerdy command
local function add_nerdy_command()
    vim.api.nvim_create_user_command('Nerdy', function(opts)
        local args = vim.split(opts.args, ' ')
        args = vim.tbl_filter(function(arg)
            return arg ~= ''
        end, args)

        if #args == 0 then
            fetcher.list()
            return
        end

        local subcommand = args[1]

        if subcommand == 'list' then
            fetcher.list()
        elseif subcommand == 'recent' then
            fetcher.list_recent()
        elseif subcommand == 'get' then
            if #args == 2 then
                local icon = fetcher.get(args[2])
                if icon ~= '' then
                    vim.api.nvim_put({ icon }, 'c', false, true)
                end
            else
                print('Usage: Nerdy get <icon_name>')
            end
        else
            print('Unknown subcommand: ' .. subcommand)
            print('Usage: Nerdy <subcommand> [options]')
            print('Available subcommands: list, recent, get')
        end
    end, { nargs = '*', complete = complete_nerdy })
end

---Setup Nerdy commands
function M.setup()
    if config.use_new_command then
        add_nerdy_command()
    else
        vim.notify(
            'Legacy Nerdy commands are deprecated and will be removed in a future version.\n'
                .. 'Please switch to the new `:Nerdy` command by adding `use_new_command = true` in your config.\n'
                .. 'More info: https://github.com/2kabhishek/nerdy.nvim',
            vim.log.levels.WARN
        )
        legacy.add_legacy_commands()
    end
end

return M
