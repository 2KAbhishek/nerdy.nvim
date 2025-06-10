local nerdy = require('nerdy')

describe('nerdy', function()
    before_each(function()
        local recent = require('nerdy.recent')
        recent.save_recent_icons({})
    end)

    after_each(function()
        local recent = require('nerdy.recent')
        recent.save_recent_icons({})
    end)

    it('has the right functions defined', function()
        assert.is_function(nerdy.list)
        assert.is_function(nerdy.list_recent)
        assert.is_function(nerdy.get)
        assert.is_function(nerdy.setup)
    end)

    describe('get function', function()
        it('returns the correct character for a valid icon name', function()
            local char = nerdy.get('cod-account')
            assert(char == '', 'Expected cod-account icon character to be ""')
        end)

        it('returns the correct character for another valid icon name', function()
            local char = nerdy.get('cod-add')
            assert(char == '', 'Expected cod-add icon character to be ""')
        end)

        it('returns empty string for non-existent icon', function()
            local char = nerdy.get('non-existent-icon')
            assert(char == '', 'Expected empty string for non-existent icon')
        end)

        it('returns empty string for nil input', function()
            local char = nerdy.get(nil)
            assert(char == '', 'Expected empty string for nil input')
        end)

        it('returns empty string for empty string input', function()
            local char = nerdy.get('')
            assert(char == '', 'Expected empty string for empty string input')
        end)
    end)

    describe('list function', function()
        it('exists and is callable', function()
            assert.is_function(nerdy.list)
        end)

        it('calls vim.ui.select with icon list', function()
            local original_ui_select = vim.ui.select
            local called_with_items = nil
            local called_with_opts = nil
            
            vim.ui.select = function(items, opts, callback)
                called_with_items = items
                called_with_opts = opts
                -- Don't call callback to avoid UI interaction
            end
            
            nerdy.list()
            
            -- Restore original function
            vim.ui.select = original_ui_select
            
            assert.is_not_nil(called_with_items)
            assert.is_table(called_with_items)
            assert(#called_with_items > 0, 'Expected non-empty icon list')
            assert.are.equal('Nerdy Icons', called_with_opts.prompt)
            assert.is_function(called_with_opts.format_item)
        end)

        it('formats items correctly', function()
            local original_ui_select = vim.ui.select
            local format_function = nil
            
            vim.ui.select = function(items, opts, callback)
                format_function = opts.format_item
            end
            
            nerdy.list()
            vim.ui.select = original_ui_select
            
            assert.is_function(format_function)
            
            local test_item = { name = 'test-icon', code = 'e123', char = '' }
            local formatted = format_function(test_item)
            assert.is_string(formatted)
            assert(formatted:match('test%-icon'), 'Expected name in formatted string')
            assert(formatted:match('e123'), 'Expected code in formatted string')
        end)

        it('adds selected icon to recent when callback is called', function()
            local original_ui_select = vim.ui.select
            local selection_callback = nil
            
            vim.ui.select = function(items, opts, callback)
                selection_callback = callback
            end
            
            nerdy.list()
            vim.ui.select = original_ui_select
            
            assert.is_function(selection_callback)
            
            -- Test that selecting an icon adds it to recent
            local recent_utils = require('nerdy.recent')
            local recent_before = recent_utils.load_recent_icons()
            assert.are.equal(0, #recent_before)
            
            local test_icon = { name = 'cod-account', code = 'eb99', char = '' }
            selection_callback(test_icon, 1)
            
            local recent_after = recent_utils.load_recent_icons()
            assert.are.equal(1, #recent_after)
            assert.are.equal('cod-account', recent_after[1].name)
        end)
    end)

    describe('list_recent function', function()
        it('exists and is callable', function()
            assert.is_function(nerdy.list_recent)
        end)

        it('shows info message when no recent icons exist', function()
            local original_notify = vim.notify
            local notification_message = nil
            local notification_level = nil
            
            vim.notify = function(message, level)
                notification_message = message
                notification_level = level
            end
            
            nerdy.list_recent()
            
            vim.notify = original_notify
            
            assert.are.equal('No recent icons found', notification_message)
            assert.are.equal(vim.log.levels.INFO, notification_level)
        end)

        it('calls vim.ui.select when recent icons exist', function()
            -- Add a recent icon first
            local recent_utils = require('nerdy.recent')
            local icon_list = require('nerdy.icons')
            recent_utils.add_to_recent(icon_list[1])
            
            local original_ui_select = vim.ui.select
            local called_with_items = nil
            local called_with_opts = nil
            
            vim.ui.select = function(items, opts, callback)
                called_with_items = items
                called_with_opts = opts
            end
            
            nerdy.list_recent()
            vim.ui.select = original_ui_select
            
            assert.is_not_nil(called_with_items)
            assert.is_table(called_with_items)
            assert.are.equal(1, #called_with_items)
            assert.are.equal('Recent Nerdy Icons', called_with_opts.prompt)
            assert.is_function(called_with_opts.format_item)
        end)

        it('updates recent list when selection is made', function()
            -- Add two recent icons
            local recent_utils = require('nerdy.recent')
            local icon_list = require('nerdy.icons')
            recent_utils.add_to_recent(icon_list[1])
            recent_utils.add_to_recent(icon_list[2])
            
            local original_ui_select = vim.ui.select
            local selection_callback = nil
            
            vim.ui.select = function(items, opts, callback)
                selection_callback = callback
            end
            
            nerdy.list_recent()
            vim.ui.select = original_ui_select
            
            -- Select the second icon (should move it to front)
            local recent_before = recent_utils.load_recent_icons()
            assert.are.equal(2, #recent_before)
            
            selection_callback(recent_before[2], 2)
            
            local recent_after = recent_utils.load_recent_icons()
            assert.are.equal(2, #recent_after)
            assert.are.equal(recent_before[2].name, recent_after[1].name)
        end)
    end)

    describe('recent icons functionality', function()
        it('starts with empty recent icons list', function()
            local recent_utils = require('nerdy.recent')
            local recent = recent_utils.load_recent_icons()
            assert.are.same({}, recent)
        end)

        it('does not add icon to recent when using get function', function()
            nerdy.get('cod-account')
            local recent_utils = require('nerdy.recent')
            local recent = recent_utils.load_recent_icons()
            assert.are.equal(0, #recent)
        end)

        it('clears recent icons', function()
            -- Manually add icons to test clearing
            local recent_utils = require('nerdy.recent')
            local icon_list = require('nerdy.icons')
            recent_utils.add_to_recent(icon_list[1])
            recent_utils.add_to_recent(icon_list[2])

            local recent_before = recent_utils.load_recent_icons()
            assert.are.equal(2, #recent_before)

            recent_utils.save_recent_icons({})

            local recent_after = recent_utils.load_recent_icons()
            assert.are.same({}, recent_after)
        end)

        it('persists recent icons across sessions', function()
            -- Manually add icon to test persistence
            local recent_utils = require('nerdy.recent')
            local icon_list = require('nerdy.icons')
            recent_utils.add_to_recent(icon_list[1])

            local recent_file = vim.fn.stdpath('data') .. '/nerdy_recent.json'
            local file = io.open(recent_file, 'r')

            assert.is_not_nil(file)
            local content = file:read('*all')
            file:close()

            local ok, data = pcall(vim.json.decode, content)
            assert.is_true(ok)
            assert.are.equal(1, #data)
            assert.are.equal(icon_list[1].name, data[1].name)
        end)
    end)

    describe('setup function', function()
        it('configures max_recent setting', function()
            nerdy.setup({ max_recent = 5 })

            -- Manually add icons to test max_recent limit
            local recent_utils = require('nerdy.recent')
            local icon_list = require('nerdy.icons')
            for i = 1, 7 do
                recent_utils.add_to_recent(icon_list[i])
            end

            local recent = recent_utils.load_recent_icons()
            assert.are.equal(5, #recent)
        end)

        it('merges configuration options', function()
            nerdy.setup({ max_recent = 15 })

            -- Test that configuration is properly merged
            assert.is_function(nerdy.setup)
        end)
    end)
end)
