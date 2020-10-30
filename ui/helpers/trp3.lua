local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local integrations = ns.integrations
local settings = ns.settings
local ui = ns.ui

--[[ local options = {
    order: Number,
} ]]
local function updateTRPButton(options)
    return {
        order = options.order,
        type = "execute",
        name = "Update Total RP",
        desc = "Update your Total RP 'Currently' with your current/max HP",
        width = "full",
        hidden = function()
            return not integrations.TRP or settings.autoUpdateTRP.get()
        end,
        confirm = function()
            if not TEARollHelper.db.global.warningsSeen.updateTRP then
                return "This will allow this addon to overwrite any content you have set in your 'Currently' field."
            end
            return false
        end,
        func = function()
            integrations.TRP.updateCurrently()
            TEARollHelper:Print("Updated your Total RP profile.")
            TEARollHelper.db.global.warningsSeen.updateTRP = true
        end,
    }
end

--[[ local options = {
    order: Number,
} ]]
local function autoUpdateTRPNote(options)
    return {
        order = options.order,
        type = "description",
        name = COLOURS.NOTE .. " |nYour Total RP is set to update automatically when needed.|n ",
        hidden = function()
            return not (integrations.TRP and settings.autoUpdateTRP.get())
        end,
    }
end

ui.helpers.updateTRPButton = updateTRPButton
ui.helpers.autoUpdateTRPNote = autoUpdateTRPNote