---@class CodeCompanion.History.MiniPicker : CodeCompanion.History.DefaultPicker
local MiniPicker = setmetatable({}, {
    __index = require("codecompanion._extensions.history.pickers.default"),
})
MiniPicker.__index = MiniPicker

function MiniPicker:browse()
    local mini_pick = require("mini.pick")

    local function get_selected_items()
        local state = mini_pick.get_picker_state()
        if not state then
            return {}
        end

        if state.selection and #state.selection > 0 then
            return state.selection
        end

        if state.current then
            return { state.current }
        end

        return {}
    end

    local mappings = {
        [self.config.keymaps.rename.n] = function()
            local state = mini_pick.get_picker_state()
            local item = state and state.current
            if not item then
                return
            end
            self.config.handlers.on_rename(item)
        end,
        [self.config.keymaps.rename.i] = function()
            local state = mini_pick.get_picker_state()
            local item = state and state.current
            if not item then
                return
            end
            self.config.handlers.on_rename(item)
        end,
        [self.config.keymaps.delete.n] = function()
            local items = get_selected_items()
            if #items == 0 then
                return
            end
            self.config.handlers.on_delete(items)
        end,
        [self.config.keymaps.delete.i] = function()
            local items = get_selected_items()
            if #items == 0 then
                return
            end
            self.config.handlers.on_delete(items)
        end,
        [self.config.keymaps.duplicate.n] = function()
            local state = mini_pick.get_picker_state()
            local item = state and state.current
            if item and self.config.handlers.on_duplicate then
                self.config.handlers.on_duplicate(item)
            end
        end,
        [self.config.keymaps.duplicate.i] = function()
            local state = mini_pick.get_picker_state()
            local item = state and state.current
            if item and self.config.handlers.on_duplicate then
                self.config.handlers.on_duplicate(item)
            end
        end,
    }

    local source = {
        name = self.config.title,
        items = self.config.items,
        show = function(item)
            return self:format_entry(item)
        end,
        on_choice = function(item)
            if item then
                self.config.handlers.on_select(item)
            end
        end,
        mappings = mappings,
    }

    local ok, err = pcall(mini_pick.start, {
        source = source,
    })

    if not ok then
        mini_pick.start({
            source = self.config.title,
            items = self.config.items,
            show = function(item)
                return self:format_entry(item)
            end,
            on_choice = function(item)
                if item then
                    self.config.handlers.on_select(item)
                end
            end,
            mappings = mappings,
        })
    end
end

return MiniPicker
