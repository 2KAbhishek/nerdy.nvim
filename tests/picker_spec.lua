local picker = require('nerdy.picker')
local config_module = require('nerdy.config')

describe('picker', function()
    local original_config

    before_each(function()
        original_config = vim.deepcopy(config_module.config)
        config_module.config.picker = 'auto'
    end)

    after_each(function()
        config_module.config = vim.deepcopy(original_config)
    end)

    describe('normalize_provider', function()
        it('normalizes fzf aliases', function()
            assert.are.equal('fzf_lua', picker.normalize_provider('fzf-lua'))
            assert.are.equal('fzf_lua', picker.normalize_provider('fzf_lua'))
            assert.are.equal('fzf_lua', picker.normalize_provider('fzf'))
            assert.are.equal('fzf_lua', picker.normalize_provider('FZF-LUA'))
        end)

        it('normalizes snacks aliases', function()
            assert.are.equal('snacks', picker.normalize_provider('snacks'))
            assert.are.equal('snacks', picker.normalize_provider('snacks.picker'))
            assert.are.equal('snacks', picker.normalize_provider('snacks_picker'))
        end)

        it('normalizes telescope', function()
            assert.are.equal('telescope', picker.normalize_provider('telescope'))
            assert.are.equal('telescope', picker.normalize_provider('TELESCOPE'))
        end)

        it('normalizes select aliases', function()
            assert.are.equal('select', picker.normalize_provider('select'))
            assert.are.equal('select', picker.normalize_provider('vim.ui.select'))
            assert.are.equal('select', picker.normalize_provider('ui_select'))
            assert.are.equal('select', picker.normalize_provider('ui-select'))
        end)

        it('returns auto for nil or auto', function()
            assert.are.equal('auto', picker.normalize_provider(nil))
            assert.are.equal('auto', picker.normalize_provider('auto'))
        end)
    end)

    describe('is_available', function()
        it('returns true for select', function()
            assert.is_true(picker.is_available('select'))
        end)

        it('returns false for unknown provider', function()
            assert.is_false(picker.is_available('unknown_picker'))
        end)
    end)

    describe('get_provider', function()
        it('falls back to select when no external pickers are installed', function()
            config_module.config.picker = 'auto'
            assert.are.equal('select', picker.get_provider())
        end)

        it('warns and falls back to select when configured provider is unavailable', function()
            config_module.config.picker = 'fzf-lua'

            local warned_message = nil
            local warned_level = nil
            local original_notify = vim.notify
            vim.notify = function(msg, level)
                warned_message = msg
                warned_level = level
            end

            local resolved = picker.get_provider()
            vim.notify = original_notify

            assert.are.equal('select', resolved)
            assert.is_not_nil(warned_message)
            assert.is_truthy(warned_message:match('Configured picker "fzf_lua" is not available'))
            assert.are.equal(vim.log.levels.WARN, warned_level)
        end)

        it('honors provider priority when auto-detecting', function()
            local original_is_available = picker.is_available
            picker.is_available = function(provider)
                if provider == 'fzf_lua' or provider == 'telescope' then
                    return true
                end
                return false
            end

            config_module.config.picker = 'auto'
            assert.are.equal('telescope', picker.get_provider())

            picker.is_available = function(provider)
                if provider == 'fzf_lua' then
                    return true
                end
                return false
            end
            assert.are.equal('fzf_lua', picker.get_provider())

            picker.is_available = original_is_available
        end)

        it('uses explicit provider when available', function()
            local original_is_available = picker.is_available
            picker.is_available = function(provider)
                return provider == 'fzf_lua'
            end

            config_module.config.picker = 'fzf-lua'
            assert.are.equal('fzf_lua', picker.get_provider())

            picker.is_available = original_is_available
        end)
    end)

    describe('fzf_lua provider', function()
        local mock_icons = {
            { name = 'cod-account', code = 'eb99', char = '' },
            { name = 'cod-add', code = 'ea60', char = '' },
        }

        it('invokes fzf-lua with multi-select enabled and returns selected items', function()
            local captured_items = nil
            local captured_opts = nil

            package.loaded['fzf-lua'] = {
                fzf_exec = function(items, opts)
                    captured_items = items
                    captured_opts = opts
                end,
            }

            local selected_result = nil
            picker.providers.fzf_lua(mock_icons, 'Test Icons', function(selected)
                selected_result = selected
            end)

            assert.is_not_nil(captured_items)
            assert.are.equal(2, #captured_items)
            assert.are.equal('cod-account (eb99) : ', captured_items[1])
            assert.are.equal('Test Icons  ', captured_opts.prompt)
            assert.is_false(captured_opts.previewer)
            assert.is_true(captured_opts.fzf_opts['--multi'])
            assert.are.equal('0', captured_opts.fzf_opts['--margin'])
            assert.are.equal('0', captured_opts.fzf_opts['--padding'])

            -- Simulate single selection
            captured_opts.actions['default']({ captured_items[1] })
            assert.is_not_nil(selected_result)
            assert.are.equal(1, #selected_result)
            assert.are.equal('cod-account', selected_result[1].name)

            -- Simulate multi-selection
            captured_opts.actions['default']({ captured_items[1], captured_items[2] })
            assert.are.equal(2, #selected_result)
            assert.are.equal('cod-account', selected_result[1].name)
            assert.are.equal('cod-add', selected_result[2].name)

            package.loaded['fzf-lua'] = nil
        end)
    end)

    describe('snacks provider', function()
        local mock_icons = {
            { name = 'cod-account', code = 'eb99', char = '' },
            { name = 'cod-add', code = 'ea60', char = '' },
        }

        it('invokes snacks picker and returns selected items', function()
            local captured_config = nil
            local closed = false

            package.loaded['snacks'] = {
                picker = {
                    pick = function(cfg)
                        captured_config = cfg
                    end,
                },
            }

            local selected_result = nil
            picker.providers.snacks(mock_icons, 'Test Snacks', function(selected)
                selected_result = selected
            end)

            assert.is_not_nil(captured_config)
            assert.are.equal(2, #captured_config.items)
            assert.are.equal('Test Snacks', captured_config.title)
            assert.are.equal('select', captured_config.layout.preset)

            local mock_picker = {
                selected = function(_, _)
                    return { { icon = mock_icons[1] }, { icon = mock_icons[2] } }
                end,
                close = function(_)
                    closed = true
                end,
            }

            captured_config.confirm(mock_picker)
            assert.is_true(closed)
            assert.is_not_nil(selected_result)
            assert.are.equal(2, #selected_result)
            assert.are.equal('cod-account', selected_result[1].name)
            assert.are.equal('cod-add', selected_result[2].name)

            package.loaded['snacks'] = nil
        end)
    end)

    describe('telescope provider', function()
        local mock_icons = {
            { name = 'cod-account', code = 'eb99', char = '' },
            { name = 'cod-add', code = 'ea60', char = '' },
        }

        it('invokes telescope picker and handles multi and single selections', function()
            local picker_opts = nil
            local attach_mappings_fn = nil
            local closed_bufnr = nil

            package.loaded['telescope.pickers'] = {
                new = function(theme_opts, opts)
                    picker_opts = opts
                    return {
                        find = function() end,
                    }
                end,
            }
            package.loaded['telescope.finders'] = {
                new_table = function(opts)
                    return opts
                end,
            }
            package.loaded['telescope.config'] = {
                values = {
                    generic_sorter = function() return {} end,
                },
            }
            package.loaded['telescope.themes'] = {
                get_dropdown = function(opts) return opts end,
            }
            package.loaded['telescope.actions'] = {
                select_default = {
                    replace = function(_, fn)
                        attach_mappings_fn = fn
                    end,
                },
                close = function(bufnr)
                    closed_bufnr = bufnr
                end,
            }

            local mock_multi = { { value = mock_icons[1] }, { value = mock_icons[2] } }
            local mock_single = { value = mock_icons[1] }
            local return_multi = true

            package.loaded['telescope.actions.state'] = {
                get_current_picker = function(_)
                    return {
                        get_multi_selection = function(_)
                            if return_multi then
                                return mock_multi
                            end
                            return {}
                        end,
                    }
                end,
                get_selected_entry = function(_)
                    return mock_single
                end,
            }

            local selected_result = nil
            picker.providers.telescope(mock_icons, 'Test Telescope', function(selected)
                selected_result = selected
            end)

            assert.is_not_nil(picker_opts)
            assert.are.equal('Test Telescope', picker_opts.prompt_title)
            picker_opts.attach_mappings(123, nil)

            -- Test multi-selection
            attach_mappings_fn()
            assert.are.equal(123, closed_bufnr)
            assert.are.equal(2, #selected_result)
            assert.are.equal('cod-account', selected_result[1].name)
            assert.are.equal('cod-add', selected_result[2].name)

            -- Test single-selection fallback
            return_multi = false
            attach_mappings_fn()
            assert.are.equal(1, #selected_result)
            assert.are.equal('cod-account', selected_result[1].name)

            package.loaded['telescope.pickers'] = nil
            package.loaded['telescope.finders'] = nil
            package.loaded['telescope.config'] = nil
            package.loaded['telescope.themes'] = nil
            package.loaded['telescope.actions'] = nil
            package.loaded['telescope.actions.state'] = nil
        end)
    end)

    describe('fetcher integration with fzf-lua', function()
        local fetcher = require('nerdy.fetcher')
        local recents = require('nerdy.recents')

        after_each(function()
            package.loaded['fzf-lua'] = nil
        end)

        it('saves to recents and copies to clipboard on fzf-lua multi-selection', function()
            config_module.setup({
                picker = 'fzf-lua',
                copy_to_clipboard = true,
                copy_register = '+',
            })

            local captured_actions = nil
            package.loaded['fzf-lua'] = {
                fzf_exec = function(items, opts)
                    captured_actions = opts.actions
                end,
            }

            local added_recents = {}
            local original_add = recents.add_to_recent
            recents.add_to_recent = function(icon)
                table.insert(added_recents, icon)
            end

            local clipboard_content = ''
            local original_setreg = vim.fn.setreg
            vim.fn.setreg = function(reg, val)
                if reg == '+' then
                    clipboard_content = val
                end
            end

            fetcher.list()

            assert.is_not_nil(captured_actions)
            -- Simulate selecting 2 icons from fzf-lua
            captured_actions['default']({ 'cod-account (eb99) : ', 'cod-add (ea60) : ' })

            vim.fn.setreg = original_setreg
            recents.add_to_recent = original_add

            assert.are.equal('', clipboard_content)
            assert.are.equal(2, #added_recents)
            assert.are.equal('cod-account', added_recents[1].name)
            assert.are.equal('cod-add', added_recents[2].name)
        end)
    end)
end)
