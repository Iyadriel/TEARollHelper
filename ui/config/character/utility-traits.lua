local _, ns = ...

local character = ns.character
local rules = ns.rules
local ui = ns.ui

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

--[[ local options = {
    order: Number,
    slotIndex: Number,
} ]]
ui.modules.config.modules.character.modules.utilityTraits.getOptions = function(options)
    local slotIndex = options.slotIndex

    local function shouldHide()
        local maxTraits = rules.utility.getNumAllowedUtilityTraits()
        return slotIndex > maxTraits
    end

    return {
        trait = {
            order = options.order,
            type = "input",
            name = function()
                return "Utility trait " .. slotIndex
            end,
            width = 0.8,
            desc = "Enter the name of your utility trait.",
            hidden = shouldHide,
            get = function()
                return character.getUtilityTraitAtSlot(slotIndex).name
            end,
            set = function(info, name)
                character.setUtilityTraitAtSlot(slotIndex, name)
                updateTurnUI()
            end,
        },
    }
end